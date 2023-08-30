// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

/// https://readium.org/webpub-manifest/schema/metadata.schema.json
///
/// @param readingProgression WARNING: This contains the reading progression as declared in the
///     publication, so it might be [AUTO]. To lay out the content, use [effectiveReadingProgression]
///     to get the calculated reading progression from the declared direction and the language.
/// @param otherMetadata Additional metadata for extensions, as a JSON dictionary.
class Metadata with EquatableMixin, JSONable {
  Metadata(
      {this.identifier,
      this.type,
      required this.localizedTitle,
      this.localizedSubtitle,
      this.modified,
      this.published,
      this.languages = const [],
      this.localizedSortAs,
      this.subjects = const [],
      this.authors = const [],
      this.contributors = const [],
      this.translators = const [],
      this.editors = const [],
      this.artists = const [],
      this.illustrators = const [],
      this.letterers = const [],
      this.pencilers = const [],
      this.colorists = const [],
      this.inkers = const [],
      this.narrators = const [],
      this.publishers = const [],
      this.imprints = const [],
      this.description,
      this.duration,
      this.numberOfPages,
      Map<String, List<Collection>>? belongsTo,
      this.belongsToCollections = const [],
      this.belongsToSeries = const [],
      this.readingProgression = ReadingProgression.auto,
      this.rendition,
      this.otherMetadata = const {}})
      : this.belongsTo = belongsTo ?? {} {
    if (belongsToCollections.isNotEmpty) {
      this.belongsTo["collection"] = belongsToCollections;
    }
    if (belongsToSeries.isNotEmpty) {
      this.belongsTo["series"] = belongsToSeries;
    }
  }

  /// An URI used as the unique identifier for this [Publication].
  final String? identifier; // nullable
  final String? type; // nullable

  final LocalizedString localizedTitle;
  final LocalizedString? localizedSubtitle; // nullable
  final DateTime? modified; // nullable
  final DateTime? published; // nullable

  /// Languages used in the publication.
  final List<String> languages; // BCP 47 tag

  /// (Nullable) First language in the publication.
  String? get language => (languages.isNotEmpty ? languages.first : null);

  /// Alternative title to be used for sorting the publication in the library.
  final LocalizedString? localizedSortAs; // nullable

  /// Themes/subjects of the publication.
  final List<Subject> subjects;

  final List<Contributor> authors;
  final List<Contributor> publishers;
  final List<Contributor> contributors;
  final List<Contributor> translators;
  final List<Contributor> editors;
  final List<Contributor> artists;
  final List<Contributor> illustrators;
  final List<Contributor> letterers;
  final List<Contributor> pencilers;
  final List<Contributor> colorists;
  final List<Contributor> inkers;
  final List<Contributor> narrators;
  final List<Contributor> imprints;

  final String? description; // nullable
  final double? duration; // nullable

  /// Number of pages in the publication, if available.
  final int? numberOfPages; // nullable

  final Map<String, List<Collection>> belongsTo;
  final List<Collection> belongsToCollections;
  final List<Collection> belongsToSeries;

  /// Direction of the [Publication] reading progression.
  final ReadingProgression readingProgression;

  /// Information about the contents rendition.
  final Presentation? rendition; // nullable if not an EPUB [Publication]
  final Map<String, dynamic> otherMetadata;

  ReadingProgression get effectiveReadingProgression {
    if (readingProgression != ReadingProgression.auto) {
      return readingProgression;
    }

    // https://github.com/readium/readium-css/blob/develop/docs/CSS16-internationalization.md#missing-page-progression-direction
    if (languages.length != 1) {
      return ReadingProgression.ltr;
    }

    String language = languages.first.toLowerCase();

    if (language == "zh-hant" || language == "zh-tw") {
      return ReadingProgression.rtl;
    }

    // The region is ignored for ar, fa and he.
    language = language.split("-").first;
    if (["ar", "fa", "he"].contains(language)) {
      return ReadingProgression.rtl;
    }
    return ReadingProgression.ltr;
  }

  /// Syntactic sugar to access the [otherMetadata] values by subscripting [Metadata] directly.
  /// `metadata["layout"] == metadata.otherMetadata["layout"]`
  dynamic operator [](String key) => otherMetadata[key];

  /// Returns the default translation string for the [localizedTitle].
  String get title => localizedTitle.string;

  /// Returns the default translation string for the [localizedSortAs].
  String? get sortAs => localizedSortAs?.string;

