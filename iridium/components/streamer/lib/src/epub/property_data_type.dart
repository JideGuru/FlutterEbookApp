// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_streamer/src/epub/constants.dart';

/// Package reserved prefixes.
const Map<String, String> packageReservedPrefixes = {
  "dcterms": Vocabularies.dcterms,
  "media": Vocabularies.media,
  "rendition": Vocabularies.rendition,
  "a11y": Vocabularies.a11y,
  "marc": Vocabularies.marc,
  "onix": Vocabularies.onix,
  "schema": Vocabularies.schema,
  "xsd": Vocabularies.xsd
};

/// Content reserved prefixes.
const Map<String, String> contentReservedPrefixes = {
  "msv": Vocabularies.msv,
  "prism": Vocabularies.prism
};

/// Default vocab.
class DefaultVocab {
  static const DefaultVocab meta = DefaultVocab._(Vocabularies.meta);
  static const DefaultVocab link = DefaultVocab._(Vocabularies.link);
  static const DefaultVocab item = DefaultVocab._(Vocabularies.item);
  static const DefaultVocab itemref = DefaultVocab._(Vocabularies.itemref);
  static const DefaultVocab type = DefaultVocab._(Vocabularies.type);
  final String iri;

  const DefaultVocab._(this.iri);
}

String resolveProperty(String property, Map<String, String> prefixMap,
    {DefaultVocab? defaultVocab}) {
  List<String> splitted =
      property.split(":").where((it) => it.isNotEmpty).toList();
  if (splitted.length == 1 && defaultVocab != null) {
    return defaultVocab.iri + splitted[0];
  } else if (splitted.length == 2 && prefixMap[splitted[0]] != null) {
    return prefixMap[splitted[0]]! + splitted[1];
  } else {
    return property;
  }
}

Map<String, String> parsePrefixes(String prefixes) => Map.fromEntries(
        RegExp("\\s*(\\w+):\\s*(\\S+)").allMatches(prefixes).map((it) {
      String prefixGroup = it.group(1)!;
      String iriGroup = it.group(2)!;
      return MapEntry(prefixGroup, iriGroup);
    }));

List<String> parseProperties(String string) =>
    string.split(RegExp("\\s+")).where((it) => it.isNotEmpty).toList();
