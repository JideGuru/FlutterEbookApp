// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:mno_streamer/src/epub/metadata_parser.dart';
import 'package:mno_streamer/src/epub/package_document.dart';

/// Creates a [Publication] model from an EPUB package's document.
///
/// @param displayOptions iBooks Display Options XML file to use as a fallback for the metadata.
///        See https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#epub-2x-9
class PublicationFactory {
  final String fallbackTitle;
  final PackageDocument packageDocument;
  final Map<String, List<Link>> navigationData;
  final Map<String, Encryption> encryptionData;
  final Map<String, String> displayOptions;

  PublicationFactory(
      {required this.fallbackTitle,
      required this.packageDocument,
      Map<String, List<Link>>? navigationData,
      this.encryptionData = const {},
      this.displayOptions = const {}})
      : this.navigationData = navigationData ?? {};

  double get _epubVersion => packageDocument.epubVersion;

  List<EpubLink> get _links => packageDocument.metadata.links;

  Spine get _spine => packageDocument.spine;

  List<Item> get _manifest => packageDocument.manifest;

  PubMetadataAdapter get _pubMetadata => PubMetadataAdapter(
      _epubVersion,
      packageDocument.metadata.global,
      fallbackTitle,
      packageDocument.uniqueIdentifierId,
      _spine.direction,
      displayOptions);

  Map<String, LinkMetadataAdapter> get _itemMetadata =>
      packageDocument.metadata.refine.map((key, value) =>
          MapEntry(key, LinkMetadataAdapter(_epubVersion, value)));

  Map<String?, Item> get _itemById =>
      _manifest.where((it) => it.id != null).associateBy((it) => it.id);

  Map<String, Itemref> get _itemrefByIdref =>
      _spine.itemrefs.associateBy((it) => it.idref);

  Manifest create() {
    // Compute metadata
    Metadata metadata = _pubMetadata.metadata();
    List<Link> metadataLinks = _links.mapNotNull(_mapEpubLink).toList();

    // Compute links
    List<String> readingOrderIds = _spine.itemrefs
        .filter((it) => it.linear)
        .map((it) => it.idref)
        .toList();
    List<Link> readingOrder = readingOrderIds
        .mapNotNull((it) => _itemById[it]?.let(_computeLink))
        .toList();
    Set<String> readingOrderAllIds = _computeIdsWithFallbacks(readingOrderIds);
    List<Item> resourceItems = _manifest
        .filterNot((it) => readingOrderAllIds.contains(it.id))
        .toList();
    List<Link> resources = resourceItems.map(_computeLink).toList();

    // Compute toc and otherCollections
    List<Link> toc = navigationData.remove("toc") ?? [];
    Map<String, List<PublicationCollection>> subcollections =
        navigationData.map((key, value) => MapEntry(
            (key == "page-list") ? "pageList" : key,
            [PublicationCollection(links: value)]));

    // Build Publication object
    return Manifest(
        metadata: metadata,
        links: metadataLinks,
        readingOrder: readingOrder,
        resources: resources,
        tableOfContents: toc,
        subcollections: subcollections);
  }

  /// Compute a Publication [Link] from an Epub metadata link
  Link _mapEpubLink(EpubLink link) {
    List<String> contains = [];
    if (link.rels.contains("${Vocabularies.link}record")) {
      if (link.properties.contains("${Vocabularies.link}onix")) {
        contains.add("onix");
      }
      if (link.properties.contains("${Vocabularies.link}xmp")) {
        contains.add("xmp");
      }
    }
    return Link(
        href: link.href,
        type: link.mediaType,
        rels: link.rels,
        properties: Properties(otherProperties: {"contains": contains}));
  }

  /// Recursively find the ids of the fallback items in [items]
  Set<String> _computeIdsWithFallbacks(List<String> ids) {
    Set<String> fallbackIds = {};
    for (String it in ids) {
      fallbackIds.addAll(_computeFallbackChain(it));
    }
    return fallbackIds;
  }

  /// Compute the ids contained in the fallback chain of [item]
  Set<String> _computeFallbackChain(String id) {
    // The termination has already been checked while computing links
    Set<String> ids = {};
    Item? item = _itemById[id];
    item?.id?.let(ids.add);
    item?.fallback?.let((it) => ids.addAll(_computeFallbackChain(it)));
    return ids;
  }

  /// Compute a Publication [Link] for an epub [Item] and its fallbacks
  Link _computeLink(Item item, {Set<String> fallbackChain = const {}}) {
    (Set<String>, Properties) tuple =
        _computePropertiesAndRels(item, _itemrefByIdref[item.id]);
    Set<String> rels = tuple.$1;
    Properties properties = tuple.$2;
    return Link(
        id: item.id,
        href: item.href,
        type: item.mediaType,
        duration: _itemMetadata[item.id]?.duration,
        rels: rels,
        properties: properties,
        alternates: _computeAlternates(item, fallbackChain));
  }