  @override
  List<Object?> get props => [
        identifier,
        type,
        localizedTitle,
        localizedSubtitle,
        modified,
        published,
        languages,
        localizedSortAs,
        subjects,
        authors,
        translators,
        editors,
        artists,
        illustrators,
        letterers,
        pencilers,
        colorists,
        inkers,
        narrators,
        contributors,
        publishers,
        imprints,
        readingProgression,
        description,
        duration,
        numberOfPages,
        belongsTo,
        rendition,
        otherMetadata
      ];

  /// Serializes a [Metadata] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() => Map.from(otherMetadata)
    ..putOpt("identifier", identifier)
    ..putOpt("@type", type)
    ..putJSONableIfNotEmpty("title", localizedTitle)
    ..putJSONableIfNotEmpty("subtitle", localizedSubtitle)
    ..putOpt("modified", modified?.toIso8601String())
    ..putOpt("published", published?.toIso8601String())
    ..putIterableIfNotEmpty("language", languages)
    ..putJSONableIfNotEmpty("sortAs", localizedSortAs)
    ..putIterableIfNotEmpty("subject", subjects)
    ..putIterableIfNotEmpty("author", authors)
    ..putIterableIfNotEmpty("translator", translators)
    ..putIterableIfNotEmpty("editor", editors)
    ..putIterableIfNotEmpty("artist", artists)
    ..putIterableIfNotEmpty("illustrator", illustrators)
    ..putIterableIfNotEmpty("letterer", letterers)
    ..putIterableIfNotEmpty("penciler", pencilers)
    ..putIterableIfNotEmpty("colorist", colorists)
    ..putIterableIfNotEmpty("inker", inkers)
    ..putIterableIfNotEmpty("narrator", narrators)
    ..putIterableIfNotEmpty("contributor", contributors)
    ..putIterableIfNotEmpty("publisher", publishers)
    ..putIterableIfNotEmpty("imprint", imprints)
    ..putOpt("readingProgression", readingProgression.value)
    ..putOpt("description", description)
    ..putOpt("duration", duration)
    ..putOpt("numberOfPages", numberOfPages)
    ..putMapIfNotEmpty("belongsTo", belongsTo);

  /// Parses a [Metadata] from its RWPM JSON representation.
  ///
  /// If the metadata can't be parsed, a warning will be logged with [warnings].
  static Metadata? fromJson(Map<String, dynamic>? json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json == null) {
      return null;
    }
    LocalizedString? localizedTitle =
        LocalizedString.fromJson(json.remove("title"));
    if (localizedTitle == null) {
      Fimber.i("[title] is required $json");
      return null;
    }
    String? identifier = json.remove("identifier") as String?;
    String? type = json.remove("@type") as String?;
    LocalizedString? localizedSubtitle =
        LocalizedString.fromJson(json.remove("subtitle"));
    DateTime? modified = (json.remove("modified") as String?)?.iso8601ToDate();
    DateTime? published =
        (json.remove("published") as String?)?.iso8601ToDate();

    List<String> languages =
        json.optStringsFromArrayOrSingle("language", remove: true);
    LocalizedString? localizedSortAs =
        LocalizedString.fromJson(json.remove("sortAs"));
    List<Subject> subjects = Subject.fromJSONArray(json.remove("subject"),
        normalizeHref: normalizeHref);
    List<Contributor> authors = Contributor.fromJsonArray(json.remove("author"),
        normalizeHref: normalizeHref);
    List<Contributor> translators = Contributor.fromJsonArray(
        json.remove("translator"),
        normalizeHref: normalizeHref);
    List<Contributor> editors = Contributor.fromJsonArray(json.remove("editor"),
        normalizeHref: normalizeHref);
    List<Contributor> artists = Contributor.fromJsonArray(json.remove("artist"),
        normalizeHref: normalizeHref);
    List<Contributor> illustrators = Contributor.fromJsonArray(
        json.remove("illustrator"),
        normalizeHref: normalizeHref);
    List<Contributor> letterers = Contributor.fromJsonArray(
        json.remove("letterer"),
        normalizeHref: normalizeHref);
    List<Contributor> pencilers = Contributor.fromJsonArray(
        json.remove("penciler"),
        normalizeHref: normalizeHref);
    List<Contributor> colorists = Contributor.fromJsonArray(
        json.remove("colorist"),
        normalizeHref: normalizeHref);
    List<Contributor> inkers = Contributor.fromJsonArray(json.remove("inker"),
        normalizeHref: normalizeHref);
    List<Contributor> narrators = Contributor.fromJsonArray(
        json.remove("narrator"),
        normalizeHref: normalizeHref);
    List<Contributor> contributors = Contributor.fromJsonArray(
        json.remove("contributor"),
        normalizeHref: normalizeHref);
    List<Contributor> publishers = Contributor.fromJsonArray(
        json.remove("publisher"),
        normalizeHref: normalizeHref);
    List<Contributor> imprints = Contributor.fromJsonArray(
        json.remove("imprint"),
        normalizeHref: normalizeHref);
    ReadingProgression readingProgression = ReadingProgression.fromValue(
        json.remove("readingProgression") as String?);
    String? description = json.remove("description") as String?;
    double? duration = json.optPositiveDouble("duration", remove: true);
    int? numberOfPages = json.optPositiveInt("numberOfPages", remove: true);

