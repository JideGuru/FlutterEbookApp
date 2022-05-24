// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("get Properties {contains} when available", () {
    expect(
        {"mathml", "onix"},
        Properties(otherProperties: {
          "contains": ["mathml", "onix"]
        }).contains);
  });

  test("get Properties {contains} removes duplicates", () {
    expect(
        {"mathml", "onix"},
        Properties(otherProperties: {
          "contains": ["mathml", "onix", "onix"]
        }).contains);
  });

  test("get Properties {contains} when missing", () {
    expect(Properties().contains, orderedEquals({}));
  });

  test("get Properties {contains} skips duplicates", () {
    expect(
        {"mathml"},
        Properties(otherProperties: {
          "contains": ["mathml", "mathml"]
        }).contains);
  });

  test("get Properties {layout} when available", () {
    expect(EpubLayout.fixed,
        Properties(otherProperties: {"layout": "fixed"}).layout);
  });

  test("get Properties {layout} when missing", () {
    expect(Properties().layout, isNull);
  });
}
