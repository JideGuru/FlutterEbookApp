// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_shared/archive.dart';
import 'package:test/test.dart';

import '../../fixtures.dart';

void main() async {
  Fimber.plantTree(DebugTree());
  var fixtures = Fixtures(path: "test_resources/util/archive");
  var epubZip = fixtures.fileAt("epub.epub");
  Archive? zipArchive = await DefaultArchiveFactory().open(epubZip, null);
  assert(zipArchive != null);

  var epubExploded = fixtures.fileAt("epub");
  Archive? explodedArchive =
      await DefaultArchiveFactory().open(epubExploded, null);
  assert(explodedArchive != null);

  List<Archive> archives = [zipArchive!, explodedArchive!];

  for (Archive archive in archives) {
    group("Test Archive of type: ${archive.runtimeType}", () {
      test("Entry list is correct", () async {
        expect(
            (await archive.entries()).map((it) => it.path).toSet().containsAll({
              "mimetype",
              "EPUB/cover.xhtml",
              "EPUB/css/epub.css",
              "EPUB/css/nav.css",
              "EPUB/images/cover.png",
              "EPUB/nav.xhtml",
              "EPUB/package.opf",
              "EPUB/s04.xhtml",
              "EPUB/toc.ncx",
              "META-INF/container.xml"
            }),
            isTrue);
      });

      test("Attempting to get a missing entry throws", () async {
        expect(() async => (await archive.entry("unknown")),
            throwsA(predicate((e) => e is Exception)));
      });

      test("Fully reading an entry works well", () async {
        var bytes = await (await archive.entry("mimetype")).read();
        expect("application/epub+zip", bytes.asUtf8());
      });

      test("Reading a range of an entry works well", () async {
        var bytes = await (await archive.entry("mimetype"))
            .read(range: IntRange(0, 10));
        expect("application", bytes.asUtf8());
        expect(11, bytes.lengthInBytes);
      });

      test("Out of range indexes are clamped to the available length",
          () async {
        var bytes = await (await archive.entry("mimetype"))
            .read(range: IntRange(-5, 60));
        expect("application/epub+zip", bytes.asUtf8());
        expect(20, bytes.lengthInBytes);
      });

      test("Decreasing ranges are understood as empty ones", () async {
        var bytes = await (await archive.entry("mimetype"))
            .read(range: IntRange(60, 20));
        expect("", bytes.asUtf8());
        expect(0, bytes.lengthInBytes);
      });

      test("Computing size works well", () async {
        var size = (await archive.entry("mimetype")).length;
        expect(20, size);
      });
    });
  }
}
