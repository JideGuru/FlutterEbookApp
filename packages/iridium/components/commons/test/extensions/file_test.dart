// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/files.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;

void main() {
  test("firstComponent works well when {File} is a directory", () {
    expect("dir", File("/dir").firstComponent.path);
  });

  test("firstComponent works well when {File} is a file at root", () {
    expect("image.jpg", File("/image.jpg").firstComponent.path);
  });

  test("firstComponent works well when {File} is a file inside a directory",
      () {
    expect("dir1", File("/dir1/dir2/image.jpg").firstComponent.path);
  });
}
