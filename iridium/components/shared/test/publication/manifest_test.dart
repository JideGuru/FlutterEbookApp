// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse minimal JSON", () {
    expect(
        Manifest(
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [],
            readingOrder: []),
        Manifest.fromJson("""{
                "metadata": {"title": "Title"},
                "links": [],
                "readingOrder": []
            }"""
            .toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Manifest(
            context: ["https://readium.org/webpub-manifest/context.jsonld"],
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"self"})
            ],
            readingOrder: [Link(href: "/chap1.html", type: "text/html")],
            resources: [Link(href: "/image.png", type: "image/png")],
            tableOfContents: [
              Link(href: "/cover.html"),
              Link(href: "/chap1.html")
            ],
            subcollections: {
              "sub": [
                PublicationCollection(links: [Link(href: "/sublink")])
              ]
            }),
        Manifest.fromJson("""{
                "@context": "https://readium.org/webpub-manifest/context.jsonld",
                "metadata": {"title": "Title"},
                "links": [
                    {"href": "/manifest.json", "rel": "self"}
                ],
                "readingOrder": [
                    {"href": "/chap1.html", "type": "text/html"}
                ],
                "resources": [
                    {"href": "/image.png", "type": "image/png"}
                ],
                "toc": [
                    {"href": "/cover.html"},
                    {"href": "/chap1.html"}
                ],
                "sub": {
                    "links": [
                        {"href": "/sublink"}
                    ]
                }
            }"""
            .toJsonOrNull()));
  });

  test("parse JSON {context} as array", () {
    expect(
        Manifest(
            context: ["context1", "context2"],
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"self"})
            ],
            readingOrder: [Link(href: "/chap1.html", type: "text/html")]),
        Manifest.fromJson("""{
                "@context": ["context1", "context2"],
                "metadata": {"title": "Title"},
                "links": [
                    {"href": "/manifest.json", "rel": "self"}
                ],
                "readingOrder": [
                    {"href": "/chap1.html", "type": "text/html"}
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse JSON requires {metadata}", () {
    expect(
        Manifest.fromJson("""{
                "links": [
                    {"href": "/manifest.json", "rel": "self"}
                ],
                "readingOrder": [
                    {"href": "/chap1.html", "type": "text/html"}
                ]
        }"""
            .toJsonOrNull()),
        isNull);
  });

  // {readingOrder} used: be {spine}, so we parse {spine} as a fallback.
  test("parse JSON {spine} as {readingOrder}", () {
    expect(
        Manifest(
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"self"})
            ],
            readingOrder: [
              Link(href: "/chap1.html", type: "text/html")
            ]),
        Manifest.fromJson("""{
                "metadata": {"title": "Title"},
                "links": [
                    {"href": "/manifest.json", "rel": "self"}
                ],
                "spine": [
                    {"href": "/chap1.html", "type": "text/html"}
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse JSON ignores {readingOrder} without {type}", () {
    expect(
        Manifest(
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"self"})
            ],
            readingOrder: [
              Link(href: "/chap1.html", type: "text/html")
            ]),
        Manifest.fromJson("""{
                "metadata": {"title": "Title"},
                "links": [
                    {"href": "/manifest.json", "rel": "self"}
                ],
                "readingOrder": [
                    {"href": "/chap1.html", "type": "text/html"},
                    {"href": "/chap2.html"}
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse JSON ignores {resources} without {type}", () {
    expect(
        Manifest(
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"self"})
            ],
            readingOrder: [
              Link(href: "/chap1.html", type: "text/html")
            ],
            resources: [
              Link(href: "/withtype", type: "text/html")
            ]),
        Manifest.fromJson("""{
                "metadata": {"title": "Title"},
                "links": [
                    {"href": "/manifest.json", "rel": "self"}
                ],
                "readingOrder": [
                    {"href": "/chap1.html", "type": "text/html"}
                ],
                "resources": [
                    {"href": "/withtype", "type": "text/html"},
                    {"href": "/withouttype"}
                ]
            }"""
            .toJsonOrNull()));
  });

  test("get minimal JSON", () {
    expect(
        """{
                "metadata": {"title": {"und": "Title"}, "readingProgression": "auto"},
                "links": [],
                "readingOrder": []
            }"""
            .toJsonOrNull(),
        Manifest(
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [],
            readingOrder: []).toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "@context": ["https://readium.org/webpub-manifest/context.jsonld"],
                "metadata": {"title": {"und": "Title"}, "readingProgression": "auto"},
                "links": [
                    {"href": "/manifest.json", "rel": ["self"], "templated": false}
                ],
                "readingOrder": [
                    {"href": "/chap1.html", "type": "text/html", "templated": false}
                ],
                "resources": [
                    {"href": "/image.png", "type": "image/png", "templated": false}
                ],
                "toc": [
                    {"href": "/cover.html", "templated": false},
                    {"href": "/chap1.html", "templated": false}
                ],
                "sub": {
                    "metadata": {},
                    "links": [
                        {"href": "/sublink", "templated": false}
                    ]
                }
            }"""
            .toJsonOrNull(),
        Manifest(
            context: ["https://readium.org/webpub-manifest/context.jsonld"],
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"self"})
            ],
            readingOrder: [Link(href: "/chap1.html", type: "text/html")],
            resources: [Link(href: "/image.png", type: "image/png")],
            tableOfContents: [
              Link(href: "/cover.html"),
              Link(href: "/chap1.html")
            ],
            subcollections: {
              "sub": [
                PublicationCollection(links: [Link(href: "/sublink")])
              ]
            }).toJson());
  });

  test("self link is replaced when parsing a package", () {
    expect(
        Manifest(
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"alternate"})
            ]),
        Manifest.fromJson(
            """{
                "metadata": {"title": "Title"},
                "links": [
                    {"href": "/manifest.json", "rel": ["self"], "templated": false}
                ]
                }"""
                .toJsonOrNull(),
            packaged: true));
  });

  test("self link is kept when parsing a remote manifest", () {
    expect(
        Manifest(
            metadata:
                Metadata(localizedTitle: LocalizedString.fromString("Title")),
            links: [
              Link(href: "/manifest.json", rels: {"self"})
            ]),
        Manifest.fromJson("""{
                "metadata": {"title": "Title"},
                "links": [
                    {"href": "/manifest.json", "rel": ["self"]}
                ]
                }"""
            .toJsonOrNull()));
  });

  test("href are resolved: root when parsing a package", () {
    var json = """{
            "metadata": {"title": "Title"},
            "links": [
                {"href": "http://example.com/manifest.json", "rel": ["self"], "templated": false}
            ],
            "readingOrder": [
                {"href": "chap1.html", "type": "text/html", "templated": false}
            ]
        }"""
        .toJsonOrNull();

    expect("/chap1.html",
        Manifest.fromJson(json, packaged: true)?.readingOrder.first.href);
  });

  test("href are resolved: self link when parsing a remote manifest", () {
    var json = """{
            "metadata": {"title": "Title"},
            "links": [
                {"href": "http://example.com/directory/manifest.json", "rel": ["self"], "templated": false}
            ],
            "readingOrder": [
                {"href": "chap1.html", "type": "text/html", "templated": false}
            ]
        }"""
        .toJsonOrNull();

    expect("http://example.com/directory/chap1.html",
        Manifest.fromJson(json)?.readingOrder.first.href);
  });
}
