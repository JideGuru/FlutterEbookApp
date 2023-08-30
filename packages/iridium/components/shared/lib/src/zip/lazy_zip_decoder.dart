// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:archive/archive.dart' as a;
import 'package:mno_shared/src/zip/file_buffer.dart';
import 'package:mno_shared/src/zip/lazy_archive.dart';
import 'package:mno_shared/src/zip/lazy_archive_file.dart';
import 'package:mno_shared/src/zip/lazy_zip_directory.dart';
import 'package:mno_shared/src/zip/lazy_zip_file.dart';
import 'package:mno_shared/src/zip/lazy_zip_file_header.dart';
import 'package:universal_io/io.dart' hide Link;

/// Decode a zip formatted buffer into an [Archive] object.
class LazyZipDecoder {
  Future<LazyArchive> decodeBuffer(File file, {String? password}) async {
    final fileBuffer = await FileBuffer.from(file);
    LazyArchive archive = LazyArchive();
    LazyZipDirectory directory = LazyZipDirectory();
    return directory.load(fileBuffer, password: password).then((_) {
      for (LazyZipFileHeader zfh in directory.fileHeaders) {
        LazyZipFile zf = zfh.file;

        // The attributes are stored in base 8
        final mode = zfh.externalFileAttributes;
        final compress = zf.compressionMethod != a.ZipFile.STORE;

        LazyArchiveFile file = LazyArchiveFile(
            zfh, zf.filename, zf.uncompressedSize, zf.compressionMethod);

        file.mode = mode >> 16;

        // see https://github.com/brendan-duncan/archive/issues/21
        // UNIX systems has a creator version of 3 decimal at 1 byte offset
        if (zfh.versionMadeBy >> 8 == 3) {
          //final bool isDirectory = file.mode & 0x7000 == 0x4000;
          final bool isFile = file.mode & 0x3F000 == 0x8000;
          file.isFile = isFile;
        } else {
          file.isFile = !file.name.endsWith('/');
        }

        file.crc32 = zf.crc32;
        file.compress = compress;
        file.lastModTime = zf.lastModFileDate << 16 | zf.lastModFileTime;

        archive.addFile(file);
      }

      return archive;
    }).whenComplete(fileBuffer.close);
  }
}
