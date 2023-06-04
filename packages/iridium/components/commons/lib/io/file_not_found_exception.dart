// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class FileNotFoundException implements Exception {
  final String path;

  FileNotFoundException(this.path);

  @override
  String toString() => 'FileNotFoundException{$path}';
}
