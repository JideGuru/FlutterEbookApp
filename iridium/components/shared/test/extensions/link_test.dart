// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("hrefCommonFirstComponent is null when files are in the root", () {
    expect(
        [Link(href: "/im1.jpg"), Link(href: "/im2.jpg"), Link(href: "/toc.xml")]
            .hrefCommonFirstComponent(),
        isNull);
  });

  test(
      "hrefCommonFirstComponent is null when files are in different directories",
      () {
    expect(
        [
          Link(href: "/dir1/im1.jpg"),
          Link(href: "/dir2/im2.jpg"),
          Link(href: "/toc.xml")
        ].hrefCommonFirstComponent(),
        isNull);
  });

  test(
      "hrefCommonFirstComponent is correct when there is only one file in the root",
      () {
    expect(
        "im1.jpg", [Link(href: "/im1.jpg")].hrefCommonFirstComponent()?.path);
  });

  test(
      "hrefCommonFirstComponent is correct when all files are in the same directory",
      () {
    expect(
        "root",
        [
          Link(href: "/root/im1.jpg"),
          Link(href: "/root/im2.jpg"),
          Link(href: "/root/xml/toc.xml")
        ].hrefCommonFirstComponent()?.path);
  });
}
