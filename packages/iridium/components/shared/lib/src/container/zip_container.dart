// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/src/container/container.dart';
import 'package:mno_shared/src/streams/stream.dart';
import 'package:mno_shared/src/streams/zip_stream.dart';
import 'package:mno_shared/zip.dart';
import 'package:universal_io/io.dart' hide Link;

/// [Container] providing access to ZIP archives.
class ZipContainer extends Container {
  ZipContainer(this.path) : assert(path.isNotEmpty);

  /// Absolute path to the ZIP archive.
  final String path;

  @override
  String get identifier => path;

  /// ZIP archive holder.
  Future<ZipPackage?> get archive async {
    if (_archive == null) {
      File file = File(path);
      if (!await file.exists()) {
        return null;
      }
      _archive = await ZipPackage.fromArchive(file);
    }
    return _archive;
  }

  ZipPackage? _archive;

  @override
  Future<bool> existsAt(String path) async =>
      (await archive)?.entries[path] != null;

  @override
  Future<DataStream> streamAt(String path) async {
    ZipPackage? package =
        await archive.catchError((e, st) => ZipPackage(File("")));
    ZipLocalFile? entry = package?.entries[path];
    if (package == null || entry == null) {
      throw ContainerException.resourceNotFound(path);
    }
    return ZipStream(package, entry);
  }

  @override
  Future<int> resourceLength(String path) async {
    ZipPackage? package = await archive;
    ZipLocalFile? entry = package?.entries[path];
    if (entry == null) {
      throw ContainerException.resourceNotFound(path);
    }
    return entry.uncompressedSize;
  }
}
