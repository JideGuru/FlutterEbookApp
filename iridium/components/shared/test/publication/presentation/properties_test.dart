// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/epub.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("get Properties {clipped} when available", () {
    expect(true, Properties(otherProperties: {"clipped": true}).clipped);
  });

  test("get Properties {clipped} when missing", () {
    expect(Properties().clipped, isNull);
  });

  test("get Properties {fit} when available", () {
    expect(PresentationFit.cover,
        Properties(otherProperties: {"fit": "cover"}).fit);
  });

  test("get Properties {fit} when missing", () {
    expect(Properties().fit, isNull);
  });

  test("get Properties {orientation} when available", () {
    expect(PresentationOrientation.landscape,
        Properties(otherProperties: {"orientation": "landscape"}).orientation);
  });

  test("get Properties {orientation} when missing", () {
    expect(Properties().orientation, isNull);
  });

  test("get Properties {overflow} when available", () {
    expect(PresentationOverflow.scrolled,
        Properties(otherProperties: {"overflow": "scrolled"}).overflow);
  });

  test("get Properties {overflow} when missing", () {
    expect(Properties().overflow, isNull);
  });

  test("get Properties {page} when available", () {
    expect(PresentationPage.right,
        Properties(otherProperties: {"page": "right"}).page);
  });

  test("get Properties {page} when missing", () {
    expect(Properties().page, isNull);
  });

  test("get Properties {spread} when available", () {
    expect(PresentationSpread.both,
        Properties(otherProperties: {"spread": "both"}).spread);
  });

  test("get Properties {spread} when missing", () {
    expect(Properties().spread, isNull);
  });
}
