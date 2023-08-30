// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

/// Contributor Object for the Readium Web Publication Manifest.
/// https://readium.org/webpub-manifest/schema/contributor-object.schema.json
///
/// @param localizedName The name of the contributor.
/// @param identifier An unambiguous reference to this contributor.
/// @param sortAs The string used to sort the name of the contributor.
/// @param roles The roles of the contributor in the publication making.
/// @param position The position of the publication in this collection/series,
///     when the contributor represents a collection.
/// @param links Used to retrieve similar publications for the given contributor.
class Contributor extends Collection {
  Contributor({
    required super.localizedName,
    super.identifier,
    super.localizedSortAs,
    super.roles,
    super.position,
    super.links,
  });

  static Contributor fromString(String name) =>
      Contributor(localizedName: LocalizedString.fromString(name));

  /// Parses a [Contributor] from its RWPM JSON representation.
  ///
  /// A contributor can be parsed from a single string, or a full-fledged object.
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If the contributor can't be parsed, a warning will be logged with [warnings].
  static Contributor? fromJson(dynamic json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json == null) {
      return null;
    }

    LocalizedString? localizedName;
    if (json is String) {
      localizedName = LocalizedString.fromJson(json);
    } else if (json is Map<String, dynamic>) {
      localizedName = LocalizedString.fromJson(json.opt("name"));
    }
    if (localizedName == null) {
      Fimber.i("[name] is required");
      return null;
    }

    Map<String, dynamic> jsonObject =
        (json is Map<String, dynamic>) ? json : {};
    return Contributor(
        localizedName: localizedName,
        identifier: jsonObject.optNullableString("identifier"),
        localizedSortAs: LocalizedString.fromJson(jsonObject.remove("sortAs")),
        roles: jsonObject.optStringsFromArrayOrSingle("role").toSet(),
        position: jsonObject.optNullableDouble("position"),
        links: Link.fromJSONArray(jsonObject.optJSONArray("links"),
            normalizeHref: normalizeHref));
  }

  /// Creates a list of [Contributor] from its RWPM JSON representation.
  ///
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If a contributor can't be parsed, a warning will be logged with [warnings].
  static List<Contributor> fromJsonArray(dynamic json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json is String || json is Map<String, dynamic>) {
      return [json]
          .map((it) => Contributor.fromJson(it, normalizeHref: normalizeHref))
          .whereNotNull()
          .toList();
    } else if (json is List) {
      return json
          .map((it) => Contributor.fromJson(it, normalizeHref: normalizeHref))
          .whereNotNull()
          .toList();
    }
    return [];
  }
}
