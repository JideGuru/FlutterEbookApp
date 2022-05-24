// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/src/publication/html/dom_range.dart';
import 'package:test/test.dart';

void main() {
  test("parse {DomRange} minimal JSON", () {
    expect(
        DomRange(start: Point(cssSelector: "p", textNodeIndex: 4)),
        DomRange.fromJson("""{
                "start": {
                    "cssSelector": "p",
                    "textNodeIndex": 4
                }
            }"""
            .toJsonOrNull()));
  });

  test("parse {DomRange} full JSON", () {
    expect(
        DomRange(
            start: Point(cssSelector: "p", textNodeIndex: 4),
            end: Point(cssSelector: "a", textNodeIndex: 2)),
        DomRange.fromJson("""{
                "start": {
                    "cssSelector": "p",
                    "textNodeIndex": 4
                },
                "end": {
                    "cssSelector": "a",
                    "textNodeIndex": 2
                }
            }"""
            .toJsonOrNull()));
  });

  test("parse {DomRange} invalid JSON", () {
    expect(DomRange.fromJson('{ "invalid": "object" }'.toJsonOrNull()), isNull);
  });

  test("parse {DomRange} null JSON", () {
    expect(DomRange.fromJson(null), isNull);
  });

  test("get {DomRange} minimal JSON", () {
    expect(
        """{
                "start": {
                    "cssSelector": "p",
                    "textNodeIndex": 4
                }
            }"""
            .toJsonOrNull(),
        DomRange(start: Point(cssSelector: "p", textNodeIndex: 4)).toJson());
  });

  test("get {DomRange} full JSON", () {
    expect(
        """{
                "start": {
                    "cssSelector": "p",
                    "textNodeIndex": 4
                },
                "end": {
                    "cssSelector": "a",
                    "textNodeIndex": 2
                }
            }"""
            .toJsonOrNull(),
        DomRange(
                start: Point(cssSelector: "p", textNodeIndex: 4),
                end: Point(cssSelector: "a", textNodeIndex: 2))
            .toJson());
  });

  test("parse {Point} minimal JSON", () {
    expect(
        Point(cssSelector: "p", textNodeIndex: 4),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 4
            }"""
            .toJsonOrNull()));
  });

  test("parse {Point} full JSON", () {
    expect(
        Point(cssSelector: "p", textNodeIndex: 4, charOffset: 32),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 4,
                "charOffset": 32
            }"""
            .toJsonOrNull()));
  });

  /**
   * ", offset",  got replaced with ", charOffset", , but we still need to be able to parse it to ensure
   * backward-compatibility for apps which persisted legacy versions of the DomRange model.
   */
  test("parse legacy {Point} JSON", () {
    expect(
        Point(cssSelector: "p", textNodeIndex: 4, charOffset: 32),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 4,
                "offset": 32
            }"""
            .toJsonOrNull()));
  });

  test("parse {Point} invalid JSON", () {
    expect(
        Point.fromJson("""{
            "cssSelector": "p"
        }"""
            .toJsonOrNull()),
        isNull);
  });

  test("parse {Point} null JSON", () {
    expect(Point.fromJson(null), isNull);
  });

  test("parse {Point} requires positive {textNodeIndex}", () {
    expect(
        Point(cssSelector: "p", textNodeIndex: 1),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 1
            }"""
            .toJsonOrNull()));
    expect(
        Point(cssSelector: "p", textNodeIndex: 0),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 0
            }"""
            .toJsonOrNull()));
    expect(
        DomRange.fromJson("""{
            "cssSelector": "p",
            "textNodeIndex": -1
        }"""
            .toJsonOrNull()),
        isNull);
  });

  test("parse {Point} requires positive {charOffset}", () {
    expect(
        Point(cssSelector: "p", textNodeIndex: 1, charOffset: 1),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 1,
                "charOffset": 1
            }"""
            .toJsonOrNull()));
    expect(
        Point(cssSelector: "p", textNodeIndex: 1, charOffset: 0),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 1,
                "charOffset": 0
            }"""
            .toJsonOrNull()));
    expect(
        Point(cssSelector: "p", textNodeIndex: 1),
        Point.fromJson("""{
                "cssSelector": "p",
                "textNodeIndex": 1,
                "charOffset": -1
            }"""
            .toJsonOrNull()));
  });

  test("get {Point} minimal JSON", () {
    expect(
        """{
                "cssSelector": "p",
                "textNodeIndex": 4
            }"""
            .toJsonOrNull(),
        Point(cssSelector: "p", textNodeIndex: 4).toJson());
  });

  test("get {Point} full JSON", () {
    expect(
        """{
                "cssSelector": "p",
                "textNodeIndex": 4,
                "charOffset": 32
            }"""
            .toJsonOrNull(),
        Point(cssSelector: "p", textNodeIndex: 4, charOffset: 32).toJson());
  });
}
