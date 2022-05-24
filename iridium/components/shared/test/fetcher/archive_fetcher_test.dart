// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;

void main() {
  late ArchiveFetcher fetcher;

  setUp(() async {
    var epub = File("test_resources/fetcher/epub.epub");
    var zipFetcher = await ArchiveFetcher.fromPath(epub.path);
    assert(zipFetcher != null);
    fetcher = zipFetcher!;
  });

  test("Link list is correct", () async {
    Link createLink(String href, String? type, int? compressedLength) => Link(
          href: href,
          type: type,
          properties: Properties(
              otherProperties: compressedLength
                      ?.let((it) => {"compressedLength": compressedLength}) ??
                  {}),
        );

    expect([
      createLink("/mimetype", null, null),
      createLink("/EPUB/cover.xhtml", "text/html", 259),
      createLink("/EPUB/css/epub.css", "text/css", 595),
      createLink("/EPUB/css/nav.css", "text/css", 306),
      createLink("/EPUB/images/cover.png", "image/png", 35809),
      createLink("/EPUB/nav.xhtml", "text/html", 2293),
      createLink("/EPUB/package.opf", null, 773),
      createLink("/EPUB/s04.xhtml", "text/html", 118269),
      createLink("/EPUB/toc.ncx", "application/x-dtbncx+xml", 1697),
      createLink("/META-INF/container.xml", "application/xml", 176)
    ], await fetcher.links());
  });

  test("Computing length for a missing entry returns NotFound", () async {
    var resource = fetcher.get(Link(href: "/unknown"));
    expect(
        () async => (await resource.length()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Reading a missing entry returns NotFound", () async {
    var resource = fetcher.get(Link(href: "/unknown"));
    expect(
        () async => (await resource.read()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Fully reading an entry works well", () async {
    var resource = fetcher.get(Link(href: "/mimetype"));
    var result = (await resource.read()).getOrNull();
    expect("application/epub+zip", result?.asUtf8());
  });

  test("Reading a range of an entry works well", () async {
    var resource = fetcher.get(Link(href: "/mimetype"));
    var result = (await resource.read(range: IntRange(0, 10))).getOrNull();
    expect("application", result?.asUtf8());
    expect(11, result?.lengthInBytes);
  });

  test("Out of range indexes are clamped to the available length", () async {
    var resource = fetcher.get(Link(href: "/mimetype"));
    var result = (await resource.read(range: IntRange(-5, 60))).getOrNull();
    expect("application/epub+zip", result?.asUtf8());
    expect(20, result?.lengthInBytes);
  });

  test("Decreasing ranges are understood as empty ones", () async {
    var resource = fetcher.get(Link(href: "/mimetype"));
    var result = (await resource.read(range: IntRange(60, 80))).getOrNull();
    expect("", result?.asUtf8());
    expect(0, result?.lengthInBytes);
  });

  test("Computing length works well", () async {
    var resource = fetcher.get(Link(href: "/mimetype"));
    var result = await resource.length();
    expect(20, result.getOrNull());
  });

  test("Computing a directory length returns NotFound", () {
    var resource = fetcher.get(Link(href: "/EPUB"));
    expect(
        () async => (await resource.length()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Computing the length of a missing file returns NotFound", () {
    var resource = fetcher.get(Link(href: "/unknown"));
    expect(
        () async => (await resource.length()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Original link properties are kept", () async {
    var resource = fetcher.get(Link(
        href: "/mimetype",
        properties: Properties(otherProperties: {"other": "property"})));
    expect(
        Link(
            href: "/mimetype",
            properties: Properties(otherProperties: {"other": "property"})),
        await resource.link());
  });
}
