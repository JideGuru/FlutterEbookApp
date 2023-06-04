// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/src/streams/stream.dart';

class ContainerException implements Exception {
  /// A file on the filesystem is not found.
  factory ContainerException.fileNotFound(String path) =>
      ContainerException("File not found at `$path`");

  /// A resource contained in the [Container] is not found.
  factory ContainerException.resourceNotFound(String path) =>
      ContainerException("Resource not found at `$path`");

  const ContainerException(this.message);

  final String message;

  @override
  String toString() => 'ContainerException{message: $message}';
}

/// Access to a hierarchy of files (eg. archive, directory, remote server).
abstract class Container {
  Container();

  /// Unique identifier representing the served contents.
  /// For example, a file path, an URL, a checksum, etc.
  String get identifier;

  /// Returns whether there is contents at the given relative [path].
  Future<bool> existsAt(String path);

  /// Returns the data stream for the contents at the given relative [path].
  Future<DataStream> streamAt(String path);

  Future<int> resourceLength(String path);
}
