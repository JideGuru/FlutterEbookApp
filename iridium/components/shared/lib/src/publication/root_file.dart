// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class RootFile {
  String rootPath;
  String rootFilePath;
  String mimetype;
  double? version;

  RootFile(
      {this.rootPath = "",
      this.rootFilePath = "",
      this.mimetype = "",
      this.version});

  @override
  String toString() =>
      'RootFile{rootPath: $rootPath, rootFilePath: $rootFilePath, '
      'mimetype: $mimetype, version: $version}';
}
