// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_streamer/src/epub/property_data_type.dart';
import 'package:test/test.dart';

void main() {
  group("ParsePrefixesTest", () {
    test("A single prefix is rightly parsed", () {
      var prefixes = parsePrefixes("foaf: http://xmlns.com/foaf/spec/");
      expect(prefixes, containsPair("foaf", "http://xmlns.com/foaf/spec/"));
      expect(prefixes.length, 1);
    });

    test("Space between prefixes and iris can be ommited", () {
      var prefixes = parsePrefixes(
          "foaf: http://xmlns.com/foaf/spec/ dbp:http://dbpedia.org/ontology/");
      expect(prefixes, {
        "foaf": "http://xmlns.com/foaf/spec/",
        "dbp": "http://dbpedia.org/ontology/"
      });
      expect(prefixes.length, 2);
    });

    test("Multiple prefixes are rightly parsed", () {
      var prefixes = parsePrefixes(
          "foaf: http://xmlns.com/foaf/spec/ dbp: http://dbpedia.org/ontology/");
      expect(prefixes, {
        "foaf": "http://xmlns.com/foaf/spec/",
        "dbp": "http://dbpedia.org/ontology/"
      });
      expect(prefixes.length, 2);
    });

    group("Different prefixes can be separated by new lines", () {
      test("Multiple prefixes are rightly parsed", () {
        var prefixes = parsePrefixes("""foaf: http://xmlns.com/foaf/spec/
                dbp: http://dbpedia.org/ontology/""");
        expect(prefixes, {
          "foaf": "http://xmlns.com/foaf/spec/",
          "dbp": "http://dbpedia.org/ontology/"
        });
        expect(prefixes.length, 2);
      });
    });

    test("Empty string is rightly handled", () {
      expect(parsePrefixes(""), isEmpty);
    });
  });
  group("TestResolveProperty", () {
    test("Default vocabularies are used", () {
      expect(
          resolveProperty("nav", packageReservedPrefixes,
              defaultVocab: DefaultVocab.item),
          "http://idpf.org/epub/vocab/package/item/#nav");
    });

    test("The prefix map has highest priority", () {
      expect(
          resolveProperty("media:narrator", packageReservedPrefixes,
              defaultVocab: DefaultVocab.meta),
          "http://www.idpf.org/epub/vocab/overlays/#narrator");
    });
  });
  group("ParsePropertiesTest", () {
    test("Various white spaces are accepted", () {
      var properties = """
            rendition:flow-auto        rendition:layout-pre-paginated             
                 rendition:orientation-auto
        """;
      expect(
          parseProperties(properties),
          containsAll([
            "rendition:flow-auto",
            "rendition:layout-pre-paginated",
            "rendition:orientation-auto"
          ]));
    });

    test("Empty string is rightly handled", () {
      expect(parseProperties(""), isEmpty);
    });
  });
}
