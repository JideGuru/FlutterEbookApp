// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:mno_streamer/src/epub/extensions/xml_node.dart';
import 'package:mno_streamer/src/epub/metadata_parser.dart';
import 'package:mno_streamer/src/epub/property_data_type.dart';
import 'package:xml/xml.dart';

class PackageDocument {
  final String path;
  final double epubVersion;
  final String? uniqueIdentifierId;
  final EpubMetadata metadata;
  final List<Item> manifest;
  final Spine spine;

  PackageDocument(
      {required this.path,
      required this.epubVersion,
      this.uniqueIdentifierId,
      required this.metadata,
      required this.manifest,
      required this.spine});

  static PackageDocument? parse(XmlElement document, String filePath) {
    Map<String, String> packagePrefixes =
        document.getAttribute("prefix")?.let((it) => parsePrefixes(it)) ?? {};
    Map<String, String> prefixMap = Map.of(packageReservedPrefixes)
      ..addAll(packagePrefixes); // prefix element overrides reserved prefixes
    double epubVersion =
        document.getAttribute("version")?.toDoubleOrNull() ?? 1.2;
    EpubMetadata? metadata =
        MetadataParser(epubVersion, prefixMap).parse(document, filePath);
    if (metadata == null) {
      return null;
    }
    XmlElement? manifestElement =
        document.getElement("manifest", namespace: Namespaces.opf);
    if (manifestElement == null) {
      return null;
    }
    XmlElement? spineElement =
        document.getElement("spine", namespace: Namespaces.opf);
    if (spineElement == null) {
      return null;
    }

    return PackageDocument(
        path: filePath,
        epubVersion: epubVersion,
        uniqueIdentifierId: document.getAttribute("unique-identifier"),
        metadata: metadata,
        manifest: manifestElement
            .findElements("item", namespace: Namespaces.opf)
            .mapNotNull((it) => Item.parse(it, filePath, prefixMap))
            .toList(),
        spine: Spine.parse(spineElement, prefixMap, epubVersion));
  }
}

class Item {
  final String href;
  final String? id;
  final String? fallback;
  final String? mediaOverlay;
  final String? mediaType;
  final List<String> properties;

  Item(
      {required this.href,
      this.id,
      this.fallback,
      this.mediaOverlay,
      this.mediaType,
      required this.properties});

  static Item? parse(
      XmlNode element, String filePath, Map<String, String> prefixMap) {
    String? href = element
        .getAttribute("href")
        ?.let((it) => Href(it, baseHref: filePath).string);
    if (href == null) {
      return null;
    }
    String propAttr = element.getAttribute("properties") ?? "";
    List<String> properties = parseProperties(propAttr)
        .mapNotNull((it) =>
            resolveProperty(it, prefixMap, defaultVocab: DefaultVocab.item))
        .toList();
    return Item(
        href: href,
        id: element.id,
        fallback: element.getAttribute("fallback"),
        mediaOverlay: element.getAttribute("media-overlay"),
        mediaType: element.getAttribute("media-type"),
        properties: properties);
  }

  @override
  String toString() => 'Item{href: $href, id: $id, fallback: $fallback, '
      'mediaOverlay: $mediaOverlay, mediaType: $mediaType, properties: $properties}';
}

class Spine {
  final List<Itemref> itemrefs;
  final ReadingProgression direction;
  final String? toc;

  const Spine(this.itemrefs, this.direction, this.toc);

  static Spine parse(
      XmlNode element, Map<String, String> prefixMap, double epubVersion) {
    List<Itemref> itemrefs = element
        .findElements("itemref", namespace: Namespaces.opf)
        .mapNotNull((it) => Itemref.parse(it, prefixMap))
        .toList();
    ReadingProgression pageProgressionDirection;
    switch (element.getAttribute("page-progression-direction")) {
      case "rtl":
        pageProgressionDirection = ReadingProgression.rtl;
        break;
      case "ltr":
        pageProgressionDirection = ReadingProgression.ltr;
        break;
      default:
        pageProgressionDirection = ReadingProgression.auto; // null or "default"
    }
    String? ncx = (epubVersion >= 3.0) ? element.getAttribute("toc") : null;
    return Spine(itemrefs, pageProgressionDirection, ncx);
  }
}

class Itemref {
  final String idref;
  final bool linear;
  final List<String> properties;

  const Itemref(this.idref, this.linear, this.properties);

  static Itemref? parse(XmlNode element, Map<String, String> prefixMap) {
    String? idref = element.getAttribute("idref");
    if (idref == null) {
      return null;
    }
    bool notLinear = element.getAttribute("linear") == "no";
    String propAttr = element.getAttribute("properties") ?? "";
    List<String> properties = parseProperties(propAttr)
        .mapNotNull((it) =>
            resolveProperty(it, prefixMap, defaultVocab: DefaultVocab.itemref))
        .toList();
    return Itemref(idref, !notLinear, properties);
  }
}
