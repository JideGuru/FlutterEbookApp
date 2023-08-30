// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/archive.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/mediatype/mediatype.dart';
import 'package:mno_shared/src/mediatype/sniffer_context.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart' hide Link;

/// Determines if the provided content matches a known MediaType.
///
/// @param context Holds the file metadata and cached content, which are shared among the sniffers.
typedef Sniffer = Future<MediaType?> Function(SnifferContext context);

/// Default MediaType sniffers provided by Readium.
class Sniffers {
  /// The default sniffers provided by Readium 2 to resolve a [MediaType].
  /// The sniffers order is important, because some MediaTypes are subsets of other MediaTypes.
  static const List<Sniffer> all = [
    html,
    opds,
    lcpLicense,
    bitmap,
    webpub,
    w3cWPUB,
    epub,
    lpf,
    archive,
    pdf,
  ];

  /// Sniffs an HTML document.
  static Future<MediaType?> html(SnifferContext context) async {
    if (context.hasFileExtension(["htm", "html", "xht", "xhtml"]) ||
        context.hasAnyOfMediaTypes(["text/html", "application/xhtml+xml"])) {
      return MediaType.html;
    }
    // [contentAsXml] will fail if the HTML is not a proper XML document, hence the doctype check.
    if ((await context.contentAsXml())?.name.local.toLowerCase() == "html" ||
        (await context.contentAsString())
                ?.trimLeft()
                .startsWith("<!DOCTYPE html>") ==
            true) {
      return MediaType.html;
    }
    return null;
  }

  /// Sniffs an OPDS document.
  static Future<MediaType?> opds(SnifferContext context) async {
    // OPDS 1
    if (context
        .hasMediaType("application/atom+xml;type=entry;profile=opds-catalog")) {
      return MediaType.opds1Entry;
    }
    if (context.hasMediaType("application/atom+xml;profile=opds-catalog")) {
      return MediaType.opds1;
    }
    MediaType? xmlMediaType = (await context.contentAsXml())?.let((xml) {
      if (xml.name.namespaceUri == "http://www.w3.org/2005/Atom") {
        if (xml.name.local == "feed") {
          return MediaType.opds1;
        } else if (xml.name.local == "entry") {
          return MediaType.opds1Entry;
        }
      }
      return null;
    });
    if (xmlMediaType != null) {
      return xmlMediaType;
    }

    // OPDS 2
    if (context.hasMediaType("application/opds+json")) {
      return MediaType.opds2;
    }
    if (context.hasMediaType("application/opds-publication+json")) {
      return MediaType.opds2Publication;
    }
    MediaType? rwpmMediaType = (await context.contentAsRwpm())?.let((rwpm) {
      if (rwpm
              .linkWithRel("self")
              ?.mediaType
              .matchesFromName("application/opds+json") ==
          true) {
        return MediaType.opds2;
      }
      if (rwpm.links._firstWithRelMatching(
              (it) => it.startsWith("http://opds-spec.org/acquisition")) !=
          null) {
        return MediaType.opds2Publication;
      }
      return null;
    });
    if (rwpmMediaType != null) {
      return rwpmMediaType;
    }

    // OPDS Authentication Document.
    if (context.hasAnyOfMediaTypes([
      "application/opds-authentication+json",
      "application/vnd.opds.authentication.v1.0+json"
    ])) {
      return MediaType.opdsAuthentication;
    }
    if (await context.containsJsonKeys(["id", "title", "authentication"])) {
      return MediaType.opdsAuthentication;
    }

    return null;
  }

  /// Sniffs an LCP License Document.
  static Future<MediaType?> lcpLicense(SnifferContext context) async {
    if (context.hasFileExtension(["lcpl"]) ||
        context.hasMediaType("application/vnd.readium.lcp.license.v1.0+json")) {
      return MediaType.lcpLicenseDocument;
    }
    if (await context
        .containsJsonKeys(["id", "issued", "provider", "encryption"])) {
      return MediaType.lcpLicenseDocument;
    }
    return null;
  }

