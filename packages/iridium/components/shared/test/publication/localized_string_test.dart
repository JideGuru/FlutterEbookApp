// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;

void main() {
  test("parse JSON string", () {
    expect(LocalizedString.fromString("a string"),
        LocalizedString.fromJson("a string"));
  });

  test("parse JSON localized strings", () {
    expect(
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"}),
        LocalizedString.fromJson("""{
                "en": "a string",
                "fr": "une chaîne"
            }"""
            .toJsonOrNull()));
  });

  test("parse invalid JSON", () {
    expect(LocalizedString.fromJson("[1, 2]".toJsonArrayOrNull()), isNull);
  });

  test("parse null JSON", () {
    expect(LocalizedString.fromJson(null), isNull);
  });

  test("get JSON with one translation and no language", () {
    expect(
        LocalizedString.fromString("a string").toJson(),
        """{
                "und": "a string"
            }"""
            .toJsonOrNull());
  });

  test("get JSON", () {
    expect(
        LocalizedString.fromStrings({
          "en": "a string",
          "fr": "une chaîne",
          LocalizedString.undefinedLanguage: "Surgh"
        }).toJson(),
        """{
                "en": "a string",
                "fr": "une chaîne",
                "und": "Surgh"
            }"""
            .toJsonOrNull());
  });

  test("get the default translation", () {
    expect(
        Translation("a string"),
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"})
            .defaultTranslation);
  });

  test("get the default translation's string", () {
    expect(
        "a string",
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"})
            .string);
  });

  test("find translation by language", () {
    expect(
        Translation("une chaîne"),
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"})
            .getOrFallback("fr"));
  });

  test("find translation by language defaults: the default Locale", () {
    var language = Platform.localeName;
    expect(
        Translation("a string"),
        LocalizedString.fromStrings(
                {language: "a string", "foobar": "une chaîne"})
            .getOrFallback(null));
  });

  test("find translation by language defaults: null", () {
    expect(
        Translation("Surgh"),
        LocalizedString.fromStrings(
                {"foo": "a string", "bar": "une chaîne", null: "Surgh"})
            .getOrFallback(null));
  });

  test("find translation by language defaults: undefined", () {
    expect(
        Translation("Surgh"),
        LocalizedString.fromStrings({
          "foo": "a string",
          "bar": "une chaîne",
          LocalizedString.undefinedLanguage: "Surgh"
        }).getOrFallback(null));
  });

  test("find translation by language defaults: English", () {
    expect(
        Translation("a string"),
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"})
            .getOrFallback(null));
  });

  test("find translation by language defaults: the first found translation",
      () {
    expect(Translation("une chaîne"),
        LocalizedString.fromStrings({"fr": "une chaîne"}).getOrFallback(null));
  });

  test("maps the languages", () {
    expect(
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"}),
        LocalizedString.fromStrings({null: "a string", "fr": "une chaîne"})
            .mapLanguages((language, translation) =>
                (translation.string == "a string") ? "en" : language!));
  });

  test("maps the translations", () {
    expect(
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"}),
        LocalizedString.fromStrings({"en": "Surgh", "fr": "une chaîne"})
            .mapTranslations((language, translation) =>
                (language == "en") ? Translation("a string") : translation));
  });

  test("add or replace a new translation", () {
    expect(
        LocalizedString.fromStrings({"en": "a string", "fr": "une chaîne"}),
        LocalizedString.fromStrings({"en": "a string"})
            .copyWithString("fr", "une chaîne"));
  });
}
