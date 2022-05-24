// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:archive/archive.dart';
import 'package:mno_shared/src/zip/file_buffer.dart';
import 'package:mno_shared/src/zip/lazy_zip_file.dart';

class LazyZipFileHeader {
  static const int zipSignature = 0x02014b50;
  int signature = 0; // 2 bytes
  int versionMadeBy = 0; // 2 bytes
  int versionNeededToExtract = 0; // 2 bytes
  int generalPurposeBitFlag = 0; // 2 bytes
  int compressionMethod = 0; // 2 bytes
  int lastModifiedFileTime = 0; // 2 bytes
  int lastModifiedFileDate = 0; // 2 bytes
  late int crc32; // 4 bytes
  late int compressedSize; // 4 bytes
  late int uncompressedSize; // 4 bytes
  late int diskNumberStart; // 2 bytes
  late int internalFileAttributes; // 2 bytes
  late int externalFileAttributes; // 4 bytes
  late int localHeaderOffset; // 4 bytes
  String filename = '';
  List<int> extraField = [];
  String fileComment = '';
  late LazyZipFile file;

  LazyZipFileHeader(this.signature);

  Future<void> load(
      InputStream input, FileBuffer bytes, String? password) async {
    versionMadeBy = input.readUint16();
    versionNeededToExtract = input.readUint16();
    generalPurposeBitFlag = input.readUint16();
    compressionMethod = input.readUint16();
    lastModifiedFileTime = input.readUint16();
    lastModifiedFileDate = input.readUint16();
    crc32 = input.readUint32();
    compressedSize = input.readUint32();
    uncompressedSize = input.readUint32();
    int fnameLen = input.readUint16();
    int extraLen = input.readUint16();
    int commentLen = input.readUint16();
    diskNumberStart = input.readUint16();
    internalFileAttributes = input.readUint16();
    externalFileAttributes = input.readUint32();
    localHeaderOffset = input.readUint32();

    if (fnameLen > 0) {
      filename = input.readString(size: fnameLen);
    }

    if (extraLen > 0) {
      InputStreamBase extra = input.readBytes(extraLen);
      extraField = extra.toUint8List();

      int id = extra.readUint16();
      int size = extra.readUint16();
      if (id == 1) {
        // Zip64 extended information
        // Original
        // Size       8 bytes    Original uncompressed file size
        // Compressed
        // Size       8 bytes    Size of compressed data
        // Relative Header
        // Offset     8 bytes    Offset of local header record
        // Disk Start
        // Number     4 bytes    Number of the disk on which
        // this file starts
        if (size >= 8) {
          uncompressedSize = extra.readUint64();
        }
        if (size >= 16) {
          compressedSize = extra.readUint64();
        }
        if (size >= 24) {
          localHeaderOffset = extra.readUint64();
        }
        if (size >= 28) {
          diskNumberStart = extra.readUint32();
        }
      }
    }

    if (commentLen > 0) {
      fileComment = input.readString(size: commentLen);
    }

    bytes.position = localHeaderOffset;
    file = LazyZipFile(this, password);
    await file.load(bytes);
  }

  @override
  String toString() => filename;
}
