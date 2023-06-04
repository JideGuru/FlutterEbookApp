// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse null JSON", () {
    expect(Properties(), Properties.fromJSON(null));
  });

  test("parse minimal JSON", () {
    expect(Properties(), Properties.fromJSON("{}".toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Properties(otherProperties: {
          "other-property1": "value",
          "other-property2": [42]
        }),
        Properties.fromJSON("""{
                "other-property1": "value",
                "other-property2": [42]
            }"""
            .toJsonOrNull()));
  });

  test("get minimal JSON", () {
    expect({}, Properties().toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "other-property1": "value",
                "other-property2": [42]
            }"""
            .toJsonOrNull(),
        Properties(otherProperties: {
          "other-property1": "value",
          "other-property2": [42]
        }).toJson());
  });

  test("copy after adding the given {properties}", () {
    var properties = Properties(otherProperties: {
      "other-property1": "value",
      "other-property2": [42]
    });
    expect(
        """{
                "other-property1": "value",
                "other-property2": [42],
                "additional": "property"
            }"""
            .toJsonOrNull(),
        properties.add({"additional": "property"}).toJson());
  });
}
