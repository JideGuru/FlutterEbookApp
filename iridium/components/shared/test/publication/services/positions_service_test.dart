// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

class MockPositionsService extends PositionsService {
  final List<List<Locator>> _positions;

  MockPositionsService(this._positions);

  @override
  Future<List<List<Locator>>> positionsByReadingOrder() async => _positions;
}

void main() async {
  group("positions_service", () {
    test("get works fine", () async {
      var positions = [
        [
          Locator(
              href: "res",
              type: "application/xml",
              locations: Locations(position: 1, totalProgression: 0.0))
        ],
        [
          Locator(
              href: "chap1",
              type: "image/png",
              locations: Locations(position: 2, totalProgression: 1.0 / 4.0))
        ],
        [
          Locator(
              href: "chap2",
              type: "image/png",
              title: "Chapter 2",
              locations: Locations(position: 3, totalProgression: 3.0 / 4.0)),
          Locator(
              href: "chap2",
              type: "image/png",
              title: "Chapter 2.5",
              locations: Locations(position: 4, totalProgression: 3.0 / 4.0))
        ]
      ];

      var service = MockPositionsService(positions);

      var json = await service
          .get(Link(href: "/~readium/positions"))
          ?.let((it) => it.readAsString())
          .then((result) => result.getOrNull()?.let((it) => it.toJsonOrNull()));

      var total = json?.optNullableInt("total");
      var locators = json?.optJSONArray("positions")?.mapNotNull((locator) =>
          (locator as Map<String, dynamic>?)
              ?.let((it) => Locator.fromJson(it)));

      expect(positions.flatten().length, total);
      expect(positions.flatten(), locators);
    });

    test("helper for ServicesBuilder works fine", () {
      MockPositionsService factory(context) => MockPositionsService([]);
      expect(
          factory,
          ServicesBuilder.create()
              .also((it) => it.positionsServiceFactory = factory)
              .getPositionsServiceFactory());
    });
  });

  group("per_resource_positions_service", () {
    test("Positions from an empty {readingOrder}", () async {
      var service =
          PerResourcePositionsService(readingOrder: [], fallbackMediaType: "");
      expect(0, (await service.positions()).length);
    });

    test("Positions from a {readingOrder} with one resource", () async {
      var service = PerResourcePositionsService(
          readingOrder: [Link(href: "res", type: "image/png")],
          fallbackMediaType: "");

      expect([
        Locator(
            href: "res",
            type: "image/png",
            locations: Locations(position: 1, totalProgression: 0.0))
      ], await service.positions());
    });

    test("Positions from a {readingOrder} with a few resources", () async {
      var service = PerResourcePositionsService(readingOrder: [
        Link(href: "res"),
        Link(href: "chap1", type: "image/png"),
        Link(href: "chap2", type: "image/png", title: "Chapter 2")
      ], fallbackMediaType: "");

      expect([
        Locator(
            href: "res",
            type: "",
            locations: Locations(position: 1, totalProgression: 0.0)),
        Locator(
            href: "chap1",
            type: "image/png",
            locations: Locations(position: 2, totalProgression: 1.0 / 3.0)),
        Locator(
            href: "chap2",
            type: "image/png",
            title: "Chapter 2",
            locations: Locations(position: 3, totalProgression: 2.0 / 3.0))
      ], await service.positions());
    });

    test("{type} fallbacks on the given media type", () async {
      var service = PerResourcePositionsService(
          readingOrder: [Link(href: "res")], fallbackMediaType: "image/*");

      expect([
        Locator(
            href: "res",
            type: "image/*",
            locations: Locations(position: 1, totalProgression: 0.0))
      ], await service.positions());
    });
  });
}
