// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse JSON string", () {
    expect(Subject(localizedName: LocalizedString.fromString("Fantasy")),
        Subject.fromJson("Fantasy"));
  });

  test("parse minimal JSON", () {
    expect(
        Subject(localizedName: LocalizedString.fromString("Science Fiction")),
        Subject.fromJson('{"name": "Science Fiction"}'.toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Subject(
            localizedName: LocalizedString.fromString("Science Fiction"),
            localizedSortAs: LocalizedString.fromString("science-fiction"),
            scheme: "http://scheme",
            code: "CODE",
            links: [Link(href: "pub1"), Link(href: "pub2")]),
        Subject.fromJson("""{
                "name": "Science Fiction",
                "sortAs": "science-fiction",
                "scheme": "http://scheme",
                "code": "CODE",
                "links": [
                    {"href": "pub1"},
                    {"href": "pub2"}
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse null JSON", () {
    expect(Subject.fromJson(null), isNull);
  });

  test("parse requires {name}", () {
    expect(Subject.fromJson('{"sortAs": "science-fiction"}'.toJsonOrNull()),
        isNull);
  });

  test("parse JSON array", () {
    expect(
        [
          Subject(localizedName: LocalizedString.fromString("Fantasy")),
          Subject(
              localizedName: LocalizedString.fromString("Science Fiction"),
              scheme: "http://scheme")
        ],
        Subject.fromJSONArray("""[
                "Fantasy",
                {
                    "name": "Science Fiction",
                    "scheme": "http://scheme"
                }
            ]"""
            .toJsonArrayOrNull()));
  });

  test("parse null JSON array", () {
    expect(0, Subject.fromJSONArray(null).length);
  });

  test("parse JSON array ignores invalid subjects", () {
    expect(
        [Subject(localizedName: LocalizedString.fromString("Fantasy"))],
        Subject.fromJSONArray("""[
                "Fantasy",
                {
                    "code": "CODE"
                }
            ]"""
            .toJsonArrayOrNull()));
  });

  test("parse array from string", () {
    expect([Subject(localizedName: LocalizedString.fromString("Fantasy"))],
        Subject.fromJSONArray("Fantasy"));
  });

  test("parse array from single object", () {
    expect(
        [
          Subject(
              localizedName: LocalizedString.fromString("Fantasy"),
              code: "CODE")
        ],
        Subject.fromJSONArray("""{
                "name": "Fantasy",
                "code": "CODE"
            }"""
            .toJsonOrNull()));
  });

  test("get name from the default translation", () {
    expect(
        "Hello world",
        Subject(
            localizedName: LocalizedString.fromStrings(
                {"en": "Hello world", "fr": "Salut le monde"})).name);
  });

  test("get minimal JSON", () {
    expect(
        '{"name": {"und": "Science Fiction"}}'.toJsonOrNull(),
        Subject(localizedName: LocalizedString.fromString("Science Fiction"))
            .toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "name": {"und": "Science Fiction"},
                "sortAs": {"und": "science-fiction"},
                "scheme": "http://scheme",
                "code": "CODE",
                "links": [
                    {"href": "pub1", "templated": false},
                    {"href": "pub2", "templated": false}
                ]
            }"""
            .toJsonOrNull(),
        Subject(
            localizedName: LocalizedString.fromString("Science Fiction"),
            localizedSortAs: LocalizedString.fromString("science-fiction"),
            scheme: "http://scheme",
            code: "CODE",
            links: [Link(href: "pub1"), Link(href: "pub2")]).toJson());
  });

  test("get JSON array", () {
    expect(
        """[
                {
                    "name": {"und": "Fantasy"}
                },
                {
                    "name": {"und": "Science Fiction"},
                    "scheme": "http://scheme"
                }
            ]"""
            .toJsonArrayOrNull(),
        [
          Subject(localizedName: LocalizedString.fromString("Fantasy")),
          Subject(
              localizedName: LocalizedString.fromString("Science Fiction"),
              scheme: "http://scheme")
        ].toJson());
  });
}
