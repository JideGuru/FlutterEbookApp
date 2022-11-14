// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:archive/archive.dart';
import 'package:mno_shared/src/zip/file_buffer.dart';
import 'package:mno_shared/src/zip/lazy_zip_file_header.dart';

class LazyZipFile {
  static const int store = 0;
  static const int deflate = 8;
  static const int bzip2 = 12;

  static const int zipSignature = 0x04034b50;

  late int offsetStart, offsetEnd;
  int signature = zipSignature; // 4 bytes
  int version = 0; // 2 bytes
  int flags = 0; // 2 bytes
  int compressionMethod = 0; // 2 bytes
  int lastModFileTime = 0; // 2 bytes
  int lastModFileDate = 0; // 2 bytes
  late int crc32; // 4 bytes
  late int compressedSize; // 4 bytes
  late int uncompressedSize; // 4 bytes
  String filename = ''; // 2 bytes length, n-bytes data
  List<int> extraField = []; // 2 bytes length, n-bytes data
  LazyZipFileHeader header;
  String? password;

  LazyZipFile(this.header, this.password);

  Future<void> load(FileBuffer input) async {
    offsetStart = input.position;
    signature = await input.readUint32();
    if (signature != zipSignature) {
      throw ArchiveException('Invalid Zip Signature');
    }

    version = await input.readUint16();
    flags = await input.readUint16();
    compressionMethod = await input.readUint16();
    lastModFileTime = await input.readUint16();
    lastModFileDate = await input.readUint16();
    crc32 = await input.readUint32();
    compressedSize = await input.readUint32();
    uncompressedSize = await input.readUint32();
    int fnLen = await input.readUint16();
    int exLen = await input.readUint16();
    filename = await input.readString(fnLen);
    extraField = await input.read(exLen);
    // Read compressedSize bytes for the compressed data.
    offsetEnd = input.position;

    if (password != null) {
      _initKeys(password!);
      _isEncrypted = true;
    }

    // If bit 3 (0x08) of the flags field is set, then the CRC-32 and file
    // sizes are not known when the header is written. The fields in the
    // local header are filled with zero, and the CRC-32 and size are
    // appended in a 12-byte structure (optionally preceded by a 4-byte
    // signature) immediately after the compressed data:
    if (flags & 0x08 != 0) {
      int sigOrCrc = await input.readUint32();
      if (sigOrCrc == 0x08074b50) {
        crc32 = await input.readUint32();
      } else {
        crc32 = sigOrCrc;
      }

      compressedSize = await input.readUint32();
      uncompressedSize = await input.readUint32();
    }
  }

  @override
  String toString() => filename;

  void _initKeys(String password) {
    _keys[0] = 305419896;
    _keys[1] = 591751049;
    _keys[2] = 878082192;
    for (int c in password.codeUnits) {
      _updateKeys(c);
    }
  }

  void _updateKeys(int c) {
    _keys[0] = CRC32(_keys[0], c);
    _keys[1] += _keys[0] & 0xff;
    _keys[1] = _keys[1] * 134775813 + 1;
    _keys[2] = CRC32(_keys[2], _keys[1] >> 24);
  }

  bool get isEncrypted => _isEncrypted;

  bool _isEncrypted = false;
  final List<int> _keys = [0, 0, 0];
}
