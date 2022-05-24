// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

/// Subject of a [Publication].
///
/// See https://github.com/readium/webpub-manifest/tree/master/contexts/default#subjects
class Subject with EquatableMixin, JSONable {
  const Subject(
      {required this.localizedName,
      this.localizedSortAs,
      this.scheme,
      this.code,
      this.links = const []});

  final LocalizedString localizedName;
  final LocalizedString? localizedSortAs;
  final String? scheme;
  final String? code;
  final List<Link> links;

  factory Subject.fromString(String name) =>
      Subject(localizedName: LocalizedString.fromString(name));

  /// Returns the default translation string for the [localizedName].
  String get name => localizedName.string;

  /// Returns the default translation string for the [localizedSortAs].
  String? get sortAs => localizedSortAs?.string;

  @override
  List<Object?> get props =>
      [localizedName, localizedSortAs, scheme, code, links];

  @override
  String toString() => 'Subject($props)';

  @override
  Map<String, dynamic> toJson() => {}
    ..putJSONableIfNotEmpty("name", localizedName)
    ..putJSONableIfNotEmpty("sortAs", localizedSortAs)
    ..putOpt("scheme", scheme)
    ..putOpt("code", code)
    ..putIterableIfNotEmpty("links", links);

  /// Parses a [Subject] from its RWPM JSON representation.
  ///
  /// A subject can be parsed from a single string, or a full-fledged object.
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If the subject can't be parsed, a warning will be logged with [warnings].
  static Subject? fromJson(dynamic json,
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
    return Subject(
        localizedName: localizedName,
        localizedSortAs: LocalizedString.fromJson(jsonObject.remove("sortAs")),
        scheme: jsonObject.optNullableString("scheme"),
        code: jsonObject.optNullableString("code"),
        links: Link.fromJSONArray(jsonObject.optJSONArray("links"),
            normalizeHref: normalizeHref));
  }

  /// Creates a list of [Subject] from its RWPM JSON representation.
  ///
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If a subject can't be parsed, a warning will be logged with [warnings].
  static List<Subject> fromJSONArray(dynamic json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json is String || json is Map<String, dynamic>) {
      return [json]
          .map((it) => Subject.fromJson(it, normalizeHref: normalizeHref))
          .whereNotNull()
          .toList();
    } else if (json is List) {
      return json
          .map((it) => Subject.fromJson(it, normalizeHref: normalizeHref))
          .whereNotNull()
          .toList();
    }
    return [];
  }
}
