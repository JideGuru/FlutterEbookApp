// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_shared/container.dart';
import 'package:mno_shared/src/util/archive/archive.dart';
import 'package:mno_shared/streams.dart';
import 'package:mno_shared/zip.dart';
import 'package:universal_io/io.dart' hide Link;

class ZipArchiveFactory implements ArchiveFactory {
  const ZipArchiveFactory();

  @override
  Future<Archive?> open(FileSystemEntity file, String? password) async =>
      ZipContainer(file.path)
          .archive
          .then((zipPackage) =>
              (zipPackage != null) ? ZipArchive(zipPackage) : null)
          .catchError((error, stackTrace) {});
}

class ZipArchive extends Archive {
  final ZipPackage archive;

  ZipArchive(this.archive);

  @override
  Future<void> close() async {}

  @override
  Future<List<ArchiveEntry>> entries() async => archive.entries.values
      .where((it) => it.isLocalFile)
      .mapNotNull((it) => ZipEntry(archive, it))
      .toList();

  @override
  Future<ArchiveEntry> entry(String path) async {
    ZipLocalFile? entry = archive.entries[path];
    if (entry == null) {
      throw Exception("No file entry at path $path.");
    }
    return ZipEntry(archive, entry);
  }
}

class ZipEntry extends ArchiveEntry {
  final ZipPackage archive;
  final ZipLocalFile entry;

  ZipEntry(this.archive, this.entry);

  @override
  String get path => entry.filename;

  @override
  int? get length => entry.uncompressedSize.takeUnless((it) => it == -1);

  @override
  int? get compressedLength {
    if (entry.compressionMethod == ZipHeader.stored ||
        entry.compressionMethod == -1) {
      return null;
    } else {
      return entry.compressedSize.takeUnless((it) => it == -1);
    }
  }

  @override
  Future<ByteData> read({IntRange? range}) async => ZipStream(archive, entry)
      .readData(start: range?.start, length: range?.length)
      .then((data) => data.toByteData());

  @override
  Future<void> close() async {}
}
