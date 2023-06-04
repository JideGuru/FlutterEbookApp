// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/src/opds/price.dart';
import 'package:test/test.dart';

void main() {
  test("parse JSON price", () {
    expect(Price(currency: "EUR", value: 4.65),
        Price.fromJSON('{"currency": "EUR", "value": 4.65}'.toJsonOrNull()));
  });

  test("parse invalid JSON price", () {
    expect(Price.fromJSON('{}'.toJsonOrNull()), isNull);
  });

  test("parse null JSON price", () {
    expect(Price.fromJSON(null), isNull);
  });

  test("parse JSON price requires {currency}", () {
    expect(Price.fromJSON('{"value": 4.65}'.toJsonOrNull()), isNull);
  });

  test("parse JSON price requires {value}", () {
    expect(Price.fromJSON('{"currency": "EUR"}'.toJsonOrNull()), isNull);
  });

  test("parse JSON price requires positive {value}", () {
    expect(Price.fromJSON('{"currency": "EUR", "value": -20}'.toJsonOrNull()),
        null);
  });

  test("get JSON price", () {
    expect('{"currency": "EUR", "value": 4.65}'.toJsonOrNull(),
        Price(currency: "EUR", value: 4.65).toJson());
  });
}
