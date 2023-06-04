// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/href.dart';
import 'package:test/test.dart';

void main() {
  test("normalize to base HREF", () {
    expect(Href("", baseHref: "/folder/").string, "/folder/");
    expect(Href("/", baseHref: "/folder/").string, "/");

    expect(Href("foo/bar.txt", baseHref: "").string, "/foo/bar.txt");
    expect(Href("foo/bar.txt", baseHref: "/").string, "/foo/bar.txt");
    expect(Href("foo/bar.txt", baseHref: "/file.txt").string, "/foo/bar.txt");
    expect(Href("foo/bar.txt", baseHref: "/folder").string, "/foo/bar.txt");
    expect(Href("foo/bar.txt", baseHref: "/folder/").string,
        "/folder/foo/bar.txt");
    expect(
        Href("foo/bar.txt", baseHref: "http://example.com/folder/file.txt")
            .string,
        "http://example.com/folder/foo/bar.txt");
    expect(Href("foo/bar.txt", baseHref: "http://example.com/folder").string,
        "http://example.com/foo/bar.txt");
    expect(Href("foo/bar.txt", baseHref: "http://example.com/folder/").string,
        "http://example.com/folder/foo/bar.txt");

    expect(Href("/foo/bar.txt", baseHref: "").string, "/foo/bar.txt");
    expect(Href("/foo/bar.txt", baseHref: "/").string, "/foo/bar.txt");
    expect(Href("/foo/bar.txt", baseHref: "/file.txt").string, "/foo/bar.txt");
    expect(Href("/foo/bar.txt", baseHref: "/folder").string, "/foo/bar.txt");
    expect(Href("/foo/bar.txt", baseHref: "/folder/").string, "/foo/bar.txt");
    expect(
        Href("/foo/bar.txt", baseHref: "http://example.com/folder/file.txt")
            .string,
        "http://example.com/foo/bar.txt");
    expect(Href("/foo/bar.txt", baseHref: "http://example.com/folder").string,
        "http://example.com/foo/bar.txt");
    expect(Href("/foo/bar.txt", baseHref: "http://example.com/folder/").string,
        "http://example.com/foo/bar.txt");

    expect(Href("../foo/bar.txt", baseHref: "").string, "/foo/bar.txt");
    expect(Href("../foo/bar.txt", baseHref: "/").string, "/foo/bar.txt");
    expect(
        Href("../foo/bar.txt", baseHref: "/file.txt").string, "/foo/bar.txt");
    expect(Href("../foo/bar.txt", baseHref: "/folder").string, "/foo/bar.txt");
    expect(Href("../foo/bar.txt", baseHref: "/folder/").string, "/foo/bar.txt");
    expect(
        Href("../foo/bar.txt", baseHref: "http://example.com/folder/file.txt")
            .string,
        "http://example.com/foo/bar.txt");
    expect(Href("../foo/bar.txt", baseHref: "http://example.com/folder").string,
        "http://example.com/foo/bar.txt");
    expect(
        Href("../foo/bar.txt", baseHref: "http://example.com/folder/").string,
        "http://example.com/foo/bar.txt");

    expect(Href("foo/../bar.txt", baseHref: "").string, "/bar.txt");
    expect(Href("foo/../bar.txt", baseHref: "/").string, "/bar.txt");
    expect(Href("foo/../bar.txt", baseHref: "/file.txt").string, "/bar.txt");
    expect(Href("foo/../bar.txt", baseHref: "/folder").string, "/bar.txt");
    expect(
        Href("foo/../bar.txt", baseHref: "/folder/").string, "/folder/bar.txt");
    expect(
        Href("foo/../bar.txt", baseHref: "http://example.com/folder/file.txt")
            .string,
        "http://example.com/folder/bar.txt");
    expect(Href("foo/../bar.txt", baseHref: "http://example.com/folder").string,
        "http://example.com/bar.txt");
    expect(
        Href("foo/../bar.txt", baseHref: "http://example.com/folder/").string,
        "http://example.com/folder/bar.txt");

    expect(Href("http://absolute.com/foo/bar.txt", baseHref: "/").string,
        "http://absolute.com/foo/bar.txt");
    expect(
        Href("http://absolute.com/foo/bar.txt",
                baseHref: "https://example.com/")
            .string,
        "http://absolute.com/foo/bar.txt");

    // Anchor and query parameters are preserved
    expect(Href("foo/bar.txt#anchor", baseHref: "/").string,
        "/foo/bar.txt#anchor");
    expect(Href("foo/bar.txt?query=param#anchor", baseHref: "/").string,
        "/foo/bar.txt?query=param#anchor");
    expect(Href("/foo/bar.txt?query=param#anchor", baseHref: "/").string,
        "/foo/bar.txt?query=param#anchor");
    expect(
        Href("http://absolute.com/foo/bar.txt?query=param#anchor",
                baseHref: "/")
            .string,
        "http://absolute.com/foo/bar.txt?query=param#anchor");

    expect(Href("foo/bar.txt#anchor", baseHref: "/").string,
        "/foo/bar.txt#anchor");
    expect(Href("foo/bar.txt?query=param#anchor", baseHref: "/").string,
        "/foo/bar.txt?query=param#anchor");
    expect(Href("/foo/bar.txt?query=param#anchor", baseHref: "/").string,
        "/foo/bar.txt?query=param#anchor");
    expect(
        Href("http://absolute.com/foo/bar.txt?query=param#anchor",
                baseHref: "/")
            .string,
        "http://absolute.com/foo/bar.txt?query=param#anchor");

    // HREF that is just an anchor
    expect(Href("#anchor", baseHref: "").string, "/#anchor");
    expect(Href("#anchor", baseHref: "/").string, "/#anchor");
    expect(Href("#anchor", baseHref: "/file.txt").string, "/file.txt#anchor");
    expect(Href("#anchor", baseHref: "/folder").string, "/folder#anchor");
    expect(Href("#anchor", baseHref: "/folder/").string, "/folder/#anchor");
    expect(
        Href("#anchor", baseHref: "http://example.com/folder/file.txt").string,
        "http://example.com/folder/file.txt#anchor");
    expect(Href("#anchor", baseHref: "http://example.com/folder").string,
        "http://example.com/folder#anchor");
    expect(Href("#anchor", baseHref: "http://example.com/folder/").string,
        "http://example.com/folder/#anchor");

    // Percent encoding
    expect(
        Href("http://absolute.com/foo%20bar.txt?query=param#Hello%20world%20%C2%A3500",
                baseHref: "/")
            .string,
        "http://absolute.com/foo bar.txt?query=param#Hello world £500");
    expect(
        Href("http://absolute.com/foo bar.txt?query=param#Hello world £500",
                baseHref: "/")
            .string,
        "http://absolute.com/foo bar.txt?query=param#Hello world £500");
  });

  test("get percent-encoded string", () {
    expect(
        "http://absolute.com/foo%20bar.txt?query=param#Hello%20world%20%C2%A3500",
        Href("http://absolute.com/foo%20bar.txt?query=param#Hello%20world%20%C2%A3500",
                baseHref: "/")
            .percentEncodedString);
    expect(
        "http://absolute.com/foo%20bar.txt?query=param#Hello%20world%20%C2%A3500",
        Href("http://absolute.com/foo bar.txt?query=param#Hello world £500",
                baseHref: "/")
            .percentEncodedString);
  });

  test("get first parameter named x", () {
    var params = [
      QueryParameter("query", value: "param"),
      QueryParameter("fruit", value: "banana"),
      QueryParameter("query", value: "other"),
      QueryParameter("empty", value: null)
    ];

    expect(params.firstNamedOrNull("query"), "param");
    expect(params.firstNamedOrNull("fruit"), "banana");
    expect(params.firstNamedOrNull("empty"), isNull);
    expect(params.firstNamedOrNull("not-found"), isNull);
  });

  test("get all parameters named x", () {
    var params = [
      QueryParameter("query", value: "param"),
      QueryParameter("fruit", value: "banana"),
      QueryParameter("query", value: "other"),
      QueryParameter("empty", value: null)
    ];

    expect(params.allNamed("query"), ["param", "other"]);
    expect(params.allNamed("fruit"), ["banana"]);
    expect(params.allNamed("empty"), []);
    expect(params.allNamed("not-found"), []);
  });
}
