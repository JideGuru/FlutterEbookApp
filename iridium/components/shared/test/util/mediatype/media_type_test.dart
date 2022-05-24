// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/mediatype.dart';
import 'package:test/test.dart';

void main() {
  test("returns null for invalid types", () {
    expect(MediaType.parse("application"), null);
    expect(MediaType.parse("application/atom+xml/extra"), null);
  });

  test("to string", () {
    expect(
        "application/atom+xml;profile=opds-catalog",
        MediaType.parse("application/atom+xml;profile=opds-catalog")
            ?.toString());
  });

  test("to string is normalized", () {
    expect(
        "application/atom+xml;a=0;profile=OPDS-CATALOG",
        MediaType.parse("APPLICATION/ATOM+XML;PROFILE=OPDS-CATALOG   ;   a=0")
            ?.toString());
    // Parameters are sorted by name
    expect("application/atom+xml;a=0;b=1",
        MediaType.parse("application/atom+xml;a=0;b=1")?.toString());
    expect("application/atom+xml;a=0;b=1",
        MediaType.parse("application/atom+xml;b=1;a=0")?.toString());
  });

  test("get type", () {
    expect("application",
        MediaType.parse("application/atom+xml;profile=opds-catalog")?.type);
    expect("*", MediaType.parse("*/jpeg")?.type);
  });

  test("get subtype", () {
    expect("atom+xml",
        MediaType.parse("application/atom+xml;profile=opds-catalog")?.subtype);
    expect("*", MediaType.parse("image/*")?.subtype);
  });

  test("get parameters", () {
    expect(
        {"type": "entry", "profile": "opds-catalog"},
        MediaType.parse("application/atom+xml;type=entry;profile=opds-catalog")
            ?.parameters);
  });

  test("get empty parameters", () {
    expect(MediaType.parse("application/atom+xml")!.parameters.isEmpty, isTrue);
  });

  test("get parameters with whitespaces", () {
    expect(
        {"type": "entry", "profile": "opds-catalog"},
        MediaType.parse(
                "application/atom+xml    ;    type=entry   ;    profile=opds-catalog   ")
            ?.parameters);
  });

  test("get structured syntax suffix", () {
    expect(MediaType.parse("foo/bar")?.structuredSyntaxSuffix, isNull);
    expect(MediaType.parse("application/zip")?.structuredSyntaxSuffix, isNull);
    expect("+zip",
        MediaType.parse("application/epub+zip")?.structuredSyntaxSuffix);
    expect("+zip", MediaType.parse("foo/bar+json+zip")?.structuredSyntaxSuffix);
  });

  test("get charset", () {
    expect(MediaType.parse("text/html")?.charset, isNull);
    expect(Charsets.utf8, MediaType.parse("text/html;charset=utf-8")?.charset);
    expect(
        Charsets.utf16, MediaType.parse("text/html;charset=utf-16")?.charset);
  });

  test("type, subtype and parameter names are lowercased", () {
    var mediaType =
        MediaType.parse("APPLICATION/ATOM+XML;PROFILE=OPDS-CATALOG");
    expect("application", mediaType?.type);
    expect("atom+xml", mediaType?.subtype);
    expect({"profile": "OPDS-CATALOG"}, mediaType?.parameters);
  });

  test("charset value is uppercased", () {
    expect("UTF-8",
        MediaType.parse("text/html;charset=utf-8")?.parameters["charset"]);
  });

  test("charset value is canonicalized", () {
    expect("US-ASCII",
        MediaType.parse("text/html;charset=ascii")?.parameters["charset"]);
    expect("UNKNOWN",
        MediaType.parse("text/html;charset=unknown")?.parameters["charset"]);
  });

  test("canonicalize media type", () async {
    expect(MediaType.parse("text/html", fileExtension: "html"),
        await MediaType.parse("text/html;charset=utf-8")!.canonicalMediaType());
    expect(
        MediaType.parse("application/atom+xml;profile=opds-catalog"),
        await MediaType.parse(
                "application/atom+xml;profile=opds-catalog;charset=utf-8")!
            .canonicalMediaType());
    expect(
        MediaType.parse("application/unknown;charset=utf-8"),
        await MediaType.parse("application/unknown;charset=utf-8")!
            .canonicalMediaType());
  });

  test("equality", () {
    expect(MediaType.parse("application/atom+xml"),
        MediaType.parse("application/atom+xml"));
    expect(MediaType.parse("application/atom+xml;profile=opds-catalog"),
        MediaType.parse("application/atom+xml;profile=opds-catalog"));
    expect(MediaType.parse("application/atom+xml"),
        isNot(MediaType.parse("application/atom")));
    expect(MediaType.parse("application/atom+xml"),
        isNot(MediaType.parse("text/atom+xml")));
    expect(MediaType.parse("application/atom+xml;profile=opds-catalog"),
        isNot(MediaType.parse("application/atom+xml")));
  });

  test("equality ignores case of type, subtype and parameter names", () {
    expect(MediaType.parse("application/atom+xml;profile=opds-catalog"),
        MediaType.parse("APPLICATION/ATOM+XML;PROFILE=opds-catalog"));
    expect(MediaType.parse("application/atom+xml;profile=opds-catalog"),
        isNot(MediaType.parse("APPLICATION/ATOM+XML;PROFILE=OPDS-CATALOG")));
  });

  test("equality ignores parameters order", () {
    expect(
        MediaType.parse("application/atom+xml;type=entry;profile=opds-catalog"),
        MediaType.parse(
            "application/atom+xml;profile=opds-catalog;type=entry"));
  });

  test("equality ignores charset case", () {
    expect(MediaType.parse("application/atom+xml;charset=utf-8"),
        MediaType.parse("application/atom+xml;charset=UTF-8"));
  });

  test("contains equal media type", () {
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .contains(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
  });

  test("contains must match parameters", () {
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .contains(MediaType.parse("text/html;charset=ascii")),
        isFalse);
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .contains(MediaType.parse("text/html")),
        isFalse);
  });

  test("contains ignores parameters order", () {
    expect(
        MediaType.parse("text/html;charset=utf-8;type=entry")!
            .contains(MediaType.parse("text/html;type=entry;charset=utf-8")),
        isTrue);
  });

  test("contains ignore extra parameters", () {
    expect(
        MediaType.parse("text/html")!
            .contains(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
  });

  test("contains supports wildcards", () {
    expect(
        MediaType.parse("*/*")!
            .contains(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
    expect(
        MediaType.parse("text/*")!
            .contains(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
    expect(
        MediaType.parse("text/*")!.contains(MediaType.parse("application/zip")),
        isFalse);
  });

  test("contains from string", () {
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .containsFromName("text/html;charset=utf-8"),
        isTrue);
  });

  test("matches equal media type", () {
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .matches(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
  });

  test("matches must match parameters", () {
    expect(
        MediaType.parse("text/html;charset=ascii")!
            .matches(MediaType.parse("text/html;charset=utf-8")),
        isFalse);
  });

  test("matches ignores parameters order", () {
    expect(
        MediaType.parse("text/html;charset=utf-8;type=entry")!
            .matches(MediaType.parse("text/html;type=entry;charset=utf-8")),
        isTrue);
  });

  test("matches ignores extra parameters", () {
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .matches(MediaType.parse("text/html;charset=utf-8;extra=param")),
        isTrue);
    expect(
        MediaType.parse("text/html;charset=utf-8;extra=param")!
            .matches(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
  });

  test("matches supports wildcards", () {
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .matches(MediaType.parse("*/*")),
        isTrue);
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .matches(MediaType.parse("text/*")),
        isTrue);
    expect(
        MediaType.parse("application/zip")!.matches(MediaType.parse("text/*")),
        isFalse);
    expect(
        MediaType.parse("*/*")!
            .matches(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
    expect(
        MediaType.parse("text/*")!
            .matches(MediaType.parse("text/html;charset=utf-8")),
        isTrue);
    expect(
        MediaType.parse("text/*")!.matches(MediaType.parse("application/zip")),
        isFalse);
  });

  test("matches from string", () {
    expect(
        MediaType.parse("text/html;charset=utf-8")!
            .matchesFromName("text/html;charset=utf-8"),
        isTrue);
  });

  test("matches any media type", () {
    expect(
        MediaType.parse("text/html")!.matchesAny([
          MediaType.parse("application/zip")!,
          MediaType.parse("text/html;charset=utf-8")!
        ]),
        isTrue);
    expect(
        MediaType.parse("text/html")!.matchesAny([
          MediaType.parse("application/zip")!,
          MediaType.parse("text/plain;charset=utf-8")!
        ]),
        isFalse);
    expect(
        MediaType.parse("text/html")!
            .matchesAnyFromName(["application/zip", "text/html;charset=utf-8"]),
        isTrue);
    expect(
        MediaType.parse("text/html")!.matchesAnyFromName(
            ["application/zip", "text/plain;charset=utf-8"]),
        isFalse);
  });

  test("is ZIP", () {
    expect(MediaType.parse("text/plain")!.isZip, isFalse);
    expect(MediaType.parse("application/zip")!.isZip, isTrue);
    expect(MediaType.parse("application/zip;charset=utf-8")!.isZip, isTrue);
    expect(MediaType.parse("application/epub+zip")!.isZip, isTrue);
    // These media types must be explicitly matched since they don't have any ZIP hint
    expect(MediaType.parse("application/audiobook+lcp")!.isZip, isTrue);
    expect(MediaType.parse("application/pdf+lcp")!.isZip, isTrue);
  });

  test("is JSON", () {
    expect(MediaType.parse("text/plain")!.isJson, isFalse);
    expect(MediaType.parse("application/json")!.isJson, isTrue);
    expect(MediaType.parse("application/json;charset=utf-8")!.isJson, isTrue);
    expect(MediaType.parse("application/opds+json")!.isJson, isTrue);
  });

  test("is OPDS", () {
    expect(MediaType.parse("text/html")!.isOpds, isFalse);
    expect(MediaType.parse("application/atom+xml;profile=opds-catalog")!.isOpds,
        isTrue);
    expect(
        MediaType.parse("application/atom+xml;type=entry;profile=opds-catalog")!
            .isOpds,
        isTrue);
    expect(MediaType.parse("application/opds+json")!.isOpds, isTrue);
    expect(
        MediaType.parse("application/opds-publication+json")!.isOpds, isTrue);
    expect(
        MediaType.parse("application/opds+json;charset=utf-8")!.isOpds, isTrue);
    expect(MediaType.parse("application/opds-authentication+json")!.isOpds,
        isTrue);
  });

  test("is HTML", () {
    expect(MediaType.parse("application/opds+json")!.isHtml, isFalse);
    expect(MediaType.parse("text/html")!.isHtml, isTrue);
    expect(MediaType.parse("application/xhtml+xml")!.isHtml, isTrue);
    expect(MediaType.parse("text/html;charset=utf-8")!.isHtml, isTrue);
  });

  test("is bitmap", () {
    expect(MediaType.parse("text/html")!.isBitmap, isFalse);
    expect(MediaType.parse("image/bmp")!.isBitmap, isTrue);
    expect(MediaType.parse("image/gif")!.isBitmap, isTrue);
    expect(MediaType.parse("image/jpeg")!.isBitmap, isTrue);
    expect(MediaType.parse("image/png")!.isBitmap, isTrue);
    expect(MediaType.parse("image/tiff")!.isBitmap, isTrue);
    expect(MediaType.parse("image/tiff")!.isBitmap, isTrue);
    expect(MediaType.parse("image/tiff;charset=utf-8")!.isBitmap, isTrue);
  });

  test("is audio", () {
    expect(MediaType.parse("text/html")!.isAudio, isFalse);
    expect(MediaType.parse("audio/unknown")!.isAudio, isTrue);
    expect(MediaType.parse("audio/mpeg;param=value")!.isAudio, isTrue);
  });

  test("is video", () {
    expect(MediaType.parse("text/html")!.isVideo, isFalse);
    expect(MediaType.parse("video/unknown")!.isVideo, isTrue);
    expect(MediaType.parse("video/mpeg;param=value")!.isVideo, isTrue);
  });

  test("is RWPM", () {
    expect(MediaType.parse("text/html")!.isRwpm, isFalse);
    expect(MediaType.parse("application/audiobook+json")!.isRwpm, isTrue);
    expect(MediaType.parse("application/divina+json")!.isRwpm, isTrue);
    expect(MediaType.parse("application/webpub+json")!.isRwpm, isTrue);
    expect(MediaType.parse("application/webpub+json;charset=utf-8")!.isRwpm,
        isTrue);
  });

  test("is publication", () {
    expect(MediaType.parse("text/html")!.isPublication, isFalse);
    expect(MediaType.parse("application/audiobook+zip")!.isPublication, isTrue);
    expect(
        MediaType.parse("application/audiobook+json")!.isPublication, isTrue);
    expect(MediaType.parse("application/audiobook+lcp")!.isPublication, isTrue);
    expect(
        MediaType.parse("application/audiobook+json;charset=utf-8")!
            .isPublication,
        isTrue);
    expect(MediaType.parse("application/divina+zip")!.isPublication, isTrue);
    expect(MediaType.parse("application/divina+json")!.isPublication, isTrue);
    expect(MediaType.parse("application/webpub+zip")!.isPublication, isTrue);
    expect(MediaType.parse("application/webpub+json")!.isPublication, isTrue);
    expect(MediaType.parse("application/vnd.comicbook+zip")!.isPublication,
        isTrue);
    expect(MediaType.parse("application/epub+zip")!.isPublication, isTrue);
    expect(MediaType.parse("application/lpf+zip")!.isPublication, isTrue);
    expect(MediaType.parse("application/pdf")!.isPublication, isTrue);
    expect(MediaType.parse("application/pdf+lcp")!.isPublication, isTrue);
    expect(
        MediaType.parse("application/x.readium.w3c.wpub+json")!.isPublication,
        isTrue);
    expect(MediaType.parse("application/x.readium.zab+zip")!.isPublication,
        isTrue);
  });
}
