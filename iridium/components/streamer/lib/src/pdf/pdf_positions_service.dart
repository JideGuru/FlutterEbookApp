// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';

/// Creates the [positions] for a PDF [Publication].
///
/// @param link The [Link] to the PDF document in the [Publication].
/// @param pageCount Total page count in the PDF document.
/// @param tableOfContents Table of contents used to compute the position titles.
class PdfPositionsService extends PositionsService {
  /// [link] reference to the PDF file.
  final Link link;

  /// Number of pages.
  final int pageCount;

  /// Table of content for this PDF.
  final List<Link> tableOfContents;
  List<List<Locator>>? _positions;

  /// Creates a [PdfPositionsService] instance.
  PdfPositionsService(
      {required this.link,
      required this.pageCount,
      required this.tableOfContents});

  /// Create a [ServiceFactory] that will provide a [PdfPositionsService]
  /// instance.
  static PdfPositionsService? create(PublicationServiceContext context) {
    Link? link = context.manifest.readingOrder.firstOrNull;
    if (link == null) {
      return null;
    }
    return PdfPositionsService(
      link: link,
      pageCount: context.manifest.metadata.numberOfPages ?? 0,
      tableOfContents: context.manifest.tableOfContents,
    );
  }

  @override
  Future<List<List<Locator>>> positionsByReadingOrder() async =>
      _positions ??= _computePositions();

  List<List<Locator>> _computePositions() {
    if (pageCount <= 0) {
      Fimber.e("Invalid page count for a PDF document: $pageCount");
      return [];
    }

    return [
      IntRange(1, pageCount).map((position) {
        double progression = (position - 1) / pageCount.toDouble();
        return Locator(
            href: link.href,
            type: link.type ?? MediaType.pdf.toString(),
            locations: Locations(
                fragments: ["page=$position"],
                progression: progression,
                totalProgression: progression,
                position: position));
      }).toList()
    ];
  }
}
