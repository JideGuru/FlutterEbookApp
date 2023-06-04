// // Copyright (c) 2021 Mantano. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
//
// import 'dart:typed_data';
//
// import 'package:dartx/dartx.dart';
// import 'package:dfunc/dfunc.dart';
// import 'package:mno_shared/fetcher.dart';
// import 'package:mno_shared/publication.dart';
// import 'package:mno_streamer/src/epub/epub_positions_service.dart';
// import 'package:test/test.dart';
//
// class MockFetcher extends Fetcher {
//   final List<(int, Link)> readingOrder;
//
//   MockFetcher(this.readingOrder);
//
//   @override
//   Future<void> close() async {}
//
//   @override
//   Resource get(Link link) => MockResource(this, link);
//
//   @override
//   Future<List<Link>> links() async => [];
// }
//
// class MockResource extends Resource {
//   final MockFetcher fetcher;
//   final Link _link;
//
//   MockResource(this.fetcher, this._link);
//
//   (int, Link)? findResource(String relativePath) => fetcher.readingOrder
//       .firstOrNullWhere((item1, item2) => item2.href == relativePath);
//
//   @override
//   Future<void> close() async {}
//
//   @override
//   Future<ResourceTry<int>> length() async =>
//       findResource(_link.href)?.let((item1, item2) => ResourceTry.success(item1)) ??
//       ResourceTry.failure(ResourceException.notFound);
//
//   @override
//   Future<Link> link() async => _link;
//
//   @override
//   Future<ResourceTry<ByteData>> read({IntRange? range}) async =>
//       ResourceTry.success(ByteData(0));
// }
//
// void main() {
//   EpubPositionsService createService(
//           {EpubLayout? layout,
//           required List<Product2<int, Link>> readingOrder,
//           int reflowablePositionLength = 50}) =>
//       EpubPositionsService(
//           readingOrder: readingOrder.map((it) => it.item2).toList(),
//           fetcher: MockFetcher(readingOrder),
//           presentation: Presentation(layout: layout),
//           reflowablePositionLength: reflowablePositionLength);
//
//   Properties createProperties(
//       {EpubLayout? layout, int? encryptedOriginalLength}) {
//     var properties = {
//       if (layout != null) "layout": layout.value,
//       if (encryptedOriginalLength != null)
//         "encrypted": {
//           "algorithm": "algo",
//           "originalLength": encryptedOriginalLength
//         },
//     };
//     return Properties(otherProperties: properties);
//   }
//
//   test("Positions from an empty {readingOrder}", () async {
//     var service = createService(readingOrder: []);
//     expect(0, (await service.positions()).length);
//   });
//
//   test("Positions  from a {readingOrder} with one resource", () async {
//     var service = createService(readingOrder: [
//       Product2(1, Link(href: "res", type: "application/xml"))
//     ]);
//     expect([
//       Locator(
//           href: "res",
//           type: "application/xml",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0))
//     ], (await service.positions()));
//   });
//
//   test("Positions from a {readingOrder} with a few resources", () async {
//     var service = createService(readingOrder: [
//       Product2(1, Link(href: "res")),
//       Product2(2, Link(href: "chap1", type: "application/xml")),
//       Product2(2, Link(href: "chap2", type: "text/html", title: "Chapter 2"))
//     ]);
//
//     expect([
//       Locator(
//           href: "res",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0)),
//       Locator(
//           href: "chap1",
//           type: "application/xml",
//           locations: Locations(
//               progression: 0.0, position: 2, totalProgression: 1.0 / 3.0)),
//       Locator(
//           href: "chap2",
//           type: "text/html",
//           title: "Chapter 2",
//           locations: Locations(
//               progression: 0.0, position: 3, totalProgression: 2.0 / 3.0))
//     ], containsAll(await service.positions()));
//   });
//
//   test("{type} fallbacks on text-html", () async {
//     var service = createService(readingOrder: [
//       Product2(
//           1,
//           Link(
//               href: "chap1",
//               properties: createProperties(layout: EpubLayout.reflowable))),
//       Product2(
//           1,
//           Link(
//               href: "chap2",
//               properties: createProperties(layout: EpubLayout.fixed)))
//     ]);
//
//     expect([
//       Locator(
//           href: "chap1",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0)),
//       Locator(
//           href: "chap2",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 2, totalProgression: 0.5))
//     ], await service.positions());
//   });
//
//   test("One position per fixed-layout resources", () async {
//     var service = createService(layout: EpubLayout.fixed, readingOrder: [
//       Product2(10000, Link(href: "res")),
//       Product2(20000, Link(href: "chap1", type: "application/xml")),
//       Product2(
//           40000, Link(href: "chap2", type: "text/html", title: "Chapter 2"))
//     ]);
//
//     expect([
//       Locator(
//           href: "res",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0)),
//       Locator(
//           href: "chap1",
//           type: "application/xml",
//           locations: Locations(
//               progression: 0.0, position: 2, totalProgression: 1.0 / 3.0)),
//       Locator(
//           href: "chap2",
//           type: "text/html",
//           title: "Chapter 2",
//           locations: Locations(
//               progression: 0.0, position: 3, totalProgression: 2.0 / 3.0))
//     ], await service.positions());
//   });
//
//   test("Split reflowable resources by the provided number of bytes", () async {
//     var service = createService(
//         layout: EpubLayout.reflowable,
//         readingOrder: [
//           Product2(0, Link(href: "chap1")),
//           Product2(49, Link(href: "chap2", type: "application/xml")),
//           Product2(
//               50, Link(href: "chap3", type: "text/html", title: "Chapter 3")),
//           Product2(51, Link(href: "chap4")),
//           Product2(120, Link(href: "chap5"))
//         ],
//         reflowablePositionLength: 50);
//
//     expect([
//       Locator(
//           href: "chap1",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0)),
//       Locator(
//           href: "chap2",
//           type: "application/xml",
//           locations: Locations(
//               progression: 0.0, position: 2, totalProgression: 1.0 / 8.0)),
//       Locator(
//           href: "chap3",
//           type: "text/html",
//           title: "Chapter 3",
//           locations: Locations(
//               progression: 0.0, position: 3, totalProgression: 2.0 / 8.0)),
//       Locator(
//           href: "chap4",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.0, position: 4, totalProgression: 3.0 / 8.0)),
//       Locator(
//           href: "chap4",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.5, position: 5, totalProgression: 4.0 / 8.0)),
//       Locator(
//           href: "chap5",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.0, position: 6, totalProgression: 5.0 / 8.0)),
//       Locator(
//           href: "chap5",
//           type: "text/html",
//           locations: Locations(
//               progression: 1.0 / 3.0,
//               position: 7,
//               totalProgression: 6.0 / 8.0)),
//       Locator(
//           href: "chap5",
//           type: "text/html",
//           locations: Locations(
//               progression: 2.0 / 3.0, position: 8, totalProgression: 7.0 / 8.0))
//     ], await service.positions());
//   });
//
//   test("{layout} fallbacks to reflowable", () async {
//     // We check this by verifying that the resource will be split every 1024 bytes
//     var service = createService(
//         layout: null,
//         readingOrder: [Product2(60, Link(href: "chap1"))],
//         reflowablePositionLength: 50);
//
//     expect([
//       Locator(
//           href: "chap1",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0)),
//       Locator(
//           href: "chap1",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.5, position: 2, totalProgression: 0.5))
//     ], await service.positions());
//   });
//
//   test("Positions from publication with mixed layouts", () async {
//     var service = createService(
//         layout: EpubLayout.fixed,
//         readingOrder: [
//           Product2(20000, Link(href: "chap1")),
//           Product2(
//               60,
//               Link(
//                   href: "chap2",
//                   properties: createProperties(layout: EpubLayout.reflowable))),
//           Product2(
//               20000,
//               Link(
//                   href: "chap3",
//                   properties: createProperties(layout: EpubLayout.fixed)))
//         ],
//         reflowablePositionLength: 50);
//
//     expect([
//       Locator(
//           href: "chap1",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0)),
//       Locator(
//           href: "chap2",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.0, position: 2, totalProgression: 1.0 / 4.0)),
//       Locator(
//           href: "chap2",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.5, position: 3, totalProgression: 2.0 / 4.0)),
//       Locator(
//           href: "chap3",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.0, position: 4, totalProgression: 3.0 / 4.0))
//     ], await service.positions());
//   });
//
//   test(
//       "Use the encrypted {originalLength} if available, instead of the {Container}'s file length",
//       () async {
//     var service = createService(
//         layout: EpubLayout.reflowable,
//         readingOrder: [
//           Product2(
//               60,
//               Link(
//                   href: "chap1",
//                   properties: createProperties(encryptedOriginalLength: 20))),
//           Product2(60, Link(href: "chap2"))
//         ],
//         reflowablePositionLength: 50);
//
//     expect([
//       Locator(
//           href: "chap1",
//           type: "text/html",
//           locations:
//               Locations(progression: 0.0, position: 1, totalProgression: 0.0)),
//       Locator(
//           href: "chap2",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.0, position: 2, totalProgression: 1.0 / 3.0)),
//       Locator(
//           href: "chap2",
//           type: "text/html",
//           locations: Locations(
//               progression: 0.5, position: 3, totalProgression: 2.0 / 3.0))
//     ], await service.positions());
//   });
// }
