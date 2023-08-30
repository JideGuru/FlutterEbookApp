// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse minimal JSON", () {
    expect(
        PublicationCollection(links: [Link(href: "/link")]),
        PublicationCollection.fromJSON("""{
                "metadata": {},
                "links": [{"href": "/link"}]
            }"""
            .toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        PublicationCollection(metadata: {
          "metadata1": "value"
        }, links: [
          Link(href: "/link")
        ], subcollections: {
          "sub1": [
            PublicationCollection(links: [Link(href: "/sublink")])
          ],
          "sub2": [
            PublicationCollection(
                links: [Link(href: "/sublink1"), Link(href: "/sublink2")])
          ],
          "sub3": [
            PublicationCollection(links: [Link(href: "/sublink3")]),
            PublicationCollection(links: [Link(href: "/sublink4")])
          ]
        }),
        PublicationCollection.fromJSON("""{
                "metadata": {
                    "metadata1": "value"
                },
                "links": [
                    {"href": "/link"}
                ],
                "sub1": {
                    "links": [
                        {"href": "/sublink"}
                    ]
                },
                "sub2": [
                    {"href": "/sublink1"},
                    {"href": "/sublink2"}
                ],
                "sub3": [
                    {
                        "links": [
                            {"href": "/sublink3"}
                        ]
                    },
                    {
                        "links": [
                            {"href": "/sublink4"}
                        ]
                    }
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse null JSON", () {
    expect(PublicationCollection.fromJSON(null), isNull);
  });

  test("parse multiple JSON collections", () {
    expect(
        {
          "sub1": [
            PublicationCollection(links: [Link(href: "/sublink")])
          ],
          "sub2": [
            PublicationCollection(
                links: [Link(href: "/sublink1"), Link(href: "/sublink2")])
          ],
          "sub3": [
            PublicationCollection(links: [Link(href: "/sublink3")]),
            PublicationCollection(links: [Link(href: "/sublink4")])
          ]
        },
        PublicationCollection.collectionsFromJSON("""{
                "sub1": {
                    "links": [
                        {"href": "/sublink"}
                    ]
                },
                "sub2": [
                    {"href": "/sublink1"},
                    {"href": "/sublink2"}
                ],
                "sub3": [
                    {
                        "links": [
                            {"href": "/sublink3"}
                        ]
                    },
                    {
                        "links": [
                            {"href": "/sublink4"}
                        ]
                    }
                ]
            }"""
            .toJsonOrNull()!));
  });

  test("get minimal JSON", () {
    expect(
        """{
                "metadata": {},
                "links": [{"href": "/link", "templated": false}]
            }"""
            .toJsonOrNull(),
        PublicationCollection(links: [Link(href: "/link")]).toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "metadata": {
                    "metadata1": "value"
                },
                "links": [
                    {"href": "/link", "templated": false}
                ],
                "sub1": {
                    "metadata": {},
                    "links": [
                        {"href": "/sublink", "templated": false}
                    ]
                },
                "sub2": {
                    "metadata": {},
                    "links": [
                        {"href": "/sublink1", "templated": false},
                        {"href": "/sublink2", "templated": false}
                    ]
                },
                "sub3": [
                    {
                        "metadata": {},
                        "links": [
                            {"href": "/sublink3", "templated": false}
                        ]
                    },
                    {
                        "metadata": {},
                        "links": [
                            {"href": "/sublink4", "templated": false}
                        ]
                    }
                ]
            }"""
            .toJsonOrNull(),
        PublicationCollection(metadata: {
          "metadata1": "value"
        }, links: [
          Link(href: "/link")
        ], subcollections: {
          "sub1": [
            PublicationCollection(links: [Link(href: "/sublink")])
          ],
          "sub2": [
            PublicationCollection(
                links: [Link(href: "/sublink1"), Link(href: "/sublink2")])
          ],
          "sub3": [
            PublicationCollection(links: [Link(href: "/sublink3")]),
            PublicationCollection(links: [Link(href: "/sublink4")])
          ]
        }).toJson());
  });

  test("get multiple JSON collections", () {
    expect(
        """{
                "sub1": {
                    "metadata": {},
                    "links": [
                        {"href": "/sublink", "templated": false}
                    ]
                },
                "sub2": {
                    "metadata": {},
                    "links": [
                        {"href": "/sublink1", "templated": false},
                        {"href": "/sublink2", "templated": false}
                    ]
                },
                "sub3": [
                    {
                        "metadata": {},
                        "links": [
                            {"href": "/sublink3", "templated": false}
                        ]
                    },
                    {
                        "metadata": {},
                        "links": [
                            {"href": "/sublink4", "templated": false}
                        ]
                    }
                ]
            }"""
            .toJsonOrNull(),
        {
          "sub1": [
            PublicationCollection(links: [Link(href: "/sublink")])
          ],
          "sub2": [
            PublicationCollection(
                links: [Link(href: "/sublink1"), Link(href: "/sublink2")])
          ],
          "sub3": [
            PublicationCollection(links: [Link(href: "/sublink3")]),
            PublicationCollection(links: [Link(href: "/sublink4")])
          ]
        }.toJsonObject());
  });
}
