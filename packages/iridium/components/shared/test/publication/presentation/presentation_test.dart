// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse null JSON", () {
    expect(Presentation(), Presentation.fromJson(null));
  });

  test("parse minimal JSON", () {
    expect(
        Presentation(
            clipped: null,
            continuous: null,
            fit: null,
            orientation: null,
            overflow: null,
            spread: null,
            layout: null),
        Presentation.fromJson("{}".toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Presentation(
            clipped: true,
            continuous: false,
            fit: PresentationFit.cover,
            orientation: PresentationOrientation.landscape,
            overflow: PresentationOverflow.paginated,
            spread: PresentationSpread.both,
            layout: EpubLayout.fixed),
        Presentation.fromJson("""{
                "clipped": true,
                "continuous": false,
                "fit": "cover",
                "orientation": "landscape",
                "overflow": "paginated",
                "spread": "both",
                "layout": "fixed"
            }"""
            .toJsonOrNull()));
  });

  test("get minimal JSON", () {
    expect("{}".toJsonOrNull(), Presentation().toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "clipped": true,
                "continuous": false,
                "fit": "cover",
                "orientation": "landscape",
                "overflow": "paginated",
                "spread": "both",
                "layout": "fixed"
            }"""
            .toJsonOrNull(),
        Presentation(
                clipped: true,
                continuous: false,
                fit: PresentationFit.cover,
                orientation: PresentationOrientation.landscape,
                overflow: PresentationOverflow.paginated,
                spread: PresentationSpread.both,
                layout: EpubLayout.fixed)
            .toJson());
  });

  test("parse fit from JSON value", () {
    expect(PresentationFit.width, PresentationFit.from("width"));
    expect(PresentationFit.height, PresentationFit.from("height"));
    expect(PresentationFit.contain, PresentationFit.from("contain"));
    expect(PresentationFit.cover, PresentationFit.from("cover"));
    expect(PresentationFit.from("foobar"), isNull);
    expect(PresentationFit.from(null), isNull);
  });

  test("get fit JSON value", () {
    expect("width", PresentationFit.width.value);
    expect("height", PresentationFit.height.value);
    expect("contain", PresentationFit.contain.value);
    expect("cover", PresentationFit.cover.value);
  });

  test("parse orientation from JSON value", () {
    expect(PresentationOrientation.auto, PresentationOrientation.from("auto"));
    expect(PresentationOrientation.landscape,
        PresentationOrientation.from("landscape"));
    expect(PresentationOrientation.portrait,
        PresentationOrientation.from("portrait"));
    expect(PresentationOrientation.from("foobar"), isNull);
    expect(PresentationOrientation.from(null), isNull);
  });

  test("get orientation JSON value", () {
    expect("auto", PresentationOrientation.auto.value);
    expect("landscape", PresentationOrientation.landscape.value);
    expect("portrait", PresentationOrientation.portrait.value);
  });

  test("parse overflow from JSON value", () {
    expect(PresentationOverflow.auto, PresentationOverflow.from("auto"));
    expect(
        PresentationOverflow.paginated, PresentationOverflow.from("paginated"));
    expect(
        PresentationOverflow.scrolled, PresentationOverflow.from("scrolled"));
    expect(PresentationOverflow.from("foobar"), isNull);
    expect(PresentationOverflow.from(null), isNull);
  });

  test("get overflow JSON value", () {
    expect("auto", PresentationOverflow.auto.value);
    expect("paginated", PresentationOverflow.paginated.value);
    expect("scrolled", PresentationOverflow.scrolled.value);
  });

  test("parse page from JSON value", () {
    expect(PresentationPage.left, PresentationPage.from("left"));
    expect(PresentationPage.right, PresentationPage.from("right"));
    expect(PresentationPage.center, PresentationPage.from("center"));
    expect(PresentationPage.from("foobar"), isNull);
    expect(PresentationPage.from(null), isNull);
  });

  test("get page JSON value", () {
    expect("left", PresentationPage.left.value);
    expect("right", PresentationPage.right.value);
    expect("center", PresentationPage.center.value);
  });

  test("parse spread from JSON value", () {
    expect(PresentationSpread.auto, PresentationSpread.from("auto"));
    expect(PresentationSpread.both, PresentationSpread.from("both"));
    expect(PresentationSpread.none, PresentationSpread.from("none"));
    expect(PresentationSpread.landscape, PresentationSpread.from("landscape"));
    expect(PresentationSpread.from("foobar"), isNull);
    expect(PresentationSpread.from(null), isNull);
  });

  test("get spread JSON value", () {
    expect("auto", PresentationSpread.auto.value);
    expect("both", PresentationSpread.both.value);
    expect("none", PresentationSpread.none.value);
    expect("landscape", PresentationSpread.landscape.value);
  });
}
