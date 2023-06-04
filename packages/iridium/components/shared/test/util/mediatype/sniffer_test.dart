// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/data.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:test/test.dart';

import '../../fixtures.dart';

void main() {
  var fixtures = Fixtures(path: "test_resources/format");

  test("sniff ignores extension case", () async {
    expect(MediaType.epub, await MediaType.ofSingleHint(fileExtension: "EPUB"));
  });

  test("sniff ignores media type case", () async {
    expect(MediaType.epub,
        await MediaType.ofSingleHint(mediaType: "APPLICATION/EPUB+ZIP"));
  });

  test("sniff ignores media type extra parameters", () async {
    expect(
        MediaType.epub,
        await MediaType.ofSingleHint(
            mediaType: "application/epub+zip;param=value"));
  });

  test("sniff from metadata", () async {
    expect(await MediaType.ofSingleHint(fileExtension: null), isNull);
    expect(MediaType.readiumAudiobook,
        await MediaType.ofSingleHint(fileExtension: "audiobook"));
    expect(await MediaType.ofSingleHint(mediaType: null), isNull);
    expect(MediaType.readiumAudiobook,
        await MediaType.ofSingleHint(mediaType: "application/audiobook+zip"));
    expect(MediaType.readiumAudiobook,
        await MediaType.ofSingleHint(mediaType: "application/audiobook+zip"));
    expect(
        MediaType.readiumAudiobook,
        await MediaType.of(
            mediaTypes: ["application/audiobook+zip"],
            fileExtensions: ["audiobook"]));
    expect(
        MediaType.readiumAudiobook,
        await MediaType.of(
            mediaTypes: ["application/audiobook+zip"],
            fileExtensions: ["audiobook"]));
  });

  test("sniff from a file", () async {
    expect(MediaType.readiumAudiobookManifest,
        await MediaType.ofFile(fixtures.fileAt("audiobook.json")));
  });

  test("sniff from bytes", () async {
    expect(
        MediaType.readiumAudiobookManifest,
        await MediaType.ofBytes(() => fixtures
            .fileAt("audiobook.json")
            .readAsBytes()
            .then((value) => value.toByteData())));
  });

  test("sniff unknown format", () async {
    expect(await MediaType.ofSingleHint(mediaType: "invalid"), isNull);
    expect(await MediaType.ofFile(fixtures.fileAt("unknown")), isNull);
  });

  test("sniff falls back on parsing the given media type if it's valid",
      () async {
    var expected = MediaType.parse("fruit/grapes");
    expect(expected,
        equals(await MediaType.ofSingleHint(mediaType: "fruit/grapes")));
    expect(expected, await MediaType.ofSingleHint(mediaType: "fruit/grapes"));
    expect(
        expected, await MediaType.of(mediaTypes: ["invalid", "fruit/grapes"]));
    expect(expected,
        await MediaType.of(mediaTypes: ["fruit/grapes", "vegetable/brocoli"]));
  });

  test("sniff audiobook", () async {
    expect(MediaType.readiumAudiobook,
        await MediaType.ofSingleHint(fileExtension: "audiobook"));
    expect(MediaType.readiumAudiobook,
        await MediaType.ofSingleHint(mediaType: "application/audiobook+zip"));
    expect(MediaType.readiumAudiobook,
        await MediaType.ofFile(fixtures.fileAt("audiobook-package.unknown")));
  });

  test("sniff audiobook manifest", () async {
    expect(MediaType.readiumAudiobookManifest,
        await MediaType.ofSingleHint(mediaType: "application/audiobook+json"));
    expect(MediaType.readiumAudiobookManifest,
        await MediaType.ofFile(fixtures.fileAt("audiobook.json")));
    expect(MediaType.readiumAudiobookManifest,
        await MediaType.ofFile(fixtures.fileAt("audiobook-wrongtype.json")));
  });

  test("sniff BMP", () async {
    expect(MediaType.bmp, await MediaType.ofSingleHint(fileExtension: "bmp"));
    expect(MediaType.bmp, await MediaType.ofSingleHint(fileExtension: "dib"));
    expect(MediaType.bmp, await MediaType.ofSingleHint(mediaType: "image/bmp"));
    expect(
        MediaType.bmp, await MediaType.ofSingleHint(mediaType: "image/x-bmp"));
  });

  test("sniff CBZ", () async {
    expect(MediaType.cbz, await MediaType.ofSingleHint(fileExtension: "cbz"));
    expect(
        MediaType.cbz,
        await MediaType.ofSingleHint(
            mediaType: "application/vnd.comicbook+zip"));
    expect(MediaType.cbz,
        await MediaType.ofSingleHint(mediaType: "application/x-cbz"));
    expect(MediaType.cbz,
        await MediaType.ofSingleHint(mediaType: "application/x-cbr"));
    expect(
        MediaType.cbz, await MediaType.ofFile(fixtures.fileAt("cbz.unknown")));
  });

  test("sniff DiViNa", () async {
    expect(MediaType.divina,
        await MediaType.ofSingleHint(fileExtension: "divina"));
    expect(MediaType.divina,
        await MediaType.ofSingleHint(mediaType: "application/divina+zip"));
    expect(MediaType.divina,
        await MediaType.ofFile(fixtures.fileAt("divina-package.unknown")));
  });

  test("sniff DiViNa manifest", () async {
    expect(MediaType.divinaManifest,
        await MediaType.ofSingleHint(mediaType: "application/divina+json"));
    expect(MediaType.divinaManifest,
        await MediaType.ofFile(fixtures.fileAt("divina.json")));
  });

  test("sniff EPUB", () async {
    expect(MediaType.epub, await MediaType.ofSingleHint(fileExtension: "epub"));
    expect(MediaType.epub,
        await MediaType.ofSingleHint(mediaType: "application/epub+zip"));
    expect(MediaType.epub,
        await MediaType.ofFile(fixtures.fileAt("epub.unknown")));
  });

  test("sniff GIF", () async {
    expect(MediaType.gif, await MediaType.ofSingleHint(fileExtension: "gif"));
    expect(MediaType.gif, await MediaType.ofSingleHint(mediaType: "image/gif"));
  });

  test("sniff HTML", () async {
    expect(MediaType.html, await MediaType.ofSingleHint(fileExtension: "htm"));
    expect(MediaType.html, await MediaType.ofSingleHint(fileExtension: "html"));
    expect(MediaType.html, await MediaType.ofSingleHint(fileExtension: "xht"));
    expect(
        MediaType.html, await MediaType.ofSingleHint(fileExtension: "xhtml"));
    expect(
        MediaType.html, await MediaType.ofSingleHint(mediaType: "text/html"));
    expect(MediaType.html,
        await MediaType.ofSingleHint(mediaType: "application/xhtml+xml"));
    expect(MediaType.html,
        await MediaType.ofFile(fixtures.fileAt("html.unknown")));
    expect(MediaType.html,
        await MediaType.ofFile(fixtures.fileAt("xhtml.unknown")));
  });

  test("sniff JPEG", () async {
    expect(MediaType.jpeg, await MediaType.ofSingleHint(fileExtension: "jpg"));
    expect(MediaType.jpeg, await MediaType.ofSingleHint(fileExtension: "jpeg"));
    expect(MediaType.jpeg, await MediaType.ofSingleHint(fileExtension: "jpe"));
    expect(MediaType.jpeg, await MediaType.ofSingleHint(fileExtension: "jif"));
    expect(MediaType.jpeg, await MediaType.ofSingleHint(fileExtension: "jfif"));
    expect(MediaType.jpeg, await MediaType.ofSingleHint(fileExtension: "jfi"));
    expect(
        MediaType.jpeg, await MediaType.ofSingleHint(mediaType: "image/jpeg"));
  });

  test("sniff OPDS 1 feed", () async {
    expect(
        MediaType.opds1,
        await MediaType.ofSingleHint(
            mediaType: "application/atom+xml;profile=opds-catalog"));
    expect(MediaType.opds1,
        await MediaType.ofFile(fixtures.fileAt("opds1-feed.unknown")));
  });

  test("sniff OPDS 1 entry", () async {
    expect(
        MediaType.opds1Entry,
        await MediaType.ofSingleHint(
            mediaType: "application/atom+xml;type=entry;profile=opds-catalog"));
    expect(MediaType.opds1Entry,
        await MediaType.ofFile(fixtures.fileAt("opds1-entry.unknown")));
  });

  test("sniff OPDS 2 feed", () async {
    expect(MediaType.opds2,
        await MediaType.ofSingleHint(mediaType: "application/opds+json"));
    expect(MediaType.opds2,
        await MediaType.ofFile(fixtures.fileAt("opds2-feed.json")));
  });

  test("sniff OPDS 2 publication", () async {
    expect(
        MediaType.opds2Publication,
        await MediaType.ofSingleHint(
            mediaType: "application/opds-publication+json"));
    expect(MediaType.opds2Publication,
        await MediaType.ofFile(fixtures.fileAt("opds2-publication.json")));
  });

  test("sniff OPDS authentication document", () async {
    expect(
        MediaType.opdsAuthentication,
        await MediaType.ofSingleHint(
            mediaType: "application/opds-authentication+json"));
    expect(
        MediaType.opdsAuthentication,
        await MediaType.ofSingleHint(
            mediaType: "application/vnd.opds.authentication.v1.0+json"));
    expect(MediaType.opdsAuthentication,
        await MediaType.ofFile(fixtures.fileAt("opds-authentication.json")));
  });

  test("sniff LCP protected audiobook", () async {
    expect(MediaType.lcpProtectedAudiobook,
        await MediaType.ofSingleHint(fileExtension: "lcpa"));
    expect(MediaType.lcpProtectedAudiobook,
        await MediaType.ofSingleHint(mediaType: "application/audiobook+lcp"));
    expect(MediaType.lcpProtectedAudiobook,
        await MediaType.ofFile(fixtures.fileAt("audiobook-lcp.unknown")));
  });

  test("sniff LCP protected PDF", () async {
    expect(MediaType.lcpProtectedPdf,
        await MediaType.ofSingleHint(fileExtension: "lcpdf"));
    expect(MediaType.lcpProtectedPdf,
        await MediaType.ofSingleHint(mediaType: "application/pdf+lcp"));
    expect(MediaType.lcpProtectedPdf,
        await MediaType.ofFile(fixtures.fileAt("pdf-lcp.unknown")));
  });

  test("sniff LCP license document", () async {
    expect(MediaType.lcpLicenseDocument,
        await MediaType.ofSingleHint(fileExtension: "lcpl"));
    expect(
        MediaType.lcpLicenseDocument,
        await MediaType.ofSingleHint(
            mediaType: "application/vnd.readium.lcp.license.v1.0+json"));
    expect(MediaType.lcpLicenseDocument,
        await MediaType.ofFile(fixtures.fileAt("lcpl.unknown")));
  });

  test("sniff LPF", () async {
    expect(MediaType.lpf, await MediaType.ofSingleHint(fileExtension: "lpf"));
    expect(MediaType.lpf,
        await MediaType.ofSingleHint(mediaType: "application/lpf+zip"));
    expect(
        MediaType.lpf, await MediaType.ofFile(fixtures.fileAt("lpf.unknown")));
    expect(MediaType.lpf,
        await MediaType.ofFile(fixtures.fileAt("lpf-index-html.unknown")));
  });

  test("sniff PDF", () async {
    expect(MediaType.pdf, await MediaType.ofSingleHint(fileExtension: "pdf"));
    expect(MediaType.pdf,
        await MediaType.ofSingleHint(mediaType: "application/pdf"));
    expect(
        MediaType.pdf, await MediaType.ofFile(fixtures.fileAt("pdf.unknown")));
  });

  test("sniff PNG", () async {
    expect(MediaType.png, await MediaType.ofSingleHint(fileExtension: "png"));
    expect(MediaType.png, await MediaType.ofSingleHint(mediaType: "image/png"));
  });

  test("sniff TIFF", () async {
    expect(MediaType.tiff, await MediaType.ofSingleHint(fileExtension: "tiff"));
    expect(MediaType.tiff, await MediaType.ofSingleHint(fileExtension: "tif"));
    expect(
        MediaType.tiff, await MediaType.ofSingleHint(mediaType: "image/tiff"));
    expect(MediaType.tiff,
        await MediaType.ofSingleHint(mediaType: "image/tiff-fx"));
  });

  test("sniff WebP", () async {
    expect(MediaType.webp, await MediaType.ofSingleHint(fileExtension: "webp"));
    expect(
        MediaType.webp, await MediaType.ofSingleHint(mediaType: "image/webp"));
  });

  test("sniff WebPub", () async {
    expect(MediaType.readiumWebpub,
        await MediaType.ofSingleHint(fileExtension: "webpub"));
    expect(MediaType.readiumWebpub,
        await MediaType.ofSingleHint(mediaType: "application/webpub+zip"));
    expect(MediaType.readiumWebpub,
        await MediaType.ofFile(fixtures.fileAt("webpub-package.unknown")));
  });

  test("sniff WebPub manifest", () async {
    expect(MediaType.readiumWebpubManifest,
        await MediaType.ofSingleHint(mediaType: "application/webpub+json"));
    expect(MediaType.readiumWebpubManifest,
        await MediaType.ofFile(fixtures.fileAt("webpub.json")));
  });

  test("sniff W3C WPUB manifest", () async {
    expect(MediaType.w3cWpubManifest,
        await MediaType.ofFile(fixtures.fileAt("w3c-wpub.json")));
  });

  test("sniff ZAB", () async {
    expect(MediaType.zab, await MediaType.ofSingleHint(fileExtension: "zab"));
    expect(
        MediaType.zab, await MediaType.ofFile(fixtures.fileAt("zab.unknown")));
  });
}
