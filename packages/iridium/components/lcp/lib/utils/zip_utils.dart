// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_archive/flutter_archive.dart';
import 'package:universal_io/io.dart' hide Link;

class ZipUtils {
  static Future<void> injectEntry(File zipFile, ByteEntry entry) {
    Directory tmp = Directory("${zipFile.path}.tmp");
    File entryFile = File(tmp.path + Platform.pathSeparator + entry.path);
    return ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: tmp)
        .then((_) => entryFile.writeAsBytes(entry.data.buffer.asUint8List()))
        .then((_) =>
            ZipFile.createFromDirectory(sourceDir: tmp, zipFile: zipFile))
        .then((_) => tmp.delete(recursive: true));
  }
}

class ByteEntry {
  final String path;
  final ByteData data;

  ByteEntry(this.path, this.data);
}
