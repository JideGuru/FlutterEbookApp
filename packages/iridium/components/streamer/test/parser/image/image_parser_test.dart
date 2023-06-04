// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:mno_shared/archive.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;

Future<void> main() async {
  PublicationAsset assetForResource(String resource) {
    String path = "test_resources/image/$resource";
    return FileAsset(File(path));
  }

  Future<Fetcher> fetcherForAsset(PublicationAsset asset) async =>
      (await asset.createFetcher(
              PublicationAssetDependencies(DefaultArchiveFactory()), null))
          .getOrThrow();

  final ImageParser parser = ImageParser();

  final PublicationAsset cbzAsset = assetForResource("futuristic_tales.cbz");
  final Fetcher cbzFetcher = await fetcherForAsset(cbzAsset);

  final PublicationAsset jpgAsset = assetForResource("futuristic_tales.jpg");
  final Fetcher jpgFetcher = await fetcherForAsset(jpgAsset);

  test("CBZ is accepted", () async {
    expect(await parser.parseFile(cbzAsset, cbzFetcher), isNotNull);
  });

  test("JPG is accepted", () async {
    expect(await parser.parseFile(jpgAsset, jpgFetcher), isNotNull);
  });

  test("readingOrder is sorted alphabetically", () async {
    var builder = await parser.parseFile(cbzAsset, cbzFetcher);
    expect(builder, isNotNull);
    var readingOrder = builder!.manifest.readingOrder.map((it) => it.href
        .removePrefix("/Cory Doctorow's Futuristic Tales of the Here and Now"));
    expect(
        readingOrder,
        containsAllInOrder(
            ["/a-fc.jpg", "/x-002.jpg", "/x-003.jpg", "/x-004.jpg"]));
  });

  test("the cover is the first item in the readingOrder", () async {
    var builder = await parser.parseFile(cbzAsset, cbzFetcher);
    expect(builder, isNotNull);
    expect("/Cory Doctorow's Futuristic Tales of the Here and Now/a-fc.jpg",
        builder!.manifest.readingOrder.firstWithRel("cover")?.href);
  });

  test("title is based on archive's root directory when any", () async {
    var builder = await parser.parseFile(cbzAsset, cbzFetcher);
    expect(builder, isNotNull);
    expect("Cory Doctorow's Futuristic Tales of the Here and Now",
        builder!.manifest.metadata.title);
  });
}
