// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_opds/mno_opds.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;

void main() {
  test("parse navigation feed", () {
    ParseData parseData = parse("test/opds/nav-feed.atom");
    expect(
        ParseData(
            feed: Feed("OPDS Catalog Root Example", 1,
                Uri.parse("https://example.com"),
                metadata: OpdsMetadata(
                    title: "OPDS Catalog Root Example",
                    modified: parseDate("2010-01-10T10:03:10Z")),
                links: [
                  Link(
                      href: "https://example.com/opds-catalogs/root.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=navigation",
                      rels: {"self"},
                      properties: Properties()),
                  Link(
                      href: "https://example.com/opds-catalogs/root.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=navigation",
                      rels: {"start"})
                ],
                navigation: [
                  Link(
                      href: "https://example.com/opds-catalogs/popular.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=acquisition",
                      title: "Popular Publications",
                      rels: {"http://opds-spec.org/sort/popular"}),
                  Link(
                      href: "https://example.com/opds-catalogs/new.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=acquisition",
                      title: "New Publications",
                      rels: {"http://opds-spec.org/sort/new"}),
                  Link(
                      href: "https://example.com/opds-catalogs/unpopular.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=acquisition",
                      title: "Unpopular Publications",
                      rels: {"subsection"}),
                ]),
            publication: null,
            type: 1),
        parseData);
  });

  test("parse acquisition feed", () {
    ParseData parseData = parse("test/opds/acquisition-feed.atom");
    expect(
        ParseData(
            feed: Feed(
                "Unpopular Publications", 1, Uri.parse("https://example.com"),
                metadata: OpdsMetadata(
                    title: "Unpopular Publications",
                    modified: parseDate("2010-01-10T10:01:11Z")),
                links: [
                  Link(
                      href:
                          "https://example.com/opds-catalogs/vampire.farming.xml",
                      type: "application/atom+xml;profile=opds-catalog;kind=acquisition",
                      rels: {"related"}),
                  Link(
                      href: "https://example.com/opds-catalogs/unpopular.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=acquisition",
                      rels: {"self"}),
                  Link(
                      href: "https://example.com/opds-catalogs/root.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=navigation",
                      rels: {"start"}),
                  Link(
                      href: "https://example.com/opds-catalogs/root.xml",
                      type:
                          "application/atom+xml;profile=opds-catalog;kind=navigation",
                      rels: {"up"})
                ],
                publications: [
                  Publication(
                    manifest: Manifest(
                      metadata: Metadata(
                          identifier:
                              "urn:uuid:6409a00b-7bf2-405e-826c-3fdff0fd0734",
                          localizedTitle:
                              LocalizedString.fromString("Bob, Son of Bob"),
                          modified: parseDate("2010-01-10T10:01:11Z"),
                          published: null,
                          languages: ["en"],
                          subjects: [
                            Subject(
                                localizedName: LocalizedString.fromString(
                                    "FICTION / Men's Adventure"),
                                scheme:
                                    "http://www.bisg.org/standards/bisac_subject/index.html",
                                code: "FIC020000")
                          ],
                          authors: [
                            Contributor(
                                localizedName: LocalizedString.fromString(
                                    "Bob the Recursive"),
                                links: [
                                  Link(
                                      href: "http://opds-spec.org/authors/1285")
                                ])
                          ],
                          description:
                              "The story of the son of the Bob and the gallant part he played in the lives of a man and a woman."),
                      links: [
                        Link(
                            href: "https://example.com/covers/4561.thmb.gif",
                            type: "image/gif",
                            rels: {"http://opds-spec.org/image/thumbnail"}),
                        Link(
                            href:
                                "https://example.com/opds-catalogs/entries/4571.complete.xml",
                            type: "application/atom+xml;type=entry;profile=opds-catalog",
                            title: "Complete Catalog Entry for Bob, Son of Bob",
                            rels: {"alternate"}),
                        Link(
                            href: "https://example.com/content/free/4561.epub",
                            type: "application/epub+zip",
                            rels: {"http://opds-spec.org/acquisition"}),
                        Link(
                            href: "https://example.com/content/free/4561.mobi",
                            type: "application/x-mobipocket-ebook",
                            rels: {"http://opds-spec.org/acquisition"})
                      ],
                      subcollections: {
                        "images": [
                          PublicationCollection(
                            links: [
                              Link(
                                  href:
                                      "https://example.com/covers/4561.lrg.png",
                                  type: "image/png",
                                  rels: {"http://opds-spec.org/image"})
                            ],
                          ),
                        ]
                      },
                    ),
                  ),
                  Publication(
                    manifest: Manifest(
                      metadata: Metadata(
                          identifier:
                              "urn:uuid:7b595b0c-e15c-4755-bf9a-b7019f5c1dab",
                          localizedTitle: LocalizedString.fromString(
                              "Modern Online Philately"),
                          modified: parseDate("2010-01-10T10:01:10Z"),
                          languages: ["en"],
                          authors: [
                            Contributor(
                                localizedName:
                                    LocalizedString.fromString("Stampy McGee"),
                                links: [
                                  Link(
                                      href:
                                          "http://opds-spec.org/authors/21285")
                                ]),
                            Contributor(
                                localizedName:
                                    LocalizedString.fromString("Alice McGee"),
                                links: [
                                  Link(
                                      href:
                                          "http://opds-spec.org/authors/21284")
                                ]),
                            Contributor(
                                localizedName:
                                    LocalizedString.fromString("Harold McGee"),
                                links: [
                                  Link(
                                      href:
                                          "http://opds-spec.org/authors/21283")
                                ])
                          ],
                          publishers: [
                            Contributor(
                                localizedName: LocalizedString.fromString(
                                    "StampMeOnline, Inc."))
                          ],
                          description:
                              "The definitive reference for the web-curious philatelist."),
                      links: [
                        Link(
                            href: "https://example.com/content/buy/11241.epub",
                            type: "application/epub+zip",
                            rels: {"http://opds-spec.org/acquisition/buy"},
                            properties: Properties(otherProperties: {
                              "price": {"currency": "USD", "value": 18.99}
                            }))
                      ],
                      subcollections: {
                        "images": [
                          PublicationCollection(
                            links: [
                              Link(
                                  href:
                                      "https://example.com/covers/11241.lrg.jpg",
                                  type: "image/jpeg",
                                  rels: {"http://opds-spec.org/image"})
                            ],
                          )
                        ]
                      },
                    ),
                  )
                ],
                facets: [
                  Facet(
                      title: "Categories",
                      metadata: OpdsMetadata(title: "Categories"),
                      links: [
                        Link(
                            href: "https://example.com/sci-fi",
                            title: "Science-Fiction",
                            rels: {"http://opds-spec.org/facet"}),
                        Link(
                            href: "https://example.com/romance",
                            title: "Romance",
                            rels: {"http://opds-spec.org/facet"},
                            properties: Properties(
                                otherProperties: {"numberOfItems": 600}))
                      ])
                ]),
            publication: null,
            type: 1),
        parseData);
  });

  test("parse full entry", () {
    ParseData parseData = parse("test/opds/entry.atom");
    expect(
        ParseData(
            feed: null,
            publication: Publication(
              manifest: Manifest(
                metadata: Metadata(
                    identifier: "urn:uuid:6409a00b-7bf2-405e-826c-3fdff0fd0734",
                    localizedTitle:
                        LocalizedString.fromString("Bob, Son of Bob"),
                    modified: parseDate("2010-01-10T10:01:11Z"),
                    languages: ["en"],
                    subjects: [
                      Subject(
                          localizedName: LocalizedString.fromString(
                              "FICTION / Men's Adventure"),
                          scheme:
                              "http://www.bisg.org/standards/bisac_subject/index.html",
                          code: "FIC020000")
                    ],
                    authors: [
                      Contributor(
                          localizedName:
                              LocalizedString.fromString("Bob the Recursive"),
                          links: [
                            Link(href: "http://opds-spec.org/authors/1285")
                          ])
                    ],
                    description:
                        "The story of the son of the Bob and the gallant part he played in the lives of a man and a woman. Bob begins his humble life under the wandering eye of his senile mother, but quickly learns how to escape into the wilder world. Follow Bob as he uncovers his father's past and uses those lessons to improve the lives of others."),
                links: [
                  Link(
                      href: "https://example.com/covers/4561.thmb.gif",
                      type: "image/gif",
                      rels: {"http://opds-spec.org/image/thumbnail"}),
                  Link(
                      href:
                          "https://example.com/opds-catalogs/entries/4571.complete.xml",
                      type: "application/atom+xml;type=entry;profile=opds-catalog",
                      rels: {"self"}),
                  Link(
                      href: "https://example.com/content/free/4561.epub",
                      type: "application/epub+zip",
                      rels: {"http://opds-spec.org/acquisition"}),
                  Link(
                      href: "https://example.com/content/free/4561.mobi",
                      type: "application/x-mobipocket-ebook",
                      rels: {"http://opds-spec.org/acquisition"})
                ],
                subcollections: {
                  "images": [
                    PublicationCollection(links: [
                      Link(
                          href: "https://example.com/covers/4561.lrg.png",
                          type: "image/png",
                          rels: {"http://opds-spec.org/image"})
                    ])
                  ]
                },
              ),
            ),
            type: 1),
        parseData);
  });
}

ParseData parse(String filename, {Uri? url}) => Opds1Parser.parse(
    File(filename).readAsStringSync(), url ?? Uri.parse("https://example.com"));

DateTime? parseDate(String string) => string.iso8601ToDate();
