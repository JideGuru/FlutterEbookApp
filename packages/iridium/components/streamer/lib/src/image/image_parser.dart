// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/files.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/publication_parser.dart';
import 'package:universal_io/io.dart' hide Link;

/// Parser that supports a collection of images.
class ImageParser implements StreamPublicationParser {
  @override
  Future<PublicationBuilder?> parseFile(
      PublicationAsset asset, Fetcher fetcher) async {
    if (!await _accepts(asset, fetcher)) {
      return null;
    }

    List<Link> readingOrder = (await fetcher.links())
        .where((it) => !File(it.href).isHiddenOrThumbs && it.mediaType.isBitmap)
        .toList()
      ..sort((a, b) => a.href.compareTo(b.href));
    if (readingOrder.isEmpty) {
      throw Exception("No bitmap found in the publication.");
    }
    String title = (await fetcher.guessTitle()) ?? asset.name;

    // First valid resource is the cover.
    readingOrder[0] = readingOrder[0].copy(rels: {"cover"});

    Manifest manifest = Manifest(
        metadata: Metadata(localizedTitle: LocalizedString.fromString(title)),
        readingOrder: readingOrder,
        subcollections: {
          "pageList": [PublicationCollection(links: readingOrder)]
        });
    return PublicationBuilder(
        manifest: manifest,
        fetcher: fetcher,
        servicesBuilder: ServicesBuilder.create(
            positions: PerResourcePositionsService.createFactory(
                fallbackMediaType: "image/*")));
  }

  Future<bool> _accepts(PublicationAsset file, Fetcher fetcher) async {
    if (await file.mediaType == MediaType.cbz) {
      return true;
    }
    List<String> allowedExtensions = ["acbf", "txt", "xml"];
    if ((await fetcher.links())
        .where((it) => !File(it.href).isHiddenOrThumbs)
        .every((it) =>
            it.mediaType.isBitmap ||
            allowedExtensions.contains(File(it.href).lowercasedExtension))) {
      return true;
    }
    return false;
  }
}
