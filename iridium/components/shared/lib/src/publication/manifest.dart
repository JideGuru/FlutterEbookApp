// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/uri.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

/// Holds the metadata of a Readium publication, as described in the Readium Web Publication Manifest.
class Manifest with EquatableMixin implements JSONable {
  final List<String> context;
  final Metadata metadata;
  List<Link> links;
  final List<Link> readingOrder;
  final List<Link> resources;
  final List<Link> tableOfContents;
  final Map<String, List<PublicationCollection>> subcollections;

  Manifest(
      {this.context = const [],
      required this.metadata,
      this.links = const [],
      this.readingOrder = const [],
      this.resources = const [],
      this.tableOfContents = const [],
      this.subcollections = const {}});

  Manifest copy({
    List<String>? context,
    Metadata? metadata,
    List<Link>? links,
    List<Link>? readingOrder,
    List<Link>? resources,
    List<Link>? tableOfContents,
    Map<String, List<PublicationCollection>>? subcollections,
  }) =>
      Manifest(
        context: context ?? this.context,
        metadata: metadata ?? this.metadata,
        links: links ?? this.links,
        readingOrder: readingOrder ?? this.readingOrder,
        resources: resources ?? this.resources,
        tableOfContents: tableOfContents ?? this.tableOfContents,
        subcollections: subcollections ?? this.subcollections,
      );

  @override
  List<Object> get props => [
        context,
        metadata,
        links,
        readingOrder,
        resources,
        tableOfContents,
        subcollections,
      ];

  /// Finds the first [Link] with the given relation in the manifest's links.
  Link? linkWithRel(String rel) =>
      readingOrder.firstWithRel(rel) ??
      resources.firstWithRel(rel) ??
      links.firstWithRel(rel);

  /// Finds all [Link]s having the given [rel] in the manifest's links.
  List<Link> linksWithRel(String rel) =>
      (readingOrder + resources + links).filterByRel(rel);

  /// Serializes a [Publication] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{}
      ..putIterableIfNotEmpty("@context", context)
      ..putJSONableIfNotEmpty("metadata", metadata)
      ..put("links", links.toJson())
      ..put("readingOrder", readingOrder.toJson())
      ..putIterableIfNotEmpty("resources", resources)
      ..putIterableIfNotEmpty("toc", tableOfContents);
    subcollections.appendToJsonObject(json);
    return json;
  }

  @override
  String toString() => toJson().toString().replaceAll("\\/", "/");

  static LinkHrefNormalizer normalizeHref(String baseUrl) =>
      (String href) => Href(href, baseHref: baseUrl).string;

  /// Parses a [Publication] from its RWPM JSON representation.
  ///
  /// If the publication can't be parsed, a warning will be logged with [warnings].
  /// https://readium.org/webpub-manifest/
  /// https://readium.org/webpub-manifest/schema/publication.schema.json
  static Manifest? fromJson(
    Map<String, dynamic>? json, {
    bool packaged = false,
  }) {
    if (json == null) {
      return null;
    }
    String baseUrl;
    if (packaged) {
      baseUrl = "/";
    } else {
      String? href = Link.fromJSONArray(json.optJSONArray("links"))
          .firstWithRel("self")
          ?.href;
      baseUrl = href?.let(
              (it) => Uri.tryParse(it)?.removeLastComponent().toString()) ??
          "/";
    }

    List<String> context =
        json.optStringsFromArrayOrSingle("@context", remove: true);
    Metadata? metadata = Metadata.fromJson(
        json.remove("metadata") as Map<String, dynamic>?,
        normalizeHref: normalizeHref(baseUrl));
    if (metadata == null) {
      Fimber.i("[metadata] is required $json");
      return null;
    }

    List<Link> links = Link.fromJSONArray(
            json.remove("links") as List<dynamic>?,
            normalizeHref: normalizeHref(baseUrl))
        .map((it) => (!packaged || !it.rels.contains("self"))
            ? it
            : it.copy(
                rels: it.rels
                  ..remove("self")
                  ..add("alternate")))
        .toList();
    // [readingOrder] used to be [spine], so we parse [spine] as a fallback.
    List<dynamic>? readingOrderJSON =
        (json.remove("readingOrder") ?? json.remove("spine")) as List<dynamic>?;
    List<Link> readingOrder = Link.fromJSONArray(readingOrderJSON,
            normalizeHref: normalizeHref(baseUrl))
        .where((it) => it.type != null)
        .toList();

    List<Link> resources = Link.fromJSONArray(
            json.remove("resources") as List<dynamic>?,
            normalizeHref: normalizeHref(baseUrl))
        .where((it) => it.type != null)
        .toList();

    List<Link> tableOfContents = Link.fromJSONArray(
        json.remove("toc") as List<dynamic>?,
        normalizeHref: normalizeHref(baseUrl));

    // Parses subcollections from the remaining JSON properties.
    Map<String, List<PublicationCollection>> subcollections =
        PublicationCollection.collectionsFromJSON(json,
            normalizeHref: normalizeHref(baseUrl));

    return Manifest(
        context: context,
        metadata: metadata,
        links: links,
        readingOrder: readingOrder,
        resources: resources,
        tableOfContents: tableOfContents,
        subcollections: subcollections);
  }
}
