// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/exceptions.dart';
import 'package:mno_shared/src/util/archive/exploded_archive.dart';
import 'package:mno_shared/src/util/archive/zip_archive.dart';
import 'package:universal_io/io.dart' hide Link;

mixin ArchiveFactory {
  /// Opens an archive from a local [file].
  Future<Archive?> open(FileSystemEntity file, String? password);
}

class DefaultArchiveFactory implements ArchiveFactory {
  final ArchiveFactory zipFactory;
  final ArchiveFactory explodedArchiveFactory;

  const DefaultArchiveFactory()
      : zipFactory = const ZipArchiveFactory(),
        explodedArchiveFactory = const ExplodedArchiveFactory();

  /// Opens a ZIP or exploded archive.
  @override
  Future<Archive?> open(FileSystemEntity file, String? password) async =>
      waitTryOrNull(() async {
        if (await FileSystemEntity.isDirectory(file.path)) {
          return explodedArchiveFactory.open(file, password);
        } else {
          try {
            return await zipFactory.open(file, password);
          } on Exception catch (e, st) {
            Fimber.d("ERROR open archive", ex: e, stacktrace: st);
            return null;
          }
        }
      });
}

/// Represents an immutable archive.
abstract class Archive {
  /// List of all the archived file entries.
  Future<List<ArchiveEntry>> entries();

  /// Gets the entry at the given `path`.
  Future<ArchiveEntry> entry(String path);

  /// Closes the archive.
  Future<void> close();
}

/// Holds an archive entry's metadata.
abstract class ArchiveEntry {
  /// Absolute path to the entry in the archive.
  String get path;

  /// Uncompressed data length.
  int? get length;

  ///  Compressed data length.
  int? get compressedLength;

  /// Reads the whole content of this entry.
  /// When [range] is null, the whole content is returned. Out-of-range indexes are clamped to the
  /// available length automatically.
  Future<ByteData> read({IntRange? range});

  /// Closes any pending resources for this entry.
  Future<void> close();
}
