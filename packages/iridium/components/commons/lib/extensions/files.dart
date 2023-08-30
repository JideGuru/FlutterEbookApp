// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:crypto/crypto.dart' as crypto;
import 'package:dfunc/dfunc.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart' hide Link;

extension FileSystemEntityExtension on FileSystemEntity {
  String get lowercasedExtension => extension(path).toLowerCase();

  bool get isHiddenOrThumbs => path
      .let((it) => basename(it))
      .let((it) => it.startsWith(".") || it == "Thumbs.db");

  /// Returns a [File] to the first component of the [File]'s path,
  /// regardless of whether it is a directory or a file.
  File get firstComponent {
    List<String> elem = split(path);
    String result = elem.firstWhere((it) => it != "/", orElse: () => path);
    return File(result);
  }
}

extension FileExtension on File {
  Future<String> get md5 =>
      crypto.md5.bind(this.openRead()).map((value) => value.toString()).first;
}