    Map<String, dynamic> belongsToJson =
        (json.remove("belongsTo") as Map<String, dynamic>? ??
            json.remove("belongs_to") as Map<String, dynamic>? ??
            {});
    Map<String, List<Collection>> belongsTo = {};
    for (String key in belongsToJson.keys) {
      if (!belongsToJson.isNull(key)) {
        dynamic value = belongsToJson[key];
        belongsTo[key] =
            Contributor.fromJsonArray(value, normalizeHref: normalizeHref);
      }
    }

    return Metadata(
      identifier: identifier,
      type: type,
      localizedTitle: localizedTitle,
      localizedSubtitle: localizedSubtitle,
      localizedSortAs: localizedSortAs,
      modified: modified,
      published: published,
      languages: languages,
      subjects: subjects,
      authors: authors,
      translators: translators,
      editors: editors,
      artists: artists,
      illustrators: illustrators,
      letterers: letterers,
      pencilers: pencilers,
      colorists: colorists,
      inkers: inkers,
      narrators: narrators,
      contributors: contributors,
      publishers: publishers,
      imprints: imprints,
      readingProgression: readingProgression,
      description: description,
      duration: duration,
      numberOfPages: numberOfPages,
      belongsTo: belongsTo,
      otherMetadata: json,
    );
  }

  Metadata copy({
    String? identifier,
    String? type,
    LocalizedString? localizedTitle,
    LocalizedString? localizedSubtitle,
    DateTime? modified,
    DateTime? published,
    List<String>? languages,
    LocalizedString? localizedSortAs,
    List<Subject>? subjects,
    List<Contributor>? authors,
    List<Contributor>? publishers,
    List<Contributor>? contributors,
    List<Contributor>? translators,
    List<Contributor>? editors,
    List<Contributor>? artists,
    List<Contributor>? illustrators,
    List<Contributor>? letterers,
    List<Contributor>? pencilers,
    List<Contributor>? colorists,
    List<Contributor>? inkers,
    List<Contributor>? narrators,
    List<Contributor>? imprints,
    String? description,
    double? duration,
    int? numberOfPages,
    Map<String, List<Collection>>? belongsTo,
    ReadingProgression? readingProgression,
    Presentation? rendition,
    Map<String, dynamic>? otherMetadata,
  }) =>
      Metadata(
        identifier: identifier ?? this.identifier,
        type: type ?? this.type,
        localizedTitle: localizedTitle ?? this.localizedTitle,
        localizedSubtitle: localizedSubtitle ?? this.localizedSubtitle,
        modified: modified ?? this.modified,
        published: published ?? this.published,
        languages: languages ?? this.languages,
        localizedSortAs: localizedSortAs ?? this.localizedSortAs,
        subjects: subjects ?? this.subjects,
        authors: authors ?? this.authors,
        publishers: publishers ?? this.publishers,
        contributors: contributors ?? this.contributors,
        translators: translators ?? this.translators,
        editors: editors ?? this.editors,
        artists: artists ?? this.artists,
        illustrators: illustrators ?? this.illustrators,
        letterers: letterers ?? this.letterers,
        pencilers: pencilers ?? this.pencilers,
        colorists: colorists ?? this.colorists,
        inkers: inkers ?? this.inkers,
        narrators: narrators ?? this.narrators,
        imprints: imprints ?? this.imprints,
        description: description ?? this.description,
        duration: duration ?? this.duration,
        numberOfPages: numberOfPages ?? this.numberOfPages,
        belongsTo: belongsTo ?? this.belongsTo,
        readingProgression: readingProgression ?? this.readingProgression,
        rendition: rendition ?? this.rendition,
        otherMetadata: otherMetadata ?? this.otherMetadata,
      );

  @override
  String toString() => 'Metadata($props)';
}