  /// Sniffs a bitmap image.
  static Future<MediaType?> bitmap(SnifferContext context) async {
    if (context.hasFileExtension(["bmp", "dib"]) ||
        context.hasAnyOfMediaTypes(["image/bmp", "image/x-bmp"])) {
      return MediaType.bmp;
    }
    if (context.hasFileExtension(["gif"]) ||
        context.hasMediaType("image/gif")) {
      return MediaType.gif;
    }
    if (context
            .hasFileExtension(["jpg", "jpeg", "jpe", "jif", "jfif", "jfi"]) ||
        context.hasMediaType("image/jpeg")) {
      return MediaType.jpeg;
    }
    if (context.hasFileExtension(["png"]) ||
        context.hasMediaType("image/png")) {
      return MediaType.png;
    }
    if (context.hasFileExtension(["tiff", "tif"]) ||
        context.hasAnyOfMediaTypes(["image/tiff", "image/tiff-fx"])) {
      return MediaType.tiff;
    }
    if (context.hasFileExtension(["webp"]) ||
        context.hasMediaType("image/webp")) {
      return MediaType.webp;
    }
    return null;
  }

  /// Sniffs a Readium Web Publication, protected or not by LCP.
  static Future<MediaType?> webpub(SnifferContext context) async {
    if (context.hasFileExtension(["audiobook"]) ||
        context.hasMediaType("application/audiobook+zip")) {
      return MediaType.readiumAudiobook;
    }
    if (context.hasMediaType("application/audiobook+json")) {
      return MediaType.readiumAudiobookManifest;
    }
    if (context.hasFileExtension(["divina"]) ||
        context.hasMediaType("application/divina+zip")) {
      return MediaType.divina;
    }
    if (context.hasMediaType("application/divina+json")) {
      return MediaType.divinaManifest;
    }
    if (context.hasFileExtension(["webpub"]) ||
        context.hasMediaType("application/webpub+zip")) {
      return MediaType.readiumWebpub;
    }
    if (context.hasMediaType("application/webpub+json")) {
      return MediaType.readiumWebpubManifest;
    }
    if (context.hasFileExtension(["lcpa"]) ||
        context.hasMediaType("application/audiobook+lcp")) {
      return MediaType.lcpProtectedAudiobook;
    }
    if (context.hasFileExtension(["lcpdf"]) ||
        context.hasMediaType("application/pdf+lcp")) {
      return MediaType.lcpProtectedPdf;
    }
    // Reads a RWPM, either from a manifest.json file, or from a manifest.json archive entry, if
    // the file is an archive.
    bool isManifest = true;
    Manifest? manifest;
    try {
      // manifest.json
      manifest = await context.contentAsRwpm() ??
          // Archive package
          (await context.readArchiveEntryAt("manifest.json"))
              ?.let((it) => Manifest.fromJson(
                  utf8.decode(it.buffer.asUint8List()).toJsonOrNull()))
              ?.also((it) => isManifest = false);
    } on Exception {
      manifest = null;
    }

    if (manifest != null) {
      bool isLcpProtected =
          await context.containsArchiveEntryAt("license.lcpl");

      if (manifest.metadata.type == "http://schema.org/Audiobook" ||
          manifest.readingOrder.allAreAudio) {
        if (isManifest) {
          return MediaType.readiumAudiobookManifest;
        } else {
          return (isLcpProtected)
              ? MediaType.lcpProtectedAudiobook
              : MediaType.readiumAudiobook;
        }
      }
      if (manifest.readingOrder.allAreBitmap) {
        return (isManifest) ? MediaType.divinaManifest : MediaType.divina;
      }
      if (isLcpProtected &&
          manifest.readingOrder.allMatchMediaType(MediaType.pdf)) {
        return MediaType.lcpProtectedPdf;
      }
      if (manifest
              .linkWithRel("self")
              ?.mediaType
              .matchesFromName("application/webpub+json") ==
          true) {
        return (isManifest)
            ? MediaType.readiumWebpubManifest
            : MediaType.readiumWebpub;
      }
    }
    return null;
  }

  static Future<MediaType?> w3cWPUB(SnifferContext context) async {
    // Somehow, [JSONObject] can't access JSON-LD keys such as `@context`.
    String content = (await context.contentAsString()) ?? "";
    if (content.contains("@context") &&
        content.contains("https://www.w3.org/ns/wp-context")) {
      return MediaType.w3cWpubManifest;
    }

    return null;
  }

