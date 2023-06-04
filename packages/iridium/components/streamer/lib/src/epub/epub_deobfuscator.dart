// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/fetcher.dart';

class EpubDeobfuscator {
  final String pubId;

  EpubDeobfuscator(this.pubId);

  Resource transform(Resource resource) =>
      DeobfuscatingResource(resource, pubId);
}

class DeobfuscatingResource extends ProxyResource {
  static const Map<String, int> _algorithm2length = {
    "http://www.idpf.org/2008/embedding": 1040,
    "http://ns.adobe.com/pdf/enc#RC": 1024
  };
  final String pubId;

  DeobfuscatingResource(super.resource, this.pubId);

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) async {
    String? algorithm =
        (await resource.link()).properties.encryption?.algorithm;

    if (!_algorithm2length.containsKey(algorithm)) {
      return resource.read(range: range);
    }

    return (await resource.read(range: range)).mapCatching((it) {
      int obfuscationLength = _algorithm2length[algorithm]!;
      ByteData obfuscationKey;
      switch (algorithm) {
        case "http://ns.adobe.com/pdf/enc#RC":
          obfuscationKey = _getHashKeyAdobe(pubId);
          break;
        default:
          obfuscationKey = pubId.sha1.toByteData();
      }

      _deobfuscate(it, range, obfuscationKey, obfuscationLength);
      return it;
    });
  }

  void _deobfuscate(ByteData bytes, IntRange? range, ByteData obfuscationKey,
      int obfuscationLength) {
    range ??= IntRange(0, bytes.lengthInBytes - 1);
    if (range.first >= obfuscationLength) {
      return;
    }

    IntRange toDeobfuscate =
        IntRange(max(range.first, 0), min(range.last, obfuscationLength - 1));
    for (int i in toDeobfuscate) {
      bytes.setUint8(
          i,
          bytes.getUint8(i) ^
              obfuscationKey.getUint8(i % obfuscationKey.lengthInBytes));
    }
  }

  ByteData _getHashKeyAdobe(String pubId) =>
      pubId.replaceFirst("urn:uuid:", "").replaceAll("-", "").toByteData();
}
