// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/src/zip/lazy_zip_file_header.dart';

/// A file contained in an Archive.
class LazyArchiveFile {
  static const int store = 0;
  static const int deflate = 8;

  LazyZipFileHeader header;
  String name;

  /// The uncompressed size of the file
  int size = 0;
  int mode = 0;
  int ownerId = 0;
  int groupId = 0;
  int lastModTime = 0;
  bool isFile = true;
  bool isSymbolicLink = false;
  String nameOfLinkedFile = "";

  /// The crc32 checksum of the uncompressed content.
  late int crc32;

  /// If false, this file will not be compressed when encoded to an archive
  /// format such as zip.
  bool compress = true;

  int get unixPermissions => mode & 0x1FF;

  LazyArchiveFile(this.header, this.name, this.size,
      [this._compressionType = store]);

  /// Is the data stored by this file currently compressed?
  bool get isCompressed => _compressionType != store;

  /// What type of compression is the raw data stored in
  int get compressionType => _compressionType;

  @override
  String toString() => name;

  final int _compressionType;
}