  /// Sniffs an EPUB publication.
  ///
  /// Reference: https://www.w3.org/publishing/epub3/epub-ocf.html#sec-zip-container-mime
  static Future<MediaType?> epub(SnifferContext context) async {
    if (context.hasFileExtension(["epub"]) ||
        context.hasMediaType("application/epub+zip")) {
      return MediaType.epub;
    }

    String? mimetype = (await context.readArchiveEntryAt("mimetype"))
        ?.let((it) => ascii.decode(it.buffer.asUint8List()).trim());
    if (mimetype == "application/epub+zip") {
      return MediaType.epub;
    }
    return null;
  }

  /// Sniffs a Lightweight Packaging MediaType (LPF).
  ///
  /// References:
  ///  - https://www.w3.org/TR/lpf/
  ///  - https://www.w3.org/TR/pub-manifest/
  static Future<MediaType?> lpf(SnifferContext context) async {
    if (context.hasFileExtension(["lpf"]) ||
        context.hasMediaType("application/lpf+zip")) {
      return MediaType.lpf;
    }
    if (await context.containsArchiveEntryAt("index.html")) {
      return MediaType.lpf;
    }

    // Somehow, [JSONObject] can't access JSON-LD keys such as `@context`.
    MediaType? mediaType =
        (await context.readArchiveEntryAt("publication.json"))
            ?.let((it) => utf8.decode(it.buffer.asUint8List()))
            .let((manifest) {
      if (manifest.contains("@context") &&
          manifest.contains("https://www.w3.org/ns/pub-context")) {
        return MediaType.lpf;
      }
      return null;
    });

    return mediaType;
  }

  /// Authorized extensions for resources in a CBZ archive.
  /// Reference: https://wiki.mobileread.com/wiki/CBR_and_CBZ
  static const cbzExtensions = [
    // bitmap
    "bmp", "dib", "gif", "jif", "jfi", "jfif", "jpg", "jpeg", "png", "tif",
    "tiff", "webp",
    // metadata
    "acbf", "xml"
  ];

  /// Authorized extensions for resources in a ZAB archive (Zipped Audio Book).
  static const zabExtensions = [
    // audio
    "aac", "aiff", "alac", "flac", "m4a", "m4b", "mp3", "ogg", "oga", "mogg",
    "opus", "wav", "webm",
    // playlist
    "asx", "bio", "m3u", "m3u8", "pla", "pls", "smil", "vlc", "wpl", "xspf",
    "zpl"
  ];

  /// Sniffs a simple Archive-based MediaType, like Comic Book Archive or Zipped Audio Book.
  ///
  /// Reference: https://wiki.mobileread.com/wiki/CBR_and_CBZ
  static Future<MediaType?> archive(SnifferContext context) async {
    if (context.hasFileExtension(["cbz"]) ||
        context.hasAnyOfMediaTypes([
          "application/vnd.comicbook+zip",
          "application/x-cbz",
          "application/x-cbr"
        ])) {
      return MediaType.cbz;
    }
    if (context.hasFileExtension(["zab"])) {
      return MediaType.zab;
    }

    if (await context.contentAsArchive() != null) {
      bool isIgnored(ArchiveEntry entry, File file) => basename(file.path)
          .let((name) => name.startsWith(".") || name == "Thumbs.db");

      Future<bool> archiveContainsOnlyExtensions(
              List<String> fileExtensions) async =>
          await context.archiveEntriesAllSatisfy((entry) {
            File file = File(entry.path);
            return isIgnored(entry, file) ||
                fileExtensions.contains(file.path.extension().toLowerCase());
          });
      if (await archiveContainsOnlyExtensions(cbzExtensions)) {
        return MediaType.cbz;
      }
      if (await archiveContainsOnlyExtensions(zabExtensions)) {
        return MediaType.zab;
      }
    }
    return null;
  }

  /// Sniffs a PDF document.
  ///
  /// Reference: https://www.loc.gov/preservation/digital/MediaTypes/fdd/fdd000123.shtml
  static Future<MediaType?> pdf(SnifferContext context) async {
    if (context.hasFileExtension(["pdf"]) ||
        context.hasMediaType("application/pdf")) {
      return MediaType.pdf;
    }
    if ((await context.read(range: IntRange(0, 5)))?.asUtf8() == "%PDF-") {
      return MediaType.pdf;
    }
    return null;
  }
}

extension ListLinkFirstWithRelMatching on List<Link> {
  /// Finds the first [Link] having a relation matching the given [predicate].
  Link? _firstWithRelMatching(bool Function(String) predicate) =>
      firstOrNullWhere((it) => it.rels.any(predicate));
}
