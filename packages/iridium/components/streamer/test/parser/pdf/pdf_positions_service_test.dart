// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/pdf/pdf_positions_service.dart';
import 'package:test/test.dart';

void main() {
  PdfPositionsService createService({Link? link, required int pageCount}) =>
      PdfPositionsService(
          link: link ?? Link(href: "/publication.pdf"),
          pageCount: pageCount,
          tableOfContents: []);

  test("Positions from 0 pages", () async {
    var service = createService(pageCount: 0);
    expect(0, (await service.positions()).length);
  });

  test("Positions from 1 page", () async {
    var service = createService(pageCount: 1);
    expect([
      [
        Locator(
            href: "/publication.pdf",
            type: "application/pdf",
            locations: Locations(
                fragments: ["page=1"],
                progression: 0.0,
                position: 1,
                totalProgression: 0.0))
      ]
    ], await service.positionsByReadingOrder());
  });

  test("Positions from several pages", () async {
    var service = createService(pageCount: 3);
    expect([
      [
        Locator(
            href: "/publication.pdf",
            type: "application/pdf",
            locations: Locations(
                fragments: ["page=1"],
                progression: 0.0,
                position: 1,
                totalProgression: 0.0)),
        Locator(
            href: "/publication.pdf",
            type: "application/pdf",
            locations: Locations(
                fragments: ["page=2"],
                progression: 1.0 / 3.0,
                position: 2,
                totalProgression: 1.0 / 3.0)),
        Locator(
            href: "/publication.pdf",
            type: "application/pdf",
            locations: Locations(
                fragments: ["page=3"],
                progression: 2.0 / 3.0,
                position: 3,
                totalProgression: 2.0 / 3.0))
      ]
    ], await service.positionsByReadingOrder());
  });
}
