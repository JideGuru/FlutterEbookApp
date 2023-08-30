// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:test/test.dart';

import 'package_document_test.dart';

void main() async {
  group("ContributorParsingTest", () {
    late Metadata epub2Metadata;
    late Metadata epub3Metadata;
    setUp(() async {
      epub2Metadata =
          (await parsePackageDocument("package/contributors-epub2.opf"))
              .metadata;
      epub3Metadata =
          (await parsePackageDocument("package/contributors-epub3.opf"))
              .metadata;
    });

    test("dc_creator is by default an author", () {
      var contributor =
          Contributor(localizedName: LocalizedString.fromString("Author 1"));
      expect(epub2Metadata.authors, contains(contributor));
      expect(epub3Metadata.authors, contains(contributor));
    });

    test("dc_publisher is a publisher", () {
      var contributor =
          Contributor(localizedName: LocalizedString.fromString("Publisher 1"));
      expect(epub2Metadata.publishers, contains(contributor));
      expect(epub3Metadata.publishers, contains(contributor));
    });

    test("dc_contributor is by default a contributor", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromString("Contributor 1"));
      expect(epub2Metadata.contributors, contains(contributor));
      expect(epub3Metadata.contributors, contains(contributor));
    });

    test("Unknown roles are ignored", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromString("Contributor 2"),
          roles: {"unknown"});
      expect(epub2Metadata.contributors, contains(contributor));
      expect(epub3Metadata.contributors, contains(contributor));
    });

    test("file-as is parsed", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromString("Contributor 3"),
          localizedSortAs: LocalizedString.fromString("Sorting Key"));
      expect(epub2Metadata.contributors, contains(contributor));
      expect(epub3Metadata.contributors, contains(contributor));
    });

    test("Localized contributors are rightly parsed (epub3 only)", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromStrings(
              {null: "Contributor 4", "fr": "Contributeur 4 en français"}));
      expect(epub3Metadata.contributors, contains(contributor));
    });

    test("Only the first role is considered (epub3 only)", () {
      var contributor =
          Contributor(localizedName: LocalizedString.fromString("Cameleon"));
      expect(epub3Metadata.authors, contains(contributor));
      expect(epub3Metadata.publishers.contains(contributor), isFalse);
    });

    test("Media Overlays narrators are rightly parsed (epub3 only)", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromString("Media Overlays Narrator"));
      expect(epub3Metadata.narrators, contains(contributor));
    });

    test("Author is rightly parsed", () {
      var contributor =
          Contributor(localizedName: LocalizedString.fromString("Author 2"));
      expect(epub2Metadata.authors, contains(contributor));
      expect(epub3Metadata.authors, contains(contributor));
    });

    test("Publisher is rightly parsed", () {
      var contributor =
          Contributor(localizedName: LocalizedString.fromString("Publisher 2"));
      expect(epub2Metadata.publishers, contains(contributor));
      expect(epub3Metadata.publishers, contains(contributor));
    });

    test("Translator is rightly parsed", () {
      var contributor =
          Contributor(localizedName: LocalizedString.fromString("Translator"));
      expect(epub2Metadata.translators, contains(contributor));
      expect(epub3Metadata.translators, contains(contributor));
    });

    test("Artist is rightly parsed", () {
      var contributor =
          Contributor(localizedName: LocalizedString.fromString("Artist"));
      expect(epub2Metadata.artists, contains(contributor));
      expect(epub3Metadata.artists, contains(contributor));
    });

    test("Illustrator is rightly parsed", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromString("Illustrator"), roles: {});
      expect(epub2Metadata.illustrators, contains(contributor));
      expect(epub3Metadata.illustrators, contains(contributor));
    });

    test("Colorist is rightly parsed", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromString("Colorist"), roles: {});
      expect(epub2Metadata.colorists, contains(contributor));
      expect(epub3Metadata.colorists, contains(contributor));
    });

    test("Narrator is rightly parsed", () {
      var contributor = Contributor(
          localizedName: LocalizedString.fromString("Narrator"), roles: {});
      expect(epub2Metadata.narrators, contains(contributor));
      expect(epub3Metadata.narrators, contains(contributor));
    });

    test("No more contributor than needed", () {
      expect(epub2Metadata.authors.length, 2);
      expect(epub2Metadata.publishers.length, 2);
      expect(epub2Metadata.translators.length, 1);
      expect(epub2Metadata.editors.length, 1);
      expect(epub2Metadata.artists.length, 1);
      expect(epub2Metadata.illustrators.length, 1);
      expect(epub2Metadata.colorists.length, 1);
      expect(epub2Metadata.narrators.length, 1);
      expect(epub2Metadata.contributors.length, 3);

      expect(epub3Metadata.authors.length, 3);
      expect(epub3Metadata.publishers.length, 2);
      expect(epub3Metadata.translators.length, 1);
      expect(epub3Metadata.editors.length, 1);
      expect(epub3Metadata.artists.length, 1);
      expect(epub3Metadata.illustrators.length, 1);
      expect(epub3Metadata.colorists.length, 1);
      expect(epub3Metadata.narrators.length, 2);
      expect(epub3Metadata.contributors.length, 4);
    });
  });
  group("TitleTest", () {
    late Metadata epub2Metadata;
    late Metadata epub3Metadata;
    setUp(() async {
      epub2Metadata =
          (await parsePackageDocument("package/titles-epub2.opf")).metadata;
      epub3Metadata =
          (await parsePackageDocument("package/titles-epub3.opf")).metadata;
    });

    test("Title is rightly parsed", () {
      expect(epub2Metadata.localizedTitle,
          LocalizedString.fromString("Alice's Adventures in Wonderland"));
      expect(
          epub3Metadata.localizedTitle,
          LocalizedString.fromStrings({
            null: "Alice's Adventures in Wonderland",
            "fr": "Les Aventures d'Alice au pays des merveilles"
          }));
    });

    test("Subtitle is rightly parsed (epub3 only)", () {
      expect(
          epub3Metadata.localizedSubtitle,
          LocalizedString.fromStrings({
            "en-GB":
                "Alice returns to the magical world from her childhood adventure",
            "fr":
                "Alice retourne dans le monde magique des aventures de son enfance"
          }));
    });

    test("file-as is parsed", () {
      expect(epub2Metadata.sortAs, "Adventures");
      expect(epub3Metadata.sortAs, "Adventures");
    });

    test("Main title takes precedence (epub3 only)", () async {
      var metadata =
          (await parsePackageDocument("package/title-main-precedence.opf"))
              .metadata;
      expect(metadata.title, "Main title takes precedence");
    });

    test(
        "The selected subtitle has the lowest display-seq property (epub3 only)",
        () async {
      var metadata =
          (await parsePackageDocument("package/title-multiple-subtitles.opf"))
              .metadata;
      expect(
          metadata.localizedSubtitle, LocalizedString.fromString("Subtitle 2"));
    });
  });
  group("SubjectTest", () {
    late Metadata complexMetadata;
    setUp(() async {
      complexMetadata =
          (await parsePackageDocument("package/subjects-complex.opf")).metadata;
    });

    test("Localized subjects are rightly parsed (epub3 only)", () {
      var subject = complexMetadata.subjects.first;
      expect(subject, isNotNull);
      expect(
          subject.localizedName,
          LocalizedString.fromStrings({
            "en": "FICTION / Occult & Supernatural",
            "fr": "FICTION / Occulte & Surnaturel"
          }));
    });

    test("file-as is rightly parsed (epub3 only)", () {
      var subject = complexMetadata.subjects.first;
      expect(subject, isNotNull);
      expect(subject.sortAs, "occult");
    });

    test("code and scheme are rightly parsed (epub3 only)", () {
      var subject = complexMetadata.subjects.first;
      expect(subject, isNotNull);
      expect(subject.scheme, "BISAC");
      expect(subject.code, "FIC024000");
    });

    test("Comma separated single subject is splitted", () async {
      var subjects = (await parsePackageDocument("package/subjects-single.opf"))
          .metadata
          .subjects;
      expect(
          subjects,
          containsAllInOrder([
            Subject(localizedName: LocalizedString.fromString("apple")),
            Subject(localizedName: LocalizedString.fromString("banana")),
            Subject(localizedName: LocalizedString.fromString("pear"))
          ]));
    });

    test("Comma separated multiple subjects are not splitted", () async {
      var subjects =
          (await parsePackageDocument("package/subjects-multiple.opf"))
              .metadata
              .subjects;
      expect(
          subjects,
          containsAllInOrder([
            Subject(localizedName: LocalizedString.fromString("fiction")),
            Subject(
                localizedName:
                    LocalizedString.fromString("apple; banana,  pear"))
          ]));
    });
  });
  group("DateTest", () {
    late Metadata epub2Metadata;
    late Metadata epub3Metadata;
    setUp(() async {
      epub2Metadata =
          (await parsePackageDocument("package/dates-epub2.opf")).metadata;
      epub3Metadata =
          (await parsePackageDocument("package/dates-epub3.opf")).metadata;
    });

    test("Publication date is rightly parsed", () {
      var expected = DateTime.parse("1865-07-04T00:00:00Z");
      expect(epub2Metadata.published, expected);
      expect(epub3Metadata.published, expected);
    });

    test("Modification date is rightly parsed", () {
      var expected = DateTime.parse("2012-04-02T12:47:00Z");
      expect(epub2Metadata.modified, expected);
      expect(epub3Metadata.modified, expected);
    });
  });
  group("MetadataMiscTest", () {
    test("Unique identifier is rightly parsed", () async {
      var expected = "urn:uuid:2";
      expect(
          (await parsePackageDocument("package/identifier-unique.opf"))
              .metadata
              .identifier,
          expected);
    });

    test("Rendition properties are parsed", () async {
      var presentation =
          (await parsePackageDocument("package/presentation-metadata.opf"))
              .metadata
              .rendition!;
      expect(presentation.continuous, false);
      expect(presentation.overflow, PresentationOverflow.scrolled);
      expect(presentation.spread, PresentationSpread.both);
      expect(presentation.orientation, PresentationOrientation.landscape);
      expect(presentation.layout, EpubLayout.fixed);
    });

    test("Cover link is rightly identified", () async {
      var expected =
          Link(href: "/OEBPS/cover.jpg", type: "image/jpeg", rels: {"cover"});
      expect(
          (await parsePackageDocument("package/cover-epub2.opf"))
              .resources
              .firstWithRel("cover"),
          expected);
      expect(
          (await parsePackageDocument("package/cover-epub3.opf"))
              .resources
              .firstWithRel("cover"),
          expected);
      expect(
          (await parsePackageDocument("package/cover-mix.opf"))
              .resources
              .firstWithRel("cover"),
          expected);
    });

    test(
        "Building of MetaItems terminates even if metadata contain cross refinings",
        () {
      parsePackageDocument("package/meta-termination.opf");
    });

    test("otherMetadata is rightly filled", () async {
      var otherMetadata =
          (await parsePackageDocument("package/meta-others.opf"))
              .metadata
              .otherMetadata;
      expect(
          otherMetadata,
          containsPair("${Vocabularies.dcterms}source", [
            "Feedbooks",
            {"@value": "Web", "http://my.url/#scheme": "http"},
            "Internet"
          ]));

      expect(
          otherMetadata,
          containsPair("http://my.url/#property0", {
            "@value": "refines0",
            "http://my.url/#property1": {
              "@value": "refines1",
              "http://my.url/#property2": "refines2",
              "http://my.url/#property3": "refines3"
            }
          }));
      expect(
          otherMetadata.keys,
          containsAll([
            "${Vocabularies.dcterms}source",
            "presentation",
            "http://my.url/#property0"
          ]));
    });
  });
  group("CollectionTest", () {
    late Metadata epub2Metadata;
    late Metadata epub3Metadata;
    setUp(() async {
      epub2Metadata =
          (await parsePackageDocument("package/collections-epub2.opf"))
              .metadata;
      epub3Metadata =
          (await parsePackageDocument("package/collections-epub3.opf"))
              .metadata;
    });

    test("Basic collection are rightly parsed (epub3 only)", () {
      expect(
          epub3Metadata.belongsToCollections,
          contains(Collection(
              localizedName:
                  LocalizedString.fromStrings({"en": "Collection B"}))));
    });

    test(
        "Collections with unknown type are put into belongsToCollections (epub3 only)",
        () {
      expect(
          epub3Metadata.belongsToCollections,
          contains(Collection(
              localizedName:
                  LocalizedString.fromStrings({"en": "Collection A"}))));
    });

    test("Localized series are rightly parsed (epub3 only)", () {
      var names =
          LocalizedString.fromStrings({"en": "Series A", "fr": "Série A"});
      expect(
          epub3Metadata.belongsToSeries,
          contains(Collection(
              localizedName: names, identifier: "ser-a", position: 2.0)));
    });

    test("Series with position are rightly computed", () {
      var expected = Collection(
          localizedName: LocalizedString.fromStrings({"en": "Series B"}),
          position: 1.5);
      expect(epub2Metadata.belongsToSeries, contains(expected));
      expect(epub3Metadata.belongsToSeries, contains(expected));
    });
  });
}
