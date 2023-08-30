// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/navigation_document_parser.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;
import 'package:xml/xml.dart';

Future<void> main() async {
  Future<Map<String, List<Link>>> parseNavigationDocument(
      String resource) async {
    String path = "test_resources/epub/$resource";
    var document = XmlDocument.parse(await File(path).readAsString());
    var navigationDocument =
        NavigationDocumentParser.parse(document, "OEBPS/xhtml/nav.xhtml");
    return navigationDocument;
  }

  var navComplex =
      await parseNavigationDocument("navigation/nav-complex.xhtml");
  var navTitles = await parseNavigationDocument("navigation/nav-titles.xhtml");
  var navSection =
      await parseNavigationDocument("navigation/nav-section.xhtml");
  var navChildren =
      await parseNavigationDocument("navigation/nav-children.xhtml");
  var navEmpty = await parseNavigationDocument("navigation/nav-empty.xhtml");

  test("nav can be a non-direct descendant of body", () {
    expect(
        navSection["toc"],
        containsAllInOrder(
            [Link(title: "Chapter 1", href: "/OEBPS/xhtml/chapter1.xhtml")]));
  });

  test("Newlines are trimmed from title", () {
    expect(
        navTitles["toc"],
        contains(Link(
            title: "A link with new lines splitting the text",
            href: "/OEBPS/xhtml/chapter1.xhtml")));
  });

  test("Spaces are trimmed from title", () {
    expect(
        navTitles["toc"],
        contains(Link(
            title: "A link with ignorable spaces",
            href: "/OEBPS/xhtml/chapter2.xhtml")));
  });

  test("Nested HTML elements are allowed in titles", () {
    expect(
        navTitles["toc"],
        contains(Link(
            title: "A link with nested HTML elements",
            href: "/OEBPS/xhtml/chapter3.xhtml")));
  });

  test("Entries with a zero-length title and no children are ignored", () {
    expect(navTitles["toc"],
        isNot(contains(Link(title: "", href: "/OEBPS/xhtml/chapter4.xhtml"))));
  });

  test("Unlinked entries without children are ignored", () {
    expect(
        navTitles["toc"],
        isNot(contains(Link(
            title: "An unlinked element without children must be ignored",
            href: "#"))));
  });

  test("Hierarchical items are allowed", () {
    expect(
        navChildren["toc"],
        containsAllInOrder([
          Link(title: "Introduction", href: "/OEBPS/xhtml/introduction.xhtml"),
          Link(title: "Part I", href: "#", children: [
            Link(title: "Chapter 1", href: "/OEBPS/xhtml/part1/chapter1.xhtml"),
            Link(title: "Chapter 2", href: "/OEBPS/xhtml/part1/chapter2.xhtml")
          ]),
          Link(
              title: "Part II",
              href: "/OEBPS/xhtml/part2/chapter1.xhtml",
              children: [
                Link(
                    title: "Chapter 1",
                    href: "/OEBPS/xhtml/part2/chapter1.xhtml"),
                Link(
                    title: "Chapter 2",
                    href: "/OEBPS/xhtml/part2/chapter2.xhtml")
              ])
        ]));
  });

  test("Fake Navigation Document is accepted", () {
    expect(navEmpty["toc"], isNull);
  });

  test("toc is rightly parsed", () {
    expect(
        navComplex["toc"],
        containsAllInOrder([
          Link(title: "Chapter 1", href: "/OEBPS/xhtml/chapter1.xhtml"),
          Link(title: "Chapter 2", href: "/OEBPS/xhtml/chapter2.xhtml")
        ]));
  });

  test("landmarks are rightly parsed", () {
    expect(
        navComplex["landmarks"],
        containsAllInOrder([
          Link(title: "Table of Contents", href: "/OEBPS/xhtml/nav.xhtml#toc"),
          Link(title: "Begin Reading", href: "/OEBPS/xhtml/chapter1.xhtml")
        ]));
  });

  test("page-list is rightly parsed", () {
    expect(
        navComplex["page-list"],
        containsAllInOrder([
          Link(title: "1", href: "/OEBPS/xhtml/chapter1.xhtml#page1"),
          Link(title: "2", href: "/OEBPS/xhtml/chapter1.xhtml#page2")
        ]));
  });
}
