// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

class MockPositionsService extends PositionsService {
  final List<List<Locator>> _positions;

  MockPositionsService(this._positions);

  @override
  Future<List<List<Locator>>> positionsByReadingOrder() async => _positions;
}

class MockPublicationService extends PublicationService {
  @override
  Type get serviceType => PositionsService;

  @override
  Resource get(Link link) {
    expect(link.templated, isFalse);
    expect("param1=a&param2=b", link.href.substringAfter("?"));
    return StringResource(link, () async => "test passed");
  }
}

void main() {
  var fixtures = Fixtures(path: "test_resources/format");
  Future<Publication> parseAt(String path) async => Publication(
      manifest: Manifest.fromJson(
          (await fixtures.fileAt(path).readAsString()).toJsonOrNull())!);

  Publication createPublication(
          {String title = "Title",
          String language = "en",
          ReadingProgression readingProgression = ReadingProgression.auto,
          List<Link> links = const [],
          List<Link> readingOrder = const [],
          List<Link> resources = const [],
          ServicesBuilder? servicesBuilder}) =>
      Publication(
          manifest: Manifest(
              metadata: Metadata(
                  localizedTitle: LocalizedString.fromString(title),
                  languages: [language],
                  readingProgression: readingProgression),
              links: links,
              readingOrder: readingOrder,
              resources: resources),
          servicesBuilder: servicesBuilder ?? ServicesBuilder.create());

  test("get the type computed from the manifest content", () async {
    expect(TYPE.audio, (await parseAt("audiobook.json")).type);
    expect(TYPE.divina, (await parseAt("divina.json")).type);
    expect(TYPE.webpub, (await parseAt("webpub.json")).type);
    expect(TYPE.webpub, (await parseAt("opds2-publication.json")).type);
  });

  test("get the default empty {positions}", () async {
    expect([], await createPublication().positions());
  });

  test("get the {positions} computed from the {PositionsService}", () async {
    expect(
        [Locator(href: "locator", type: "")],
        await createPublication(
            servicesBuilder: ServicesBuilder.create(
                positions: (context) => MockPositionsService([
                      [Locator(href: "locator", type: "")]
                    ]))).let((it) => it.positions()));
  });

  test("get the {positionsByReadingOrder} computed from the {PositionsService}",
      () async {
    expect(
        [
          [
            Locator(href: "res1", type: "text/html", title: "Loc A"),
            Locator(href: "res1", type: "text/html", title: "Loc B")
          ],
          [Locator(href: "res2", type: "text/html", title: "Loc B")]
        ],
        await createPublication(
            servicesBuilder: ServicesBuilder.create(
                positions: (context) => MockPositionsService([
                      [
                        Locator(
                            href: "res1", type: "text/html", title: "Loc A"),
                        Locator(href: "res1", type: "text/html", title: "Loc B")
                      ],
                      [Locator(href: "res2", type: "text/html", title: "Loc B")]
                    ]))).let((it) => it.positionsByReadingOrder()));
  });

  test("set {self} link", () {
    var publication = createPublication();
    publication.setSelfLink("http://manifest.json");

    expect("http://manifest.json", publication.linkWithRel("self")?.href);
  });

  test("set {self} link replaces existing {self} link", () {
    var publication = createPublication(links: [
      Link(href: "previous", rels: {"self"})
    ]);
    publication.setSelfLink("http://manifest.json");

    expect("http://manifest.json", publication.linkWithRel("self")?.href);
  });

  test("get {baseUrl} computes the URL from the {self} link", () {
    var publication = createPublication(links: [
      Link(href: "http://domain.com/path/manifest.json", rels: {"self"})
    ]);
    expect(Uri.parse("http://domain.com/path/"), publication.baseUrl);
  });

  test("get {baseUrl} when missing", () {
    expect(createPublication().baseUrl, isNull);
  });

  test("get {baseUrl} when it's a root", () {
    var publication = createPublication(links: [
      Link(href: "http://domain.com/manifest.json", rels: {"self"})
    ]);
    expect(Uri.parse("http://domain.com/"), publication.baseUrl);
  });

  test("find the first {Link} with the given {rel}", () {
    var link1 = Link(href: "found", rels: {"rel1"});
    var link2 = Link(href: "found", rels: {"rel2"});
    var link3 = Link(href: "found", rels: {"rel3"});
    var publication = createPublication(
        links: [Link(href: "other"), link1],
        readingOrder: [Link(href: "other"), link2],
        resources: [Link(href: "other"), link3]);

    expect(link1, publication.linkWithRel("rel1"));
    expect(link2, publication.linkWithRel("rel2"));
    expect(link3, publication.linkWithRel("rel3"));
  });

  test("find the first {Link} with the given {rel} when missing", () {
    expect(createPublication().linkWithRel("foobar"), isNull);
  });

  test("find all the links with the given {rel}", () {
    var publication = createPublication(links: [
      Link(href: "l1"),
      Link(href: "l2", rels: {"rel1"})
    ], readingOrder: [
      Link(href: "l3"),
      Link(href: "l4", rels: {"rel1"})
    ], resources: [
      Link(href: "l5", alternates: [
        Link(href: "alternate", rels: {"rel1"})
      ]),
      Link(href: "l6", rels: {"rel1"})
    ]);

    expect([
      Link(href: "l4", rels: {"rel1"}),
      Link(href: "l6", rels: {"rel1"}),
      Link(href: "l2", rels: {"rel1"})
    ], publication.linksWithRel("rel1"));
  });

  test("find all the links with the given {rel} when not found", () {
    expect(createPublication().linksWithRel("foobar").isEmpty, isTrue);
  });

  test("find the first {Link} with the given {href}", () {
    var link1 = Link(href: "href1");
    var link2 = Link(href: "href2");
    var link3 = Link(href: "href3");
    var link4 = Link(href: "href4");
    var link5 = Link(href: "href5");
    var publication = createPublication(links: [
      Link(href: "other"),
      link1
    ], readingOrder: [
      Link(href: "other", alternates: [
        Link(href: "alt1", alternates: [link2])
      ]),
      link3
    ], resources: [
      Link(href: "other", children: [
        Link(href: "alt1", children: [link4])
      ]),
      link5
    ]);

    expect(link1, publication.linkWithHref("href1"));
    expect(link2, publication.linkWithHref("href2"));
    expect(link3, publication.linkWithHref("href3"));
    expect(link4, publication.linkWithHref("href4"));
    expect(link5, publication.linkWithHref("href5"));
  });

  test("find the first {Link} with the given {href} without query parameters",
      () {
    var link = Link(href: "http://example.com/index.html");
    var publication =
        createPublication(readingOrder: [Link(href: "other"), link]);

    expect(
        link,
        publication.linkWithHref(
            "http://example.com/index.html?title=titre&action=edit"));
  });

  test("find the first {Link} with the given {href} without anchor", () {
    var link = Link(href: "http://example.com/index.html");
    var publication =
        createPublication(readingOrder: [Link(href: "other"), link]);

    expect(
        link, publication.linkWithHref("http://example.com/index.html#sec1"));
  });

  test("find the first {Link} with the given {href} when missing", () {
    expect(createPublication().linkWithHref("foobar"), isNull);
  });

  test("get method passes on href parameters to services", () async {
    var service = MockPublicationService();

    var link = Link(href: "link?param1=a&param2=b");
    var publication = createPublication(resources: [
      link
    ], servicesBuilder: ServicesBuilder.create(positions: (config) => service));
    expect("test passed",
        (await publication.get(link).readAsString()).getOrNull());
  });

  test("find the first resource {Link} with the given {href}", () {
    var link1 = Link(href: "href1");
    var link2 = Link(href: "href2");
    var link3 = Link(href: "href3");
    var publication = createPublication(
        links: [Link(href: "other"), link1],
        readingOrder: [Link(href: "other"), link2],
        resources: [Link(href: "other"), link3]);

    expect(publication.resourceWithHref("href1"), isNull);
    expect(link2, publication.resourceWithHref("href2"));
    expect(link3, publication.resourceWithHref("href3"));
  });

  test("find the first resource {Link} with the given {href} when missing", () {
    expect(createPublication().resourceWithHref("foobar"), isNull);
  });

  test("find the cover {Link}", () {
    var coverLink = Link(href: "cover", rels: {"cover"});
    var publication = createPublication(
        links: [Link(href: "other"), coverLink],
        readingOrder: [Link(href: "other")],
        resources: [Link(href: "other")]);

    expect(coverLink, publication.coverLink);
  });

  test("find the cover {Link} when missing", () {
    var publication = createPublication(
        links: [Link(href: "other")],
        readingOrder: [Link(href: "other")],
        resources: [Link(href: "other")]);

    expect(publication.coverLink, isNull);
  });
}

/*

 */
