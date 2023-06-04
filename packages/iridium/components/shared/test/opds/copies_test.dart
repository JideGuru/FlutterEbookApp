// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/src/opds/copies.dart';
import 'package:test/test.dart';

void main() {
  test("parse minimal JSON copies", () {
    expect(Copies(total: null, available: null),
        equals(Copies.fromJSON("{}".toJsonOrNull())));
  });

  test("parse full JSON copies", () {
    expect(Copies(total: 5, available: 6),
        equals(Copies.fromJSON('{"total": 5, "available": 6}'.toJsonOrNull())));
  });

  test("parse null JSON copies", () {
    expect(Copies.fromJSON(null), isNull);
  });

  test("parse JSON copies requires positive {total}", () {
    expect(
        Copies(total: null, available: 6),
        equals(
            Copies.fromJSON('{"total": -5, "available": 6}'.toJsonOrNull())));
  });

  test("parse JSON copies requires positive {available}", () {
    expect(
        Copies(total: 5, available: null),
        equals(
            Copies.fromJSON('{"total": 5, "available": -6}'.toJsonOrNull())));
  });

  test("get minimal JSON copies", () {
    expect("{}".toJsonOrNull(),
        equals(Copies(total: null, available: null).toJson()));
  });

  test("get full JSON copies", () {
    expect('{"total": 5, "available": 6}'.toJsonOrNull(),
        equals(Copies(total: 5, available: 6).toJson()));
  });
}
