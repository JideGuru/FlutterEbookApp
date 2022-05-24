// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() async {
  DefaultLocatorService createService(
          {List<Link> readingOrder = const [],
          List<List<Locator>> positions = const []}) =>
      DefaultLocatorService(readingOrder, () async => positions);

  const List<List<Locator>> positionsFixtures = [
    [
      Locator(
          href: "chap1",
          type: "text/html",
          locations:
              Locations(progression: 0.0, position: 1, totalProgression: 0.0))
    ],
    [
      Locator(
          href: "chap2",
          type: "application/xml",
          locations: Locations(
              progression: 0.0, position: 2, totalProgression: 1.0 / 8.0))
    ],
    [
      Locator(
          href: "chap3",
          type: "text/html",
          title: "Chapter 3",
          locations: Locations(
              progression: 0.0, position: 3, totalProgression: 2.0 / 8.0))
    ],
    [
      Locator(
          href: "chap4",
          type: "text/html",
          locations: Locations(
              progression: 0.0, position: 4, totalProgression: 3.0 / 8.0)),
      Locator(
          href: "chap4",
          type: "text/html",
          locations: Locations(
              progression: 0.5, position: 5, totalProgression: 4.0 / 8.0))
    ],
    [
      Locator(
          href: "chap5",
          type: "text/html",
          locations: Locations(
              progression: 0.0, position: 6, totalProgression: 5.0 / 8.0)),
      Locator(
          href: "chap5",
          type: "text/html",
          locations: Locations(
              progression: 1.0 / 3.0,
              position: 7,
              totalProgression: 6.0 / 8.0)),
      Locator(
          href: "chap5",
          type: "text/html",
          locations: Locations(
              progression: 2.0 / 3.0, position: 8, totalProgression: 7.0 / 8.0))
    ]
  ];

  test("locate from Locator", () async {
    var service = createService(readingOrder: [
      Link(href: "chap1", type: "application/xml"),
      Link(href: "chap2", type: "application/xml"),
      Link(href: "chap3", type: "application/xml")
    ]);
    var locator = Locator(
        href: "chap2",
        type: "text/html",
        text: LocatorText(highlight: "Highlight"));
    expect(locator, await service.locate(locator));
  });

  test("locate from Locator with empty reading order", () async {
    var service = createService(readingOrder: []);
    var locator = Locator(
        href: "chap2",
        type: "text/html",
        text: LocatorText(highlight: "Highlight"));
    expect(await service.locate(locator), isNull);
  });

  test("locate from Locator not found", () async {
    var service = createService(readingOrder: [
      Link(href: "chap1", type: "application/xml"),
      Link(href: "chap3", type: "application/xml")
    ]);
    var locator = Locator(
        href: "chap2",
        type: "text/html",
        text: LocatorText(highlight: "Highlight"));
    expect(await service.locate(locator), isNull);
  });

  test("locate from progression", () async {
    var service = createService(positions: positionsFixtures);

    expect(
        Locator(
            href: "chap1",
            type: "text/html",
            locations: Locations(
                progression: 0.0, totalProgression: 0.0, position: 1)),
        await service.locateProgression(0.0));

    expect(
        Locator(
            href: "chap3",
            type: "text/html",
            title: "Chapter 3",
            locations: Locations(
                progression: 0.0, totalProgression: 2.0 / 8.0, position: 3)),
        await service.locateProgression(0.25));

    var chap5FirstTotalProg = 5.0 / 8.0;
    var chap4FirstTotalProg = 3.0 / 8.0;

    expect(
        Locator(
            href: "chap4",
            type: "text/html",
            locations: Locations(
                progression: (0.4 - chap4FirstTotalProg) /
                    (chap5FirstTotalProg - chap4FirstTotalProg),
                totalProgression: 0.4,
                position: 4)),
        await service.locateProgression(0.4));

    expect(
        Locator(
            href: "chap4",
            type: "text/html",
            locations: Locations(
                progression: (0.55 - chap4FirstTotalProg) /
                    (chap5FirstTotalProg - chap4FirstTotalProg),
                totalProgression: 0.55,
                position: 5)),
        await service.locateProgression(0.55));

    expect(
        Locator(
            href: "chap5",
            type: "text/html",
            locations: Locations(
                progression:
                    (0.9 - chap5FirstTotalProg) / (1.0 - chap5FirstTotalProg),
                totalProgression: 0.9,
                position: 8)),
        await service.locateProgression(0.9));

    expect(
        Locator(
            href: "chap5",
            type: "text/html",
            locations: Locations(
                progression: 1.0, totalProgression: 1.0, position: 8)),
        await service.locateProgression(1.0));
  });

  test("locate from incorrect progression", () async {
    var service = createService(positions: positionsFixtures);
    expect(await service.locateProgression(-0.2), isNull);
    expect(await service.locateProgression(1.2), isNull);
  });

  test("locate from progression with empty positions", () async {
    var service = createService(positions: []);
    expect(await service.locateProgression(0.5), isNull);
  });
}
