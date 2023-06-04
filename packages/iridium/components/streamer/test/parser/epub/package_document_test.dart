// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dfunc/dfunc.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;
import 'package:xml/xml.dart';

Future<Manifest> parsePackageDocument(String resource,
    {String? displayOptions}) async {
  String path = "test_resources/epub/$resource";
  var document = XmlDocument.parse(await File(path).readAsString());
  var pub = document
      .let((it) => PackageDocument.parse(it.rootElement, "OEBPS/content.opf"))
      ?.let((it) => PublicationFactory(
          fallbackTitle: "fallback title", packageDocument: it))
      .create();
  assert(pub != null);
  return pub!;
}

void main() {
  group("ReadingProgressionTest", () {
    test("No page progression direction is mapped to default", () async {
      expect(
          (await parsePackageDocument("package/progression-none.opf"))
              .metadata
              .readingProgression,
          ReadingProgression.auto);
    });

    test("Default page progression direction is rightly parsed", () async {
      expect(
          (await parsePackageDocument("package/progression-default.opf"))
              .metadata
              .readingProgression,
          ReadingProgression.auto);
    });

    test("Ltr page progression direction is rightly parsed", () async {
      expect(
          (await parsePackageDocument("package/progression-ltr.opf"))
              .metadata
              .readingProgression,
          ReadingProgression.ltr);
    });

    test("Rtl page progression direction is rightly parsed", () async {
      expect(
          (await parsePackageDocument("package/progression-rtl.opf"))
              .metadata
              .readingProgression,
          ReadingProgression.rtl);
    });
  });

  group("LinkPropertyTest", () {
    late Manifest propertiesPub;
    setUp(() async => propertiesPub =
        (await parsePackageDocument("package/links-properties.opf")));

    test("contains is rightly filled", () {
      expect(propertiesPub.readingOrder[0].properties.contains,
          containsAll(["mathml"]));
      expect(propertiesPub.readingOrder[1].properties.contains,
          containsAll(["remote-resources"]));
      expect(propertiesPub.readingOrder[2].properties.contains,
          containsAll(["js", "svg"]));
      expect(propertiesPub.readingOrder[3].properties.contains.isEmpty, isTrue);
      expect(propertiesPub.readingOrder[4].properties.contains.isEmpty, isTrue);
    });

    test("rels is rightly filled", () {
      expect(propertiesPub.resources[0].rels, containsAll(["cover"]));
      expect(propertiesPub.readingOrder[0].rels.isEmpty, isTrue);
      expect(propertiesPub.readingOrder[1].rels.isEmpty, isTrue);
      expect(propertiesPub.readingOrder[2].rels.isEmpty, isTrue);
      expect(propertiesPub.readingOrder[3].rels, contains("contents"));
      expect(propertiesPub.readingOrder[4].rels.isEmpty, isTrue);
    });

    test("presentation properties are parsed", () {
      expect(propertiesPub.readingOrder[0].properties.layout, EpubLayout.fixed);
      expect(propertiesPub.readingOrder[0].properties.overflow,
          PresentationOverflow.auto);
      expect(propertiesPub.readingOrder[0].properties.orientation,
          PresentationOrientation.auto);
      expect(propertiesPub.readingOrder[0].properties.page,
          PresentationPage.right);
      expect(propertiesPub.readingOrder[0].properties.spread, isNull);

      expect(propertiesPub.readingOrder[1].properties.layout,
          EpubLayout.reflowable);
      expect(propertiesPub.readingOrder[1].properties.overflow,
          PresentationOverflow.paginated);
      expect(propertiesPub.readingOrder[1].properties.orientation,
          PresentationOrientation.landscape);
      expect(
          propertiesPub.readingOrder[1].properties.page, PresentationPage.left);
      expect(propertiesPub.readingOrder[0].properties.spread, isNull);

      expect(propertiesPub.readingOrder[2].properties.layout, isNull);
      expect(propertiesPub.readingOrder[2].properties.overflow,
          PresentationOverflow.scrolled);
      expect(propertiesPub.readingOrder[2].properties.orientation,
          PresentationOrientation.portrait);
      expect(propertiesPub.readingOrder[2].properties.page,
          PresentationPage.center);
      expect(propertiesPub.readingOrder[2].properties.spread, isNull);

      expect(propertiesPub.readingOrder[3].properties.layout, isNull);
      expect(propertiesPub.readingOrder[3].properties.overflow,
          PresentationOverflow.scrolled);
      expect(propertiesPub.readingOrder[3].properties.orientation, isNull);
      expect(propertiesPub.readingOrder[3].properties.page, isNull);
      expect(propertiesPub.readingOrder[3].properties.spread,
          PresentationSpread.auto);
    });
  });

  group("LinkTest", () {
    late Manifest resourcesPub;
    setUp(() async =>
        resourcesPub = (await parsePackageDocument("package/links.opf")));

    test("readingOrder is rightly computed", () {
      expect(
          resourcesPub.readingOrder,
          containsAll([
            Link(href: "/titlepage.xhtml", type: "application/xhtml+xml"),
            Link(href: "/OEBPS/chapter01.xhtml", type: "application/xhtml+xml")
          ]));
    });

    test("resources are rightly computed", () {
      expect(
          resourcesPub.resources,
          containsAll([
            Link(
                href: "/OEBPS/fonts/MinionPro.otf",
                type: "application/vnd.ms-opentype"),
            Link(
                href: "/OEBPS/nav.xhtml",
                type: "application/xhtml+xml",
                rels: {"contents"}),
            Link(href: "/style.css", type: "text/css"),
            Link(href: "/OEBPS/chapter01.smil", type: "application/smil+xml"),
            Link(
                href: "/OEBPS/chapter02.smil",
                type: "application/smil+xml",
                duration: 1949.0),
            Link(
                href: "/OEBPS/images/alice01a.png",
                type: "image/png",
                rels: {"cover"}),
            Link(href: "/OEBPS/images/alice02a.gif", type: "image/gif"),
            Link(href: "/OEBPS/chapter02.xhtml", type: "application/xhtml+xml"),
            Link(href: "/OEBPS/nomediatype.txt")
          ]));
    });
  });

  group("LinkMiscTest", () {
    test("Fallbacks are mapped to alternates", () async {
      expect(
          (await parsePackageDocument("package/fallbacks.opf")).resources,
          contains(Link(
              href: "/OEBPS/chap1_docbook.xml",
              type: "application/docbook+xml",
              alternates: [
                Link(
                    href: "/OEBPS/chap1.xml",
                    type: "application/z3998-auth+xml",
                    alternates: [
                      Link(
                          href: "/OEBPS/chap1.xhtml",
                          type: "application/xhtml+xml")
                    ])
              ])));
    });

    test("Fallback computing terminates even if there are crossed dependencies",
        () async {
      expect(await parsePackageDocument("package/fallbacks-termination.opf"),
          isNotNull);
    });
  });
}
