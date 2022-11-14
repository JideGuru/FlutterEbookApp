// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/src/opds/holds.dart';
import 'package:test/test.dart';

void main() {
  test("parse minimal JSON holds", () {
    expect(Holds(total: null, position: null),
        Holds.fromJSON('{}'.toJsonOrNull()));
  });

  test("parse full JSON holds", () {
    expect(Holds(total: 5, position: 6),
        Holds.fromJSON('{"total": 5, "position": 6}'.toJsonOrNull()));
  });

  test("parse null JSON holds", () {
    expect(Holds.fromJSON(null), equals(null));
  });

  test("parse JSON holds requires positive {total}", () {
    expect(Holds(total: null, position: 6),
        Holds.fromJSON('{"total": -5, "position": 6}'.toJsonOrNull()));
  });

  test("parse JSON holds requires positive {position}", () {
    expect(Holds(total: 5, position: null),
        Holds.fromJSON('{"total": 5, "position": -6}'.toJsonOrNull()));
  });

  test("get minimal JSON holds", () {
    expect('{}'.toJsonOrNull(), Holds(total: null, position: null).toJson());
  });

  test("get full JSON holds", () {
    expect('{"total": 5, "position": 6}'.toJsonOrNull(),
        Holds(total: 5, position: 6).toJson());
  });
}