  (Set<String>, Properties) _computePropertiesAndRels(
      Item item, Itemref? itemref) {
    Map<String, dynamic> properties = {};
    Set<String> rels = {};
    (List<String>, List<String>, List<String>) parsedItemProperties =
        _parseItemProperties(item.properties);
    List<String> manifestRels = parsedItemProperties.$1;
    List<String> contains = parsedItemProperties.$2;
    List<String> others = parsedItemProperties.$3;
    rels.addAll(manifestRels);
    if (contains.isNotEmpty) {
      properties["contains"] = contains;
    }
    for (String other in others) {
      properties[other] = true;
    }
    if (itemref != null) {
      properties.addAll(_parseItemrefProperties(itemref.properties));
    }

    String? coverId = _pubMetadata.cover;
    if (coverId != null && item.id == coverId) {
      rels.add("cover");
    }

    encryptionData[item.href.addPrefix('/')]
        ?.let((it) => properties["encrypted"] = it.toJson());

    return (rels, Properties(otherProperties: properties));
  }

  /// Compute alternate links for [item], checking for an infinite recursion
  List<Link> _computeAlternates(Item item, Set<String> fallbackChain) {
    Link? fallback = item.fallback?.let((id) {
      if (fallbackChain.contains(id)) {
        return null;
      }
      return _itemById[id]?.let((it) {
        Set<String> updatedChain = Set.of(fallbackChain);
        item.id?.let(updatedChain.add);
        return _computeLink(it, fallbackChain: updatedChain);
      });
    });
    Link? mediaOverlays =
        item.mediaOverlay?.let((id) => _itemById[id]?.let(_computeLink));
    return [fallback, mediaOverlays].filterNotNull().toList();
  }

  (List<String>, List<String>, List<String>) _parseItemProperties(
      List<String> properties) {
    List<String> rels = [];
    List<String> contains = [];
    List<String> others = [];
    for (String property in properties) {
      switch (property) {
        case "${Vocabularies.item}scripted":
          contains.add("js");
          break;
        case "${Vocabularies.item}mathml":
          contains.add("mathml");
          break;
        case "${Vocabularies.item}svg":
          contains.add("svg");
          break;
        case "${Vocabularies.item}xmp-record":
          contains.add("xmp");
          break;
        case "${Vocabularies.item}remote-resources":
          contains.add("remote-resources");
          break;
        case "${Vocabularies.item}nav":
          rels.add("contents");
          break;
        case "${Vocabularies.item}cover-image":
          rels.add("cover");
          break;
        default:
          others.add(property);
      }
    }
    return (rels, contains, others);
  }

  Map<String, String> _parseItemrefProperties(List<String> properties) {
    Map<String, String> linkProperties = {};
    for (String property in properties) {
      //  Page
      _parsePage(property)?.let((it) => linkProperties["page"] = it);
      //  Spread
      _parseSpread(property)?.let((it) => linkProperties["spread"] = it);
      //  Layout
      _parseLayout(property)?.let((it) => linkProperties["layout"] = it);
      //  Orientation
      _parseOrientation(property)
          ?.let((it) => linkProperties["orientation"] = it);
      //  Overflow
      _parseOverflow(property)?.let((it) => linkProperties["overflow"] = it);
    }
    return linkProperties;
  }

  String? _parsePage(String property) {
    switch (property) {
      case "${Vocabularies.rendition}page-spread-center":
        return "center";
      case "${Vocabularies.rendition}page-spread-left":
      case "${Vocabularies.itemref}page-spread-left":
        return "left";
      case "${Vocabularies.rendition}page-spread-right":
      case "${Vocabularies.itemref}page-spread-right":
        return "right";
      default:
        return null;
    }
  }

  String? _parseSpread(String property) {
    switch (property) {
      case "${Vocabularies.rendition}spread-node":
        return "none";
      case "${Vocabularies.rendition}spread-auto":
        return "auto";
      case "${Vocabularies.rendition}spread-landscape":
        return "landscape";
      case "${Vocabularies.rendition}spread-portrait":
      case "${Vocabularies.rendition}spread-both":
        return "both";
      default:
        return null;
    }
  }

  String? _parseLayout(String property) {
    switch (property) {
      case "${Vocabularies.rendition}layout-reflowable":
        return "reflowable";
      case "${Vocabularies.rendition}layout-pre-paginated":
        return "fixed";
      default:
        return null;
    }
  }

  String? _parseOrientation(String property) {
    switch (property) {
      case "${Vocabularies.rendition}orientation-auto":
        return "auto";
      case "${Vocabularies.rendition}orientation-landscape":
        return "landscape";
      case "${Vocabularies.rendition}orientation-portrait":
        return "portrait";
      default:
        return null;
    }
  }

  String? _parseOverflow(String property) {
    switch (property) {
      case "${Vocabularies.rendition}flow-auto":
        return "auto";
      case "${Vocabularies.rendition}flow-paginated":
        return "paginated";
      case "${Vocabularies.rendition}flow-scrolled-continuous":
      case "${Vocabularies.rendition}flow-scrolled-doc":
        return "scrolled";
      default:
        return null;
    }
  }
}
