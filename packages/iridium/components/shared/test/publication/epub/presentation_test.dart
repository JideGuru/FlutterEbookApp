// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  Link createLink(EpubLayout? layout) => Link(
      href: "res",
      properties: Properties(
          otherProperties: layout?.let((it) => {"layout": it.value}) ?? {}));

  test("Get the layout of a reflowable resource", () {
    expect(EpubLayout.reflowable,
        Presentation(layout: null).layoutOf(createLink(EpubLayout.reflowable)));
  });

  test("Get the layout of a fixed resource", () {
    expect(EpubLayout.fixed,
        Presentation(layout: null).layoutOf(createLink(EpubLayout.fixed)));
  });

  test("The layout of a resource takes precedence over the document layout",
      () {
    expect(
        EpubLayout.fixed,
        Presentation(layout: EpubLayout.reflowable)
            .layoutOf(createLink(EpubLayout.fixed)));
  });

  test("Get the layout falls back on the document layout", () {
    expect(EpubLayout.fixed,
        Presentation(layout: EpubLayout.fixed).layoutOf(createLink(null)));
  });

  test("Get the layout falls back on REFLOWABLE", () {
    expect(EpubLayout.reflowable,
        Presentation(layout: null).layoutOf(createLink(null)));
  });
}
