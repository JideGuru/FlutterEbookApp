// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/publication/html/dom_range.dart';
import 'package:mno_shared/src/publication/html/locator.dart';
import 'package:test/test.dart';

void main() {
  test("get Locations {cssSelector} when available", () {
    expect("p", Locations(otherLocations: {"cssSelector": "p"}).cssSelector);
  });

  test("get Locations {cssSelector} when missing", () {
    expect(Locations().cssSelector, isNull);
  });

  test("get Locations {partialCfi} when available", () {
    expect("epubcfi(/4)",
        Locations(otherLocations: {"partialCfi": "epubcfi(/4)"}).partialCfi);
  });

  test("get Locations {partialCfi} when missing", () {
    expect(Locations().partialCfi, isNull);
  });

  test("get Locations {domRange} when available", () {
    expect(
        DomRange(start: Point(cssSelector: "p", textNodeIndex: 4)),
        Locations(otherLocations: {
          "domRange": {
            "start": {"cssSelector": "p", "textNodeIndex": 4}
          }
        }).domRange);
  });

  test("get Locations {domRange} when missing", () {
    expect(Locations().domRange, isNull);
  });
}
