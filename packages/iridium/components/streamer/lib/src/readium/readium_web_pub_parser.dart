// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/io.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/pdf.dart';
import 'package:mno_streamer/publication_parser.dart';
import 'package:mno_streamer/src/container/container.dart';
import 'package:mno_streamer/src/container/publication_container.dart';
import 'package:mno_streamer/src/readium/lcpdf_positions_service.dart';
import 'package:mno_streamer/src/streamer.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart' hide Link;

/// Parses any Readium Web Publication package or manifest, e.g. WebPub, Audiobook, DiViNa, LCPDF...
class ReadiumWebPubParser extends PublicationParser
    implements StreamPublicationParser {
  final PdfDocumentFactory? _pdfFactory;

  /// Creates a [ReadiumWebPubParser] instance.
  ReadiumWebPubParser(this._pdfFactory);

  @override
  Future<PublicationBuilder?> parseFile(
      PublicationAsset asset, Fetcher fetcher) async {
    MediaType mediaType = await asset.mediaType;
    if (!mediaType._isReadiumWebPubProfile) {
      return null;
    }

    Manifest? manifest;
    if (mediaType.isRwpm) {
      Link? manifestLink = (await fetcher.links()).firstOrNull;
      if (manifestLink == null) {
        throw Exception("Empty fetcher.");
      }
      Map<String, dynamic> manifestJson = await fetcher
          .get(manifestLink)
          .use((it) => it.readAsJson())
          .then((result) => result.getOrThrow());
      manifest = Manifest.fromJson(manifestJson);
    } else {
      Link? manifestLink = (await fetcher.links())
          .firstOrNullWhere((it) => it.href == "/manifest.json");
      if (manifestLink == null) {
        throw Exception("Unable to find a manifest link.");
      }
      Map<String, dynamic> manifestJson = await fetcher
          .get(manifestLink)
          .use((it) => it.readAsJson())
          .then((result) => result.getOrThrow());
      manifest = Manifest.fromJson(manifestJson, packaged: true);
    }
    if (manifest == null) {
      throw Exception("Failed to parse RWPM.");
    }

    // Checks the requirements from the LCPDF specification.
    // https://readium.org/lcp-specs/notes/lcp-for-pdf.html
    List<Link> readingOrder = manifest.readingOrder;
    Fimber.d("readingOrder: $readingOrder");
    if (mediaType == MediaType.lcpProtectedPdf &&
        (readingOrder.isEmpty ||
            !readingOrder.all((it) => it.mediaType.matches(MediaType.pdf)))) {
      Fimber.d("throw Exception(\"Invalid LCP Protected PDF.\")");
      throw Exception("Invalid LCP Protected PDF.");
    }

    ServiceFactory? positionsServiceFactory;
    ServiceFactory? coverServiceFactory;
    if (mediaType == MediaType.lcpProtectedPdf) {
      positionsServiceFactory =
          _pdfFactory?.let((it) => LcpdfPositionsService.create(it));
      await _pdfFactory?.let((it) async {
        Link link = readingOrder.first;
        try {
          PdfDocument document = await it.openResource(fetcher.get(link));
          coverServiceFactory =
              document.cover?.let(InMemoryCoverService.createFactory);
          manifest = manifest!.copy(
            metadata: manifest!.metadata.copy(
              numberOfPages: document.pageCount,
            ),
          );
          manifest!.subcollections["pageList"] = [
            PublicationCollection(
                links: List.generate(
                    document.pageCount,
                    (index) => Link(
                          id: "${link.href}?page=$index",
                          href: "${link.href}?page=$index",
                          type: MediaType.pdf.toString(),
                          title: manifest!.metadata.localizedTitle.string,
                        )))
          ];
        } on Exception catch (e) {
          Fimber.e("openPdfAt failed", ex: e);
        }
      });
    } else if (mediaType == MediaType.divinaManifest ||
        mediaType == MediaType.divina) {
      positionsServiceFactory = PerResourcePositionsService.createFactory(
          fallbackMediaType: "image/*");
    } else if (mediaType == MediaType.readiumAudiobook ||
        mediaType == MediaType.readiumAudiobookManifest ||
        mediaType == MediaType.lcpProtectedAudiobook) {
      // positionsServiceFactory = AudioLocatorService.createFactory();
    }

    ServicesBuilder servicesBuilder = ServicesBuilder.create(
      positions: positionsServiceFactory,
      cover: coverServiceFactory,
    );

    return PublicationBuilder(
        manifest: manifest!,
        fetcher: fetcher,
        servicesBuilder: servicesBuilder);
  }

  @override
  Future<PubBox?> parseWithFallbackTitle(
      String fileAtPath, String fallbackTitle) async {
    File file = File(fileAtPath);
    FileAsset asset = FileAsset(file);
    MediaType mediaType = await asset.mediaType;
    Fetcher baseFetcher;
    try {
      baseFetcher = await ArchiveFetcher.fromPath(file.path) ??
          FileFetcher.single(href: "/${basename(fileAtPath)}", file: file);
    } on FileNotFoundException {
      throw ContainerError.missingFile(fileAtPath);
    } on Exception {
      return null;
    }

    Drm? drm = (await baseFetcher._isProtectedWithLcp()) ? Drm.lcp : null;
    PublicationBuilder? builder;
    try {
      builder = await parseFile(asset, baseFetcher);
    } on Exception {
      return null;
    }
    if (builder == null) {
      return null;
    }

    Publication publication = builder.build().also((it) {
      it.type = mediaType.toPublicationType();
    });

    PublicationContainer container = PublicationContainer(
            path: file.canonicalPath, mediaType: mediaType, drm: drm)
        .also((it) {
      if (!mediaType.isRwpm) {
        it.rootFile.rootFilePath = "manifest.json";
      }
    });

    return PubBox(publication, container);
  }
}

extension _FetcherIsProtectedWithLcp on Fetcher {
  Future<bool> _isProtectedWithLcp() => getWithHref("license.lcpl")
      .use((it) => it.length())
      .then((result) => result.isSuccess);
}

extension _MediaTypeIsReadiumWebPubProfile on MediaType {
  /// Returns whether this media type is of a Readium Web Publication profile.
  bool get _isReadiumWebPubProfile => matchesAny([
        MediaType.readiumWebpub,
        MediaType.readiumWebpubManifest,
        MediaType.readiumAudiobook,
        MediaType.readiumAudiobookManifest,
        MediaType.lcpProtectedAudiobook,
        MediaType.divina,
        MediaType.divinaManifest,
        MediaType.lcpProtectedPdf
      ]);
}
