// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;

void main() {
  File text = File("test_resources/fetcher/text.txt");
  Directory directory = Directory("test_resources/fetcher/directory");
  FileFetcher fetcher =
      FileFetcher({"/file_href": text, "/dir_href": directory});

  test("Computing length for a missing file returns NotFound", () {
    var resource = fetcher.get(Link(href: "/unknown"));
    expect(
        () async => (await resource.length()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Reading a missing file returns NotFound", () {
    var resource = fetcher.get(Link(href: "/unknown"));
    expect(
        () async => (await resource.read()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Reading an href in the map works well", () async {
    var resource = fetcher.get(Link(href: "/file_href"));
    var result = (await resource.read()).getOrNull();
    expect("text", result?.asUtf8());
  });

  test("Reading a file in a directory works well", () async {
    var resource = fetcher.get(Link(href: "/dir_href/text1.txt"));
    var result = (await resource.read()).getOrNull();
    expect("text1", result?.asUtf8());
  });

  test("Reading a file in a subdirectory works well", () async {
    var resource = fetcher.get(Link(href: "/dir_href/subdirectory/text2.txt"));
    var result = (await resource.read()).getOrNull();
    expect("text2", result?.asUtf8());
  });

  test("Reading a directory returns NotFound", () async {
    var resource = fetcher.get(Link(href: "/dir_href/subdirectory"));
    expect(
        () async => (await resource.length()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Reading a file outside the allowed directory returns NotFound", () {
    var resource = fetcher.get(Link(href: "/dir_href/../text1.txt"));
    expect(
        () async => (await resource.read()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Reading a range works well", () async {
    var resource = fetcher.get(Link(href: "/file_href"));
    var result = (await resource.read(range: IntRange(0, 2))).getOrNull();
    expect("tex", result?.asUtf8());
  });

  test("Reading two ranges with the same resource work well", () async {
    var resource = fetcher.get(Link(href: "/file_href"));
    var result1 = (await resource.read(range: IntRange(0, 1))).getOrNull();
    expect("te", result1?.asUtf8());
    var result2 = (await resource.read(range: IntRange(1, 3))).getOrNull();
    expect("ext", result2?.asUtf8());
  });

  test("Out of range indexes are clamped to the available length", () async {
    var resource = fetcher.get(Link(href: "/file_href"));
    var result = (await resource.read(range: IntRange(-5, 60))).getOrNull();
    expect("text", result?.asUtf8());
    expect(4, result?.lengthInBytes);
  });

  test("Decreasing ranges are understood as empty ones", () async {
    var resource = fetcher.get(Link(href: "/file_href"));
    var result = (await resource.read(range: IntRange(60, 20))).getOrNull();
    expect("", result?.asUtf8());
    expect(0, result?.lengthInBytes);
  });

  test("Computing length works well", () async {
    var resource = fetcher.get(Link(href: "/file_href"));
    var result = (await resource.length()).getOrNull();
    expect(4, result);
  });

  test("Computing a directory length returns NotFound", () async {
    var resource = fetcher.get(Link(href: "/dir_href/subdirectory"));
    expect(
        () async => (await resource.length()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Computing the length of a missing file returns NotFound", () async {
    var resource = fetcher.get(Link(href: "/unknown"));
    expect(
        () async => (await resource.length()).getOrThrow(),
        throwsA(predicate((e) =>
            e is ResourceException &&
            e.userMessageId == ResourceException.notFound.userMessageId)));
  });

  test("Computing links works well", () async {
    var links = await fetcher.links();
    Fimber.d("links: $links");
    expect((await fetcher.links()), [
      Link(href: "/file_href", type: "text/plain"),
      Link(href: "/dir_href/subdirectory/hello.mp3", type: "audio/mpeg"),
      Link(href: "/dir_href/subdirectory/text2.txt", type: "text/plain"),
      Link(href: "/dir_href/text1.txt", type: "text/plain"),
    ]);
  });
}
