// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart' as pub;

/// Decrypts a resource protected with LCP.
class LcpDecryptor {
  final LcpLicense? license;

  LcpDecryptor(this.license);

  Resource transform(Resource resource) => LazyResource(() async {
        // Checks if the resource is encrypted and whether the encryption schemes of the resource
        // and the DRM license are the same.
        pub.Link link = await resource.link();
        pub.Encryption? encryption = link.properties.encryption;
        if (encryption == null ||
            encryption.scheme != "http://readium.org/2014/01/lcp") {
          return resource;
        }

        if (license == null) {
          return FailureResource(link, ResourceException.forbidden);
        }
        if (link.isDeflated || !link.isCbcEncrypted) {
          return FullLcpResource(resource, license!);
        }
        return CbcLcpResource(resource, license!);
      });
}

/// A  LCP resource that is read, decrypted and cached fully before reading requested ranges.
///
/// Can be used when it's impossible to map a read range (byte range request) to the encrypted
/// resource, for example when the resource is deflated before encryption.
class FullLcpResource extends TransformingResource {
  final LcpLicense license;

  FullLcpResource(super.resource, this.license);

  @override
  Future<ResourceTry<ByteData>> transform(ResourceTry<ByteData> data) async =>
      license.decryptFully(data, (await resource.link()).isDeflated);

  @override
  Future<ResourceTry<int>> length() async {
    int? originalLength =
        (await resource.link()).properties.encryption?.originalLength;
    return originalLength != null
        ? Future.value(ResourceTry.success(originalLength))
        : super.length();
  }
}

class CbcLcpResource extends Resource {
  static const int aesBlockSize = 16; // bytes
  final Resource resource;
  final LcpLicense license;
  // Note: we don't declare this _length member as "late" according to
  // https://dart.dev/guides/language/effective-dart/usage#avoid-late-variables-if-you-need-to-check-whether-they-are-initialized
  ResourceTry<int>? _length;

  CbcLcpResource(this.resource, this.license);

  @override
  Future<pub.Link> link() => resource.link();

  @override
  Future<ResourceTry<int>> length() async {
    if (_length != null) {
      return _length!;
    }
    _length = await resource
        .length()
        .then((res) => res.flatMapWaitResource((length) async {
              if (length < 2 * aesBlockSize) {
                throw Exception("Invalid CBC-encrypted stream");
              }
              int readOffset = length - (2 * aesBlockSize);
              return await resource
                  .read(range: IntRange(readOffset, length))
                  .then((res) => res.mapWait((bytes) async {
                        ByteData decryptedBytes = (await license.decrypt(bytes))
                            .getOrElse((failure) => throw Exception(
                                "Can't decrypt trailing size of CBC-encrypted stream $failure"));
                        return length -
                            aesBlockSize - // Minus IV or previous block
                            (aesBlockSize - decryptedBytes.lengthInBytes) %
                                aesBlockSize; // Minus padding part
                      }));
            }));

    return _length!;
  }

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) async {
    if (range == null) {
      return license.decryptFully(await resource.read(), false);
    }

    IntRange range2 = IntRange(max(0, range.first), range.last);

    if (range2.isEmpty) {
      return ResourceTry.success(ByteData(0));
    }
    return resource.length().then((res) =>
        res.flatMapWaitResource((encryptedLength) async {
          // encrypted data is shifted by AES_BLOCK_SIZE because of IV and
          // the previous block must be provided to perform XOR on intermediate blocks
          int encryptedStart = range.first.floorMultipleOf(aesBlockSize);
          int encryptedEndExclusive =
              (range.last + 1).ceilMultipleOf(aesBlockSize) + aesBlockSize;

          return resource
              .read(range: IntRange(encryptedStart, encryptedEndExclusive))
              .then((res) => res.mapWait((encryptedData) async {
                    String href = (await link()).href;
                    ByteData bytes = (await license.decrypt(encryptedData))
                        .getOrElse((failure) => throw Exception(
                            "Can't decrypt the content at: $href, $failure"));

                    // exclude the bytes added to match a multiple of AES_BLOCK_SIZE
                    int sliceStart = range.first - encryptedStart;

                    // was the last block read to provide the desired range
                    bool lastBlockRead =
                        encryptedLength - encryptedEndExclusive <= aesBlockSize;
                    int rangeLength =
                        await _computeRangeLength(lastBlockRead, range);
                    return bytes.sliceArray(IntRange(sliceStart, rangeLength));
                  }));
        }));
  }

  Future<int> _computeRangeLength(bool lastBlockRead, IntRange range) async {
    int rangeLength;
    if (lastBlockRead) {
      // use decrypted length to ensure range.last doesn't exceed decrypted length - 1
      int l = (await length()).getOrThrow();
      rangeLength = range.last.coerceAtMost(l - 1) - range.first + 1;
    } else {
      rangeLength = range.last - range.first + 1;
    }
    return rangeLength;
  }

  @override
  Future<void> close() => resource.close();
}

extension LcpLicenseExtension on LcpLicense {
  Future<ResourceTry<ByteData>> decryptFully(
          ResourceTry<ByteData> data, bool isDeflated) async =>
      data.mapWait((encryptedData) async {
        // Decrypts the resource.
        ByteData bytes = (await decrypt(encryptedData)).getOrElse((failure) =>
            throw Exception("Failed to decrypt the resource: $failure"));

        if (bytes.lengthInBytes == 0) {
          throw Exception("Lcp.nativeDecrypt returned an empty ByteArray");
        }

        // Removes the padding.
        bytes = bytes.buffer.asByteData(0, bytes.lengthInBytes - bytes.padding);

        // If the ressource was compressed using deflate, inflates it.
        if (isDeflated) {
          bytes = bytes.inflate();
        }
        return bytes;
      });
}

extension LinkExtension on pub.Link {
  bool get isDeflated =>
      properties.encryption?.compression?.toLowerCase() == "deflate";

  bool get isCbcEncrypted =>
      properties.encryption?.algorithm ==
      "http://www.w3.org/2001/04/xmlenc#aes256-cbc";
}

extension IntExtension on int {
  int ceilMultipleOf(int divisor) =>
      (divisor * (this / divisor + ((this % divisor == 0) ? 0 : 1))).truncate();

  int floorMultipleOf(int divisor) => (divisor * (this / divisor)).truncate();
}

extension ByteDataExtension on ByteData {
  int get padding => getInt8(lengthInBytes - 1);
}
