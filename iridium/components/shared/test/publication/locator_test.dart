// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse {Locator} minimal JSON", () {
    expect(
        Locator(href: "http://locator", type: "text/html"),
        Locator.fromJson("""{
                "href": "http://locator",
                "type": "text/html"
            }"""
            .toJsonOrNull()));
  });

  test("parse {Locator} full JSON", () {
    expect(
        Locator(
            href: "http://locator",
            type: "text/html",
            title: "My Locator",
            locations: Locations(position: 42),
            text: LocatorText(highlight: "Excerpt")),
        Locator.fromJson("""{
                "href": "http://locator",
                "type": "text/html",
                "title": "My Locator",
                "locations": {
                    "position": 42
                },
                "text": {
                    "highlight": "Excerpt"
                }
            }"""
            .toJsonOrNull()));
  });

  test("parse {Locator} null JSON", () {
    expect(null, Locator.fromJson(null));
  });

  test("parse {Locator} invalid JSON", () {
    expect(Locator.fromJson('{ "invalid": "object" }'.toJsonOrNull()), isNull);
  });

  test("create {Locator} from minimal {Link}", () {
    expect(Locator(href: "http://locator", type: ""),
        Link(href: "http://locator").toLocator());
  });

  test("create {Locator} from full {Link} with fragment", () {
    expect(
        Locator(
            href: "http://locator",
            type: "text/html",
            title: "My Link",
            locations: Locations(fragments: ["page=42"])),
        Link(
                href: "http://locator#page=42",
                type: "text/html",
                title: "My Link")
            .toLocator());
  });

  test("get {Locator} minimal JSON", () {
    expect(
        """{
                "href": "http://locator",
                "type": "text/html"
            }"""
            .toJsonOrNull(),
        Locator(href: "http://locator", type: "text/html").toJson());
  });

  test("get {Locator} full JSON", () {
    expect(
        """{
                "href": "http://locator",
                "type": "text/html",
                "title": "My Locator",
                "locations": {
                    "position": 42
                },
                "text": {
                    "highlight": "Excerpt"
                }
            }"""
            .toJsonOrNull(),
        Locator(
                href: "http://locator",
                type: "text/html",
                title: "My Locator",
                locations: Locations(position: 42),
                text: LocatorText(highlight: "Excerpt"))
            .toJson());
  });

  test("copy a {Locator} with different {Locations} sub-properties", () {
    expect(
        Locator(
            href: "http://locator",
            type: "text/html",
            locations: Locations(
                fragments: ["p=4", "frag34"],
                progression: 0.74,
                position: 42,
                totalProgression: 0.32,
                otherLocations: {"other": "other-location"})),
        Locator(
                href: "http://locator",
                type: "text/html",
                locations: Locations(position: 42, progression: 2.0))
            .copyWithLocations(
                fragments: ["p=4", "frag34"],
                progression: 0.74,
                position: 42,
                totalProgression: 0.32,
                otherLocations: {"other": "other-location"}));
  });

  test("copy a {Locator} with reset {Locations} sub-properties", () {
    expect(
        Locator(
            href: "http://locator", type: "text/html", locations: Locations()),
        Locator(
                href: "http://locator",
                type: "text/html",
                locations: Locations(position: 42, progression: 2.0))
            .copyWithLocations(
                fragments: [],
                progression: null,
                position: null,
                totalProgression: null,
                otherLocations: {}));
  });

  test("parse {Locations} minimal JSON", () {
    expect(Locations(), Locations.fromJson("{}".toJsonOrNull()));
  });

  test("parse {Locations} full JSON", () {
    expect(
        Locations(
            fragments: ["p=4", "frag34"],
            progression: 0.74,
            position: 42,
            totalProgression: 0.32,
            otherLocations: {"other": "other-location"}),
        Locations.fromJson("""{
                "fragments": ["p=4", "frag34"],
                "progression": 0.74,
                "totalProgression": 0.32,
                "position": 42,
                "other": "other-location"
            }"""
            .toJsonOrNull()));
  });

  test("parse {Locations} null JSON", () {
    expect(Locations(), Locations.fromJson(null));
  });

  test("parse {Locations} single fragment JSON", () {
    expect(Locations(fragments: ["frag34"]),
        Locations.fromJson('{ "fragment": "frag34" }'.toJsonOrNull()));
  });

  test("parse {Locations} ignores {position} smaller than 1", () {
    expect(Locations(position: 1),
        Locations.fromJson('{ "position": 1 }'.toJsonOrNull()));
    expect(Locations(), Locations.fromJson('{ "position": 0 }'.toJsonOrNull()));
    expect(
        Locations(), Locations.fromJson('{ "position": -1 }'.toJsonOrNull()));
  });

  test("parse {Locations} ignores {progression} outside of 0-1 range", () {
    expect(Locations(progression: 0.5),
        Locations.fromJson('{ "progression": 0.5 }'.toJsonOrNull()));
    expect(Locations(progression: 0.0),
        Locations.fromJson('{ "progression": 0 }'.toJsonOrNull()));
    expect(Locations(progression: 1.0),
        Locations.fromJson('{ "progression": 1 }'.toJsonOrNull()));
    expect(Locations(),
        Locations.fromJson('{ "progression": -0.5 }'.toJsonOrNull()));
    expect(Locations(),
        Locations.fromJson('{ "progression": 1.2 }'.toJsonOrNull()));
  });

  test("parse {Locations} ignores {totalProgression} outside of 0-1 range", () {
    expect(Locations(totalProgression: 0.5),
        Locations.fromJson('{ "totalProgression": 0.5 }'.toJsonOrNull()));
    expect(Locations(totalProgression: 0.0),
        Locations.fromJson('{ "totalProgression": 0 }'.toJsonOrNull()));
    expect(Locations(totalProgression: 1.0),
        Locations.fromJson('{ "totalProgression": 1 }'.toJsonOrNull()));
    expect(Locations(),
        Locations.fromJson('{ "totalProgression": -0.5 }'.toJsonOrNull()));
    expect(Locations(),
        Locations.fromJson('{ "totalProgression": 1.2 }'.toJsonOrNull()));
  });

  test("get {Locations} minimal JSON", () {
    expect("{}".toJsonOrNull(), Locations().toJson());
  });

  test("get {Locations} full JSON", () {
    expect(
        """{
                "fragments": ["p=4", "frag34"],
                "progression": 0.74,
                "totalProgression": 25.32,
                "position": 42,
                "other": "other-location"
            }"""
            .toJsonOrNull(),
        Locations(
            fragments: ["p=4", "frag34"],
            progression: 0.74,
            position: 42,
            totalProgression: 25.32,
            otherLocations: {"other": "other-location"}).toJson());
  });

  test("parse {Text} minimal JSON", () {
    expect(LocatorText(), LocatorText.fromJson("{}".toJsonOrNull()));
  });

  test("parse {Text} full JSON", () {
    expect(
        LocatorText(
            before: "Text before",
            highlight: "Highlighted text",
            after: "Text after"),
        LocatorText.fromJson("""{
                "before": "Text before",
                "highlight": "Highlighted text",
                "after": "Text after"
            }"""
            .toJsonOrNull()));
  });

  test("parse {Text} null JSON", () {
    expect(LocatorText(), LocatorText.fromJson(null));
  });

  test("get {Text} minimal JSON", () {
    expect("{}".toJsonOrNull(), LocatorText().toJson());
  });

  test("get {Text} full JSON", () {
    expect(
        """{
                "before": "Text before",
                "highlight": "Highlighted text",
                "after": "Text after"
            }"""
            .toJsonOrNull(),
        LocatorText(
                before: "Text before",
                highlight: "Highlighted text",
                after: "Text after")
            .toJson());
  });
}
