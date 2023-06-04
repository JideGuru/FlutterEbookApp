// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:mno_streamer/src/epub/property_data_type.dart';
import 'package:xml/xml.dart';

/// Parser for navigation document that describes navigation tables.
///
/// The navigation tables are: toc, page-list, landmarks, lot, loi, loa, lov.
class NavigationDocumentParser {
  static const List<String> _keys = [
    "toc",
    "page-list",
    "landmarks",
    "lot",
    "loi",
    "loa",
    "lov"
  ];

  /// Parse the Xml document for navigation tables.
  static Map<String, List<Link>> parse(XmlDocument document, String filePath) {
    Map<String, String> docPrefixes = document
            .getAttribute("prefix", namespace: Namespaces.ops)
            ?.let(parsePrefixes) ??
        {};
    Map<String, String> prefixMap = Map.of(contentReservedPrefixes)
      ..addAll(docPrefixes); // prefix element overrides reserved prefixes

    XmlElement? body =
        document.rootElement.getElement("body", namespace: Namespaces.xhtml);
    if (body == null) {
      return {};
    }
    List<(List<String>, List<Link>)> navs = body
        .findAllElements("nav", namespace: Namespaces.xhtml)
        .mapNotNull((it) => _parseNavElement(it, filePath, prefixMap))
        .toList();
    Map<String, List<Link>> navMap = Map.fromEntries(navs
        .flatMap((nav) => nav.$1.map((type) => MapEntry(type, nav.$2))));
    return navMap.map((key, value) {
      String suffix = key.removePrefix(Vocabularies.type);
      String updatedKey = (_keys.contains(suffix)) ? suffix : key;
      return MapEntry(updatedKey, value);
    });
  }

  static (List<String>, List<Link>)? _parseNavElement(
      XmlElement nav, String filePath, Map<String, String> prefixMap) {
    String? typeAttr = nav.getAttribute("type", namespace: Namespaces.ops);
    if (typeAttr == null) {
      return null;
    }
    List<String> types = parseProperties(typeAttr)
        .mapNotNull((it) =>
            resolveProperty(it, prefixMap, defaultVocab: DefaultVocab.type))
        .toList();
    List<Link>? links = nav
        .getElement("ol", namespace: Namespaces.xhtml)
        ?.let((it) => _parseOlElement(it, filePath));
    return (types.isNotEmpty && links != null && links.isNotEmpty)
        ? (types, links)
        : null;
  }

  static List<Link> _parseOlElement(XmlElement element, String filePath) =>
      element
          .findElements("li", namespace: Namespaces.xhtml)
          .mapNotNull((it) => _parseLiElement(it, filePath))
          .toList();

  static Link? _parseLiElement(XmlElement element, String filePath) {
    XmlElement? first = element.children.whereType<XmlElement>().firstOrNull;
    if (first == null) {
      return null; // should be <a>,  <span>, or <ol>
    }
    String title = (first.name.local == "ol")
        ? ""
        : first.text.replaceAll(RegExp("\\s+"), " ").trim();
    String? rawHref = first.getAttribute("href");
    String href = (first.name.local == "a" && !rawHref.isNullOrBlank)
        ? Href(rawHref!, baseHref: filePath).string
        : "#";
    List<Link> children = element
            .getElement("ol", namespace: Namespaces.xhtml)
            ?.let((it) => _parseOlElement(it, filePath)) ??
        [];

    if (children.isEmpty && (href == "#" || title == "")) {
      return null;
    } else {
      return Link(title: title, href: href, children: children);
    }
  }
}
