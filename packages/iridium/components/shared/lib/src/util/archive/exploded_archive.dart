// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_shared/src/util/archive/archive.dart';
import 'package:mno_shared/streams.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart' hide Link;

class ExplodedArchiveFactory implements ArchiveFactory {
  const ExplodedArchiveFactory();

  @override
  Future<Archive?> open(FileSystemEntity file, String? password) async =>
      ExplodedArchive(Directory(file.path));
}

class ExplodedArchive extends Archive {
  final Directory directory;

  ExplodedArchive(this.directory);

  @override
  Future<void> close() async {}

  @override
  Future<List<ArchiveEntry>> entries() => directory
      .list(recursive: true)
      .where((it) => FileSystemEntity.isFileSync(it.path))
      .map((it) => ExplodedEntry(it as File, directory))
      .toList();

  @override
  Future<ArchiveEntry> entry(String path) async {
    File file = File(join(directory.path, path));
    if (!isWithin(directory.path, file.path) ||
        !await FileSystemEntity.isFile(file.path)) {
      throw Exception("No file entry at path $path.");
    }
    return ExplodedEntry(file, directory);
  }
}

class ExplodedEntry extends ArchiveEntry {
  final File file;
  final Directory directory;

  ExplodedEntry(this.file, this.directory);

  @override
  int? get compressedLength => null;

  @override
  int? get length => file.lengthSync();

  @override
  String get path =>
      relative(file.path, from: directory.path).replaceAll("\\", "/");

  @override
  Future<ByteData> read({IntRange? range}) async => FileStream.fromFile(file)
      .then((stream) =>
          stream.readData(start: range?.start, length: range?.length))
      .then((data) => data.toByteData());

  @override
  Future<void> close() async {}
}
