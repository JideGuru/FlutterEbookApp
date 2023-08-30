// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:universal_io/io.dart' hide Link;

class Translation {
  final String string;

  const Translation(this.string);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Translation &&
          runtimeType == other.runtimeType &&
          string == other.string;

  @override
  int get hashCode => string.hashCode;

  @override
  String toString() => string;
}

/// A potentially localized (multilingual) string.
///
/// The translations are indexed by a BCP 47 language tag.
class LocalizedString with EquatableMixin, JSONable {
  /// BCP-47 tag for an undefined language.
  static const String undefinedLanguage = "und";
  LocalizedString._(this.translations);

  static LocalizedString fromStrings(Map<String?, String> strings) =>
      LocalizedString._(
          strings.map((key, value) => MapEntry(key, Translation(value))));

  static LocalizedString fromString(String string) =>
      LocalizedString._({null: Translation(string)});

  /// Parses a [LocalizedString] from its RWPM JSON representation.
  /// If the localized string can't be parsed, a warning will be logged with [warnings].
  ///
  /// "anyOf": [
  ///   {
  ///     "type": "string"
  ///   },
  ///   {
  ///     "description": "The language in a language map must be a valid BCP 47 tag.",
  ///     "type": "object",
  ///     "patternProperties": {
  ///       "^((?<grandfathered>(en-GB-oed|i-ami|i-bnn|i-default|i-enochian|i-hak|i-klingon|i-lux|i-mingo|i-navajo|i-pwn|i-tao|i-tay|i-tsu|sgn-BE-FR|sgn-BE-NL|sgn-CH-DE)|(art-lojban|cel-gaulish|no-bok|no-nyn|zh-guoyu|zh-hakka|zh-min|zh-min-nan|zh-xiang))|((?<language>([A-Za-z]{2,3}(-(?<extlang>[A-Za-z]{3}(-[A-Za-z]{3}){0,2}))?)|[A-Za-z]{4}|[A-Za-z]{5,8})(-(?<script>[A-Za-z]{4}))?(-(?<region>[A-Za-z]{2}|[0-9]{3}))?(-(?<variant>[A-Za-z0-9]{5,8}|[0-9][A-Za-z0-9]{3}))*(-(?<extension>[0-9A-WY-Za-wy-z](-[A-Za-z0-9]{2,8})+))*(-(?<privateUse>x(-[A-Za-z0-9]{1,8})+))?)|(?<privateUse2>x(-[A-Za-z0-9]{1,8})+))$": {
  ///         "type": "string"
  ///       }
  ///     },
  ///     "additionalProperties": false,
  ///     "minProperties": 1
  ///   }
  /// ]
  static LocalizedString? fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    if (json is String) {
      return LocalizedString.fromString(json);
    }
    if (json is Map<String, dynamic>) {
      return LocalizedString._fromJSONObject(json);
    }
    Fimber.i("invalid localized string object");
    return null;
  }

  factory LocalizedString._fromJSONObject(Map<String, dynamic> json) {
    Map<String?, String> translations = {};
    for (String key in json.keys) {
      String? string = json.optNullableString(key);
      if (string == null) {
        Fimber.i("invalid localized string object $json");
      } else {
        translations[key] = string;
      }
    }

    return LocalizedString.fromStrings(translations);
  }

  final Map<String?, Translation> translations;

  /// The default translation for this localized string.
  Translation get defaultTranslation =>
      this.getOrFallback(null) ?? Translation("");

  /// The default translation string for this localized string.
  /// This is a shortcut for apps.
  String get string => defaultTranslation.string;

  /// Returns the first translation for the given [language] BCP–47 tag.
  /// If not found, then fallback:
  ///    1. on the default [Locale]
  ///    2. on the undefined language
  ///    3. on the English language
  ///    4. the first translation found
  Translation? getOrFallback(String? language) =>
      translations[language] ??
      translations[Platform.localeName] ??
      translations[null] ??
      translations[undefinedLanguage] ??
      translations["en"] ??
      translations.keys.firstOrNull?.let((it) => translations[it]);

  /// Returns a new [LocalizedString] after adding (or replacing) the translation with the given
  /// [language].
  LocalizedString copyWithString(String language, String string) => copy(
      translations: Map.from(translations)
        ..putIfAbsent(language, () => Translation(string)));

  /// Returns a new [LocalizedString] after applying the [transform] function to each language.
  LocalizedString mapLanguages(
          String Function(String?, Translation) transform) =>
      copy(
          translations: translations.map((language, translation) =>
              MapEntry(transform(language, translation), translation)));

  /// Returns a new [LocalizedString] after applying the [transform] function to each translation.
  LocalizedString mapTranslations(
          Translation Function(String?, Translation) transform) =>
      copy(
          translations: translations.map((language, translation) =>
              MapEntry(language, transform(language, translation))));

  LocalizedString copy({Map<String?, Translation>? translations}) =>
      LocalizedString._(translations ?? {});

  /// Serializes a [LocalizedString] to its RWPM JSON representation.
  @override
  Map<String, String> toJson() => translations.map((language, translation) =>
      MapEntry(language ?? undefinedLanguage, translation.string));

  @override
  List get props => [translations];

  @override
  String toString() => 'LocalizedString($translations)';
}
