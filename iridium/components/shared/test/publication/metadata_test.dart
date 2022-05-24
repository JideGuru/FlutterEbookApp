// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  Metadata createMetadata(
          {required List<String> languages,
          required ReadingProgression readingProgression}) =>
      Metadata(
          localizedTitle: LocalizedString.fromString("Title"),
          languages: languages,
          readingProgression: readingProgression);

  test("parse minimal JSON", () {
    expect(Metadata(localizedTitle: LocalizedString.fromString("Title")),
        Metadata.fromJson('{"title": "Title"}'.toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Metadata(
            identifier: "1234",
            type: "epub",
            localizedTitle:
                LocalizedString.fromStrings({"en": "Title", "fr": "Titre"}),
            localizedSubtitle: LocalizedString.fromStrings(
                {"en": "Subtitle", "fr": "Sous-titre"}),
            modified: "2001-01-01T12:36:27.000Z".iso8601ToDate(),
            published: "2001-01-02T12:36:27.000Z".iso8601ToDate(),
            languages: ["en", "fr"],
            localizedSortAs: LocalizedString.fromString("sort key"),
            subjects: [
              Subject.fromString("Science Fiction"),
              Subject.fromString("Fantasy")
            ],
            authors: [Contributor.fromString("Author")],
            translators: [Contributor.fromString("Translator")],
            editors: [Contributor.fromString("Editor")],
            artists: [Contributor.fromString("Artist")],
            illustrators: [Contributor.fromString("Illustrator")],
            letterers: [Contributor.fromString("Letterer")],
            pencilers: [Contributor.fromString("Penciler")],
            colorists: [Contributor.fromString("Colorist")],
            inkers: [Contributor.fromString("Inker")],
            narrators: [Contributor.fromString("Narrator")],
            contributors: [Contributor.fromString("Contributor")],
            publishers: [Contributor.fromString("Publisher")],
            imprints: [Contributor.fromString("Imprint")],
            readingProgression: ReadingProgression.rtl,
            description: "Description",
            duration: 4.24,
            numberOfPages: 240,
            belongsTo: {
              "schema:Periodical": [Contributor.fromString("Periodical")],
              "schema:Newspaper": [
                Contributor.fromString("Newspaper 1"),
                Contributor.fromString("Newspaper 2")
              ]
            },
            belongsToCollections: [Contributor.fromString("Collection")],
            belongsToSeries: [Contributor.fromString("Series")],
            otherMetadata: {
              "other-metadata1": "value",
              "other-metadata2": [42]
            }),
        Metadata.fromJson("""{
                "identifier": "1234",
                "@type": "epub",
                "title": {"en": "Title", "fr": "Titre"},
                "subtitle": {"en": "Subtitle", "fr": "Sous-titre"},
                "modified": "2001-01-01T12:36:27.000Z",
                "published": "2001-01-02T12:36:27.000Z",
                "language": ["en", "fr"],
                "sortAs": "sort key",
                "subject": ["Science Fiction", "Fantasy"],
                "author": "Author",
                "translator": "Translator",
                "editor": "Editor",
                "artist": "Artist",
                "illustrator": "Illustrator",
                "letterer": "Letterer", 
                "penciler": "Penciler",
                "colorist": "Colorist",
                "inker": "Inker",
                "narrator": "Narrator",
                "contributor": "Contributor",
                "publisher": "Publisher",
                "imprint": "Imprint",
                "readingProgression": "rtl",
                "description": "Description",
                "duration": 4.24,
                "numberOfPages": 240,
                "belongsTo": {
                    "collection": "Collection",
                    "series": "Series",
                    "schema:Periodical": "Periodical",
                    "schema:Newspaper": [ "Newspaper 1", "Newspaper 2" ]
                },
                "other-metadata1": "value",
                "other-metadata2": [42]
            }"""
            .toJsonOrNull()));
  });

  test("parse null JSON", () {
    expect(Metadata.fromJson(null), isNull);
  });

  test("parse JSON with single language", () {
    expect(
        Metadata(
            localizedTitle: LocalizedString.fromString("Title"),
            languages: ["fr"]),
        Metadata.fromJson("""{
                "title": "Title",
                "language": "fr"
            }"""
            .toJsonOrNull()));
  });

  test("parse JSON requires {title}", () {
    expect(Metadata.fromJson('{"duration": 4.24}'.toJsonOrNull()), isNull);
  });

  test("parse JSON {duration} requires positive", () {
    expect(Metadata(localizedTitle: LocalizedString.fromString("t")),
        Metadata.fromJson('{"title": "t", "duration": -20}'.toJsonOrNull()));
  });

  test("parse JSON {numberOfPages} requires positive", () {
    expect(
        Metadata(localizedTitle: LocalizedString.fromString("t")),
        Metadata.fromJson(
            '{"title": "t", "numberOfPages": -20}'.toJsonOrNull()));
  });

  test("get minimal JSON", () {
    expect(
        """{
                "title": {"und": "Title"},
                "readingProgression": "auto"
            }"""
            .toJsonOrNull(),
        Metadata(localizedTitle: LocalizedString.fromString("Title")).toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "identifier": "1234",
                "@type": "epub",
                "title": {"en": "Title", "fr": "Titre"},
                "subtitle": {"en": "Subtitle", "fr": "Sous-titre"},
                "modified": "2001-01-01T12:36:27.000Z",
                "published": "2001-01-02T12:36:27.000Z",
                "language": ["en", "fr"],
                "sortAs": {"en": "sort key", "fr": "clé de tri"},
                "subject": [
                    {"name": {"und": "Science Fiction"}},
                    {"name": {"und": "Fantasy"}}
                ],
                "author": [{"name": {"und": "Author"}}],
                "translator": [{"name": {"und": "Translator"}}],
                "editor": [{"name": {"und": "Editor"}}],
                "artist": [{"name": {"und": "Artist"}}],
                "illustrator": [{"name": {"und": "Illustrator"}}],
                "letterer": [{"name": {"und": "Letterer"}}],
                "penciler": [{"name": {"und": "Penciler"}}],
                "colorist": [{"name": {"und": "Colorist"}}],
                "inker": [{"name": {"und": "Inker"}}],
                "narrator": [{"name": {"und": "Narrator"}}],
                "contributor": [{"name": {"und": "Contributor"}}],
                "publisher": [{"name": {"und": "Publisher"}}],
                "imprint": [{"name": {"und": "Imprint"}}],
                "readingProgression": "rtl",
                "description": "Description",
                "duration": 4.24,
                "numberOfPages": 240,
                "belongsTo": {
                    "collection": [{"name": {"und": "Collection"}}],
                    "series": [{"name": {"und": "Series"}}],
                    "schema:Periodical": [{"name": {"und": "Periodical"}}]
                },
                "other-metadata1": "value",
                "other-metadata2": [42]
            }"""
            .toJsonOrNull(),
        Metadata(
            identifier: "1234",
            type: "epub",
            localizedTitle:
                LocalizedString.fromStrings({"en": "Title", "fr": "Titre"}),
            localizedSubtitle: LocalizedString.fromStrings(
                {"en": "Subtitle", "fr": "Sous-titre"}),
            modified: "2001-01-01T12:36:27.000Z".iso8601ToDate(),
            published: "2001-01-02T12:36:27.000Z".iso8601ToDate(),
            languages: ["en", "fr"],
            localizedSortAs: LocalizedString.fromStrings(
                {"en": "sort key", "fr": "clé de tri"}),
            subjects: [
              Subject.fromString("Science Fiction"),
              Subject.fromString("Fantasy")
            ],
            authors: [Contributor.fromString("Author")],
            translators: [Contributor.fromString("Translator")],
            editors: [Contributor.fromString("Editor")],
            artists: [Contributor.fromString("Artist")],
            illustrators: [Contributor.fromString("Illustrator")],
            letterers: [Contributor.fromString("Letterer")],
            pencilers: [Contributor.fromString("Penciler")],
            colorists: [Contributor.fromString("Colorist")],
            inkers: [Contributor.fromString("Inker")],
            narrators: [Contributor.fromString("Narrator")],
            contributors: [Contributor.fromString("Contributor")],
            publishers: [Contributor.fromString("Publisher")],
            imprints: [Contributor.fromString("Imprint")],
            readingProgression: ReadingProgression.rtl,
            description: "Description",
            duration: 4.24,
            numberOfPages: 240,
            belongsTo: {
              "schema:Periodical": [Contributor.fromString("Periodical")]
            },
            belongsToCollections: [Contributor.fromString("Collection")],
            belongsToSeries: [Contributor.fromString("Series")],
            otherMetadata: {
              "other-metadata1": "value",
              "other-metadata2": [42]
            }).toJson());
  });

  test("effectiveReadingProgression falls back on LTR", () {
    var metadata = createMetadata(
        languages: [], readingProgression: ReadingProgression.auto);
    expect(ReadingProgression.ltr, metadata.effectiveReadingProgression);
  });

  test("effectiveReadingProgression falls back on priveded reading progression",
      () {
    var metadata = createMetadata(
        languages: [], readingProgression: ReadingProgression.rtl);
    expect(ReadingProgression.rtl, metadata.effectiveReadingProgression);
  });

  test("effectiveReadingProgression with RTL languages", () {
    expect(
        ReadingProgression.rtl,
        createMetadata(
                languages: ["zh-Hant"],
                readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
    expect(
        ReadingProgression.rtl,
        createMetadata(
                languages: ["zh-TW"],
                readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
    expect(
        ReadingProgression.rtl,
        createMetadata(
                languages: ["ar"], readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
    expect(
        ReadingProgression.rtl,
        createMetadata(
                languages: ["fa"], readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
    expect(
        ReadingProgression.rtl,
        createMetadata(
                languages: ["he"], readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
    expect(
        ReadingProgression.ltr,
        createMetadata(
                languages: ["he"], readingProgression: ReadingProgression.ltr)
            .effectiveReadingProgression);
  });

  test("effectiveReadingProgression ignores multiple languages", () {
    expect(
        ReadingProgression.ltr,
        createMetadata(
                languages: ["ar", "fa"],
                readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
  });

  test("effectiveReadingProgression ignores language case", () {
    expect(
        ReadingProgression.rtl,
        createMetadata(
                languages: ["AR"], readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
  });

  test(
      "effectiveReadingProgression ignores language region, except for Chinese",
      () {
    expect(
        ReadingProgression.rtl,
        createMetadata(
                languages: ["ar-foo"],
                readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
    // But not for ZH
    expect(
        ReadingProgression.ltr,
        createMetadata(
                languages: ["zh-foo"],
                readingProgression: ReadingProgression.auto)
            .effectiveReadingProgression);
  });
}
