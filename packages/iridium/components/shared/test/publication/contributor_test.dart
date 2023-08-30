// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse JSON string", () {
    expect(Contributor(localizedName: LocalizedString.fromString("Thom Yorke")),
        Contributor.fromJson("Thom Yorke"));
  });

  test("parse minimal JSON", () {
    expect(
        Contributor(
            localizedName: LocalizedString.fromString("Colin Greenwood")),
        Contributor.fromJson('{"name": "Colin Greenwood"}'.toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Contributor(
            localizedName: LocalizedString.fromString("Colin Greenwood"),
            localizedSortAs: LocalizedString.fromString("greenwood"),
            identifier: "colin",
            roles: {"bassist"},
            position: 4.0,
            links: [Link(href: "http://link1"), Link(href: "http://link2")]),
        Contributor.fromJson("""{
                "name": "Colin Greenwood",
                "identifier": "colin",
                "sortAs": "greenwood",
                "role": "bassist",
                "position": 4,
                "links": [
                    {"href": "http://link1"},
                    {"href": "http://link2"}
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse JSON with multiple roles", () {
    expect(
        Contributor(
            localizedName: LocalizedString.fromString("Thom Yorke"),
            roles: {"singer", "guitarist"}),
        Contributor.fromJson("""{
                "name": "Thom Yorke",
                "role": ["singer", "guitarist", "guitarist"]
            }"""
            .toJsonOrNull()));
  });

  test("parse null JSON", () {
    expect(Contributor.fromJson(null), isNull);
  });

  test("parse requires {name}", () {
    expect(Contributor.fromJson('{"identifier": "c1"}'.toJsonOrNull()), isNull);
  });

  test("parse JSON array", () {
    expect(
        [
          Contributor(localizedName: LocalizedString.fromString("Thom Yorke")),
          Contributor(
              localizedName: LocalizedString.fromStrings(
                  {"en": "Jonny Greenwood", "fr": "Jean Boisvert"}),
              roles: {"guitarist"})
        ],
        Contributor.fromJsonArray("""[
                "Thom Yorke",
                {
                    "name": {"en": "Jonny Greenwood", "fr": "Jean Boisvert"},
                    "role": "guitarist"
                }
            ]"""
            .toJsonArrayOrNull()));
  });

  test("parse null JSON array", () {
    expect(0, Contributor.fromJsonArray(null).length);
  });

  test("parse JSON array ignores invalid contributors", () {
    expect(
        [Contributor(localizedName: LocalizedString.fromString("Thom Yorke"))],
        Contributor.fromJsonArray("""[
                "Thom Yorke",
                {
                    "role": "guitarist"
                }
            ]"""
            .toJsonArrayOrNull()));
  });

  test("parse array from string", () {
    expect(
        [Contributor(localizedName: LocalizedString.fromString("Thom Yorke"))],
        Contributor.fromJsonArray("Thom Yorke"));
  });

  test("parse array from single object", () {
    expect(
        [
          Contributor(
              localizedName: LocalizedString.fromStrings(
                  {"en": "Jonny Greenwood", "fr": "Jean Boisvert"}),
              roles: {"guitarist"})
        ],
        Contributor.fromJsonArray("""{
                "name": {"en": "Jonny Greenwood", "fr": "Jean Boisvert"},
                "role": "guitarist"
            }"""
            .toJsonOrNull()));
  });

  test("get name from the default translation", () {
    expect(
        "Jonny Greenwood",
        Contributor(
            localizedName: LocalizedString.fromStrings(
                {"en": "Jonny Greenwood", "fr": "Jean Boisvert"})).name);
  });

  test("get minimal JSON", () {
    expect(
        '{"name": {"und": "Colin Greenwood"}}'.toJsonOrNull(),
        Contributor(
                localizedName: LocalizedString.fromString("Colin Greenwood"))
            .toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "name": {"und": "Colin Greenwood"},
                "identifier": "colin",
                "sortAs": {"und": "greenwood"},
                "role": ["bassist"],
                "position": 4.0,
                "links": [
                    {"href": "http://link1", "templated": false},
                    {"href": "http://link2", "templated": false}
                ]
            }"""
            .toJsonOrNull(),
        Contributor(
                localizedName: LocalizedString.fromString("Colin Greenwood"),
                localizedSortAs: LocalizedString.fromString("greenwood"),
                identifier: "colin",
                roles: {"bassist"},
                position: 4.0,
                links: [Link(href: "http://link1"), Link(href: "http://link2")])
            .toJson());
  });

  test("get JSON array", () {
    expect(
        """[
                {
                    "name": {"und": "Thom Yorke"}
                },
                {
                    "name": {"en": "Jonny Greenwood", "fr": "Jean Boisvert"},
                    "role": ["guitarist"]
                }
            ]"""
            .toJsonArrayOrNull(),
        [
          Contributor(localizedName: LocalizedString.fromString("Thom Yorke")),
          Contributor(
              localizedName: LocalizedString.fromStrings(
                  {"en": "Jonny Greenwood", "fr": "Jean Boisvert"}),
              roles: {"guitarist"})
        ].toJson());
  });
}
