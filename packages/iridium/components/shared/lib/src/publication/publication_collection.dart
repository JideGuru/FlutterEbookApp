// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

/// Core Collection Model
///
/// https://readium.org/webpub-manifest/schema/subcollection.schema.json
/// Can be used as extension point in the Readium Web Publication Manifest.
class PublicationCollection with EquatableMixin implements JSONable {
  final Map<String, dynamic> metadata;
  final List<Link> links;
  final Map<String, List<PublicationCollection>> subcollections;

  PublicationCollection({
    this.metadata = const {},
    this.links = const [],
    this.subcollections = const {},
  });

  @override
  List<Object> get props => [
        metadata,
        links,
        subcollections,
      ];

  /// Serializes a [PublicationCollection] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "metadata": metadata,
      "links": links.toJson(),
    };
    subcollections.appendToJsonObject(json);
    return json;
  }

  /// Parses a [PublicationCollection] from its RWPM JSON representation.
  ///
  /// If the collection can't be parsed, a warning will be logged with [warnings].
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  static PublicationCollection? fromJSON(dynamic json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json == null) {
      return null;
    }
    List<Link> links;
    Map<String, dynamic>? metadata;
    Map<String, List<PublicationCollection>>? subcollections;

    // Parses a sub-collection object.
    if (json is Map<String, dynamic>) {
      links = Link.fromJSONArray(json.remove("links") as List<dynamic>?,
          normalizeHref: normalizeHref);
      metadata = (json.remove("metadata") as Map<String, dynamic>?);
      subcollections = collectionsFromJSON(json, normalizeHref: normalizeHref);
    }
    // Parses an array of links.
    else if (json is List) {
      links = Link.fromJSONArray(json, normalizeHref: normalizeHref);
    } else {
      Fimber.i("core collection not valid");
      return null;
    }

    if (links.isEmpty) {
      Fimber.i("core collection's [links] must not be empty");
      return null;
    }

    return PublicationCollection(
        metadata: metadata ?? {},
        links: links,
        subcollections: subcollections ?? {});
  }

  /// Parses a map of [PublicationCollection] indexed by their roles from its RWPM JSON representation.
  ///
  /// If the collection can't be parsed, a warning will be logged with [warnings].
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  static Map<String, List<PublicationCollection>> collectionsFromJSON(
      Map<String, dynamic> json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    Map<String, List<PublicationCollection>> collections = {};
    for (String role in json.keys.toList()..sort((a, b) => a.compareTo(b))) {
      dynamic subJSON = json[role];

      // Parses a list of links or a single collection object.
      PublicationCollection? collection =
          PublicationCollection.fromJSON(subJSON, normalizeHref: normalizeHref);
      if (collection != null) {
        collections.putIfAbsent(role, () => []).add(collection);
        // Parses a list of collection objects.
      } else if (subJSON is List) {
        Iterable<PublicationCollection> subcollections = subJSON
            .map((it) => PublicationCollection.fromJSON(it,
                normalizeHref: normalizeHref))
            .whereNotNull();
        collections.putIfAbsent(role, () => []).addAll(subcollections);
      }
    }
    return collections;
  }
}
