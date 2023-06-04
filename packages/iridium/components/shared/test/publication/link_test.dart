// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("templateParameters works fine", () {
    var href = "/url{?x,hello,y}name{z,y,w}";
    expect(["x", "hello", "y", "z", "w"],
        Link(href: href, templated: true).templateParameters);
  });

  test("expand works fine", () {
    var href = "/url{?x,hello,y}name";
    var parameters = {"x": "aaa", "hello": "Hello, world", "y": "b"};
    expect(
        Link(href: "/url?x=aaa&hello=Hello,%20world&y=bname", templated: false),
        Link(href: href, templated: true).expandTemplate(parameters));
  });

  test("parse minimal JSON", () {
    expect(Link(href: "http://href"),
        Link.fromJSON('{"href": "http://href"}'.toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Link(
            href: "http://href",
            type: "application/pdf",
            templated: true,
            title: "Link Title",
            rels: {"publication", "cover"},
            properties:
                Properties(otherProperties: {"orientation": "landscape"}),
            height: 1024,
            width: 768,
            bitrate: 74.2,
            duration: 45.6,
            languages: ["fr"],
            alternates: [Link(href: "/alternate1"), Link(href: "/alternate2")],
            children: [
              Link(href: "http://child1"),
              Link(href: "http://child2")
            ]),
        Link.fromJSON("""{
                "href": "http://href",
                "type": "application/pdf",
                "templated": true,
                "title": "Link Title",
                "rel": ["publication", "cover"],
                "properties": {
                    "orientation": "landscape"
                },
                "height": 1024,
                "width": 768,
                "bitrate": 74.2,
                "duration": 45.6,
                "language": "fr",
                "alternate": [
                    {"href": "/alternate1"},
                    {"href": "/alternate2"}
                ],
                "children": [
                    {"href": "http://child1"},
                    {"href": "http://child2"}
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse null JSON", () {
    expect(Link.fromJSON(null), isNull);
  });

  test("parse JSON {rel} as single string", () {
    expect(Link.fromJSON('{"href": "a", "rel": "publication"}'.toJsonOrNull()),
        Link(href: "a", rels: {"publication"}));
  });

  test("parse JSON {templated} defaults: false", () {
    var link = Link.fromJSON('{"href": "a"}'.toJsonOrNull());
    expect(link!.templated, isFalse);
  });

  test("parse JSON {templated} as false when null", () {
    var link = Link.fromJSON('{"href": "a", "templated": null}'.toJsonOrNull());
    expect(link!.templated, isFalse);
  });

  test("parse JSON multiple languages", () {
    expect(
        Link.fromJSON('{"href": "a", "language": ["fr", "en"]}'.toJsonOrNull()),
        Link(href: "a", languages: ["fr", "en"]));
  });

  test("parse JSON requires href", () {
    expect(Link.fromJSON('{"type": "application/pdf"}'.toJsonOrNull()), isNull);
  });

  test("parse JSON requires positive width", () {
    var link = Link.fromJSON('{"href": "a", "width": -20}'.toJsonOrNull());
    expect(link!.width, isNull);
  });

  test("parse JSON requires positive height", () {
    var link = Link.fromJSON('{"href": "a", "height": -20}'.toJsonOrNull());
    expect(link!.height, isNull);
  });

  test("parse JSON requires positive bitrate", () {
    var link = Link.fromJSON('{"href": "a", "bitrate": -20}'.toJsonOrNull());
    expect(link!.bitrate, isNull);
  });

  test("parse JSON requires positive duration", () {
    var link = Link.fromJSON('{"href": "a", "duration": -20}'.toJsonOrNull());
    expect(link!.duration, isNull);
  });

  test("parse JSON array", () {
    expect(
        [Link(href: "http://child1"), Link(href: "http://child2")],
        Link.fromJSONArray("""[
                {"href": "http://child1"},
                {"href": "http://child2"}
            ]"""
            .toJsonArrayOrNull()));
  });

  test("parse null JSON array", () {
    expect(<Link>[], Link.fromJSONArray(null));
  });

  test("parse JSON array ignores invalid links", () {
    expect(
        [Link(href: "http://child2")],
        Link.fromJSONArray("""[
                {"title": "Title"},
                {"href": "http://child2"}
            ]"""
            .toJsonArrayOrNull()));
  });

  test("get minimal JSON", () {
    expect('{"href": "http://href", "templated": false}'.toJsonOrNull(),
        Link(href: "http://href").toJson());
  });

  test("get full JSON", () {
    expect(
        """{
                "href": "http://href",
                "type": "application/pdf",
                "templated": true,
                "title": "Link Title",
                "rel": ["publication", "cover"],
                "properties": {
                    "orientation": "landscape"
                },
                "height": 1024,
                "width": 768,
                "bitrate": 74.2,
                "duration": 45.6,
                "language": ["fr"],
                "alternate": [
                    {"href": "/alternate1", "templated": false},
                    {"href": "/alternate2", "templated": false}
                ],
                "children": [
                    {"href": "http://child1", "templated": false},
                    {"href": "http://child2", "templated": false}
                ]
            }"""
            .toJsonOrNull(),
        Link(
            href: "http://href",
            type: "application/pdf",
            templated: true,
            title: "Link Title",
            rels: {"publication", "cover"},
            properties:
                Properties(otherProperties: {"orientation": "landscape"}),
            height: 1024,
            width: 768,
            bitrate: 74.2,
            duration: 45.6,
            languages: ["fr"],
            alternates: [Link(href: "/alternate1"), Link(href: "/alternate2")],
            children: [
              Link(href: "http://child1"),
              Link(href: "http://child2")
            ]).toJson());
  });

  test("get JSON array", () {
    expect(
        """[
                {"href": "http://child1", "templated": false},
                {"href": "http://child2", "templated": false}
            ]"""
            .toJsonArrayOrNull(),
        [Link(href: "http://child1"), Link(href: "http://child2")].toJson());
  });

  test("to URL relative: base URL", () {
    expect("http://host/folder/file.html",
        Link(href: "folder/file.html").toUrl("http://host/"));
  });

  test("to URL relative: base URL with root prefix", () {
    expect("http://host/folder/file.html",
        Link(href: "/file.html").toUrl("http://host/folder/"));
  });

  test("to URL relative: null", () {
    expect("/folder/file.html", Link(href: "folder/file.html").toUrl(null));
  });

  test("to URL with invalid HREF", () {
    expect(Link(href: "").toUrl("http://test.com"), isNull);
  });

  test("to URL with absolute HREF", () {
    expect("http://test.com/folder/file.html",
        Link(href: "http://test.com/folder/file.html").toUrl("http://host/"));
  });

  test("to URL with HREF containing invalid characters", () {
    expect("http://host/folder/Cory%20Doctorow's/a-fc.jpg",
        Link(href: "/Cory Doctorow's/a-fc.jpg").toUrl("http://host/folder/"));
  });

  test("Make a copy after adding the given {properties}", () {
    var link = Link(
        href: "http://href",
        type: "application/pdf",
        templated: true,
        title: "Link Title",
        rels: {"publication", "cover"},
        properties: Properties(otherProperties: {"orientation": "landscape"}),
        height: 1024,
        width: 768,
        bitrate: 74.2,
        duration: 45.6,
        languages: ["fr"],
        alternates: [Link(href: "/alternate1"), Link(href: "/alternate2")],
        children: [Link(href: "http://child1"), Link(href: "http://child2")]);

    expect(
        """{
                "href": "http://href",
                "type": "application/pdf",
                "templated": true,
                "title": "Link Title",
                "rel": ["publication", "cover"],
                "properties": {
                    "orientation": "landscape",
                    "additional": "property"
                },
                "height": 1024,
                "width": 768,
                "bitrate": 74.2,
                "duration": 45.6,
                "language": ["fr"],
                "alternate": [
                    {"href": "/alternate1", "templated": false},
                    {"href": "/alternate2", "templated": false}
                ],
                "children": [
                    {"href": "http://child1", "templated": false},
                    {"href": "http://child2", "templated": false}
                ]
            }"""
            .toJsonOrNull(),
        link.addProperties({"additional": "property"}).toJson());
  });

  test(
      "Find the first index of the {Link} with the given {href} in a list of {Link}",
      () {
    expect([Link(href: "href")].indexOfFirstWithHref("foobar"), isNull);

    expect(
        1,
        [
          Link(href: "href1"),
          Link(href: "href2"),
          Link(href: "href2") // duplicated on purpose
        ].indexOfFirstWithHref("href2"));
  });
}
