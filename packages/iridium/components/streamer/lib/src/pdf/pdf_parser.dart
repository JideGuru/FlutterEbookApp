// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/pdf.dart';
import 'package:mno_streamer/publication_parser.dart';
import 'package:mno_streamer/src/container/publication_container.dart';
import 'package:mno_streamer/src/pdf/pdf_positions_service.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' show File;

/// Parser for PDF file.
class PdfParser extends PublicationParser implements StreamPublicationParser {
  static const String _publicationFileName = "publication.pdf";

  /// [pdfFactory] is an implementation that can open PDF files.
  final PdfDocumentFactory pdfFactory;

  /// Creates an instance of [PdfParser] that requires a [pdfFactory].
  PdfParser(this.pdfFactory);

  @override
  Future<PublicationBuilder?> parseFile(
          PublicationAsset asset, Fetcher fetcher) =>
      _parseFile(asset, fetcher, asset.toTitle());

  String get _rootHref => "/$_publicationFileName";

  Future<PublicationBuilder?> _parseFile(
      PublicationAsset asset, Fetcher fetcher, String fallbackTitle) async {
    if ((await asset.mediaType) != MediaType.pdf) {
      return null;
    }

    Link? pdfLink = (await fetcher.links())
        .firstOrNullWhere((it) => it.mediaType == MediaType.pdf);
    if (pdfLink == null) {
      throw Exception("Unable to find PDF file.");
    }
    String fileHref = pdfLink.href;

    PdfDocument document = await pdfFactory.openResource(fetcher.get(pdfLink));
    String title = document.title?.ifBlank(() => null) ?? fallbackTitle;

    List<Link> tableOfContents = document.outline(fileHref);

    Manifest manifest = Manifest(
      metadata: Metadata(
        identifier: document.identifier,
        localizedTitle: LocalizedString.fromString(title),
        authors: [document.author]
            .whereNotNull()
            .where(((s) => s.isNotBlank))
            .mapNotNull(Contributor.fromString)
            .toList(),
        numberOfPages: document.pageCount,
      ),
      readingOrder: [pdfLink],
      resources: [
        Link(
          href: "cover.png",
          type: MediaType.png.toString(),
          rels: {'cover'},
        )
      ],
      subcollections: {
        "pageList": [
          PublicationCollection(
              links: List.generate(
                  document.pageCount,
                  (index) => Link(
                        id: "$_rootHref?page=$index",
                        href: "$_rootHref?page=$index",
                        type: MediaType.pdf.toString(),
                        title: title,
                      )))
        ]
      },
      tableOfContents: tableOfContents,
    );
    ServicesBuilder servicesBuilder = ServicesBuilder.create(
        positions: PdfPositionsService.create,
        cover: document.cover?.let(InMemoryCoverService.createFactory));
    return PublicationBuilder(
        manifest: manifest, fetcher: fetcher, servicesBuilder: servicesBuilder);
  }

  @override
  Future<PubBox?> parseWithFallbackTitle(
      String fileAtPath, String fallbackTitle) async {
    FileAsset file = FileAsset(File(fileAtPath));
    FileFetcher baseFetcher =
        FileFetcher.single(href: "/${file.name}", file: file.file);
    PublicationBuilder? builder;
    try {
      builder = await _parseFile(file, baseFetcher, fallbackTitle);
    } catch (e) {
      return null;
    }
    if (builder == null) {
      return null;
    }
    Publication publication = builder.build();

    PublicationContainer container = PublicationContainer(
        path: p.canonicalize(fileAtPath), mediaType: MediaType.pdf);

    return PubBox(publication, container);
  }
}
