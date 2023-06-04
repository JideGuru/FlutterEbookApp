// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_shared/publication.dart';

const int _emptyIntValue = -1;
const double _emptyDoubleValue = -1;

extension IntCheck on int? {
  int? check(int? defaultValue) =>
      (this == _emptyIntValue) ? defaultValue : this;
}

extension DoubleCheck on double? {
  double? check(double? defaultValue) =>
      (this == _emptyDoubleValue) ? defaultValue : this;
}

/// Provides a precise location in a publication in a format that can be stored and shared.
///
/// There are many different use cases for locators:
///  - getting back to the last position in a publication
///  - bookmarks
///  - highlights & annotations
///  - search results
///  - human-readable (and shareable) reference in a publication
///
/// https://github.com/readium/architecture/tree/master/locators
class Locator with EquatableMixin implements JSONable {
  final String href;
  final String type;
  final String? title;
  final Locations locations;
  final LocatorText text;

  const Locator(
      {required this.href,
      required this.type,
      this.title,
      this.locations = const Locations(),
      this.text = const LocatorText()});

  static Locator? fromJsonString(String jsonString) {
    try {
      //Fimber.d("jsonString $jsonString");
      Map<String, dynamic> json = JsonCodec().decode(jsonString);
      return Locator.fromJson(json);
    } catch (ex, st) {
      Fimber.e("ERROR", ex: ex, stacktrace: st);
    }
    return null;
  }

  static Locator? fromJson(Map<String, dynamic>? json) {
    String? href = json?.optNullableString("href");
    String? type = json?.optNullableString("type");
    if (href == null || type == null) {
      Fimber.i("[href] and [type] are required $json");
      return null;
    }
    return Locator(
        href: href,
        type: type,
        title: json.optNullableString("title"),
        locations: Locations.fromJson(json.optJSONObject("locations")),
        text: LocatorText.fromJson(json.optJSONObject("text")));
  }

  String get json => JsonCodec().encode(toJson());

  @override
  Map<String, dynamic> toJson() => {"href": href, "type": type}
    ..putOpt("title", title)
    ..putJSONableIfNotEmpty("locations", locations)
    ..putJSONableIfNotEmpty("text", text);

  Locator copy({
    String? href,
    String? type,
    String? title,
    Locations? locations,
    LocatorText? text,
  }) =>
      Locator(
        href: href ?? this.href,
        type: type ?? this.type,
        title: title ?? this.title,
        locations: locations ?? this.locations,
        text: text ?? this.text,
      );

  /// Shortcut to get a copy of the [Locator] with different [Locations] sub-properties.
  Locator copyWithLocations(
          {List<String>? fragments,
          double? progression = _emptyDoubleValue,
          int? position = _emptyIntValue,
          double? totalProgression = _emptyDoubleValue,
          Map<String, dynamic>? otherLocations}) =>
      copy(
          locations: locations.copy(
        fragments: fragments ?? locations.fragments,
        progression: progression.check(locations.progression),
        position: position.check(locations.position),
        totalProgression: totalProgression.check(locations.totalProgression),
        otherLocations: otherLocations ?? locations.otherLocations,
      ));

  @override
  List<Object?> get props => [href, type, title, locations, text];

  @override
  String toString() => 'Locator{href: $href, type: $type, title: $title, '
      'locations: $locations, text: $text}';
}

/// One or more alternative expressions of the location.
/// https://github.com/readium/architecture/tree/master/models/locators#the-location-object
///
/// @param fragments Contains one or more fragment in the resource referenced by the [Locator].
/// @param progression Progression in the resource expressed as a percentage (between 0 and 1).
/// @param position An index in the publication (>= 1).
/// @param totalProgression Progression in the publication expressed as a percentage (between 0
///        and 1).
/// @param otherLocations Additional locations for extensions.
class Locations with EquatableMixin implements JSONable {
  final int? position;
  final double? progression;
  final double? totalProgression;
  final List<String> fragments;
  final Map<String, dynamic> otherLocations;

  const Locations({
    this.position,
    this.progression,
    this.totalProgression,
    this.fragments = const [],
    this.otherLocations = const {},
  });

  Locations copy(
          {int? position = _emptyIntValue,
          double? progression = _emptyDoubleValue,
          double? totalProgression = _emptyDoubleValue,
          List<String>? fragments,
          Map<String, dynamic>? otherLocations}) =>
      Locations(
        progression: progression.check(this.progression),
        position: position.check(this.position),
        totalProgression: totalProgression.check(this.totalProgression),
        fragments: fragments ?? this.fragments,
        otherLocations: otherLocations ?? this.otherLocations,
      );

  int get timestamp {
    if (fragments.isEmpty) {
      return 0;
    }
    String timeFragment =
        fragments.firstWhere((e) => e.startsWith('t='), orElse: () => 't=0');
    return int.parse(timeFragment.replaceFirst('t=', ''));
  }

  /// Syntactic sugar to access the [otherLocations] values by subscripting [Locations] directly.
  /// `locations["cssSelector"] == locations.otherLocations["cssSelector"]`
  dynamic operator [](String key) => otherLocations[key];

  factory Locations.fromJson(Map<String, dynamic>? json) {
    List<String> fragments = json
            ?.optStringsFromArrayOrSingle("fragments", remove: true)
            .takeIf((it) => it.isNotEmpty) ??
        json?.optStringsFromArrayOrSingle("fragment", remove: true) ??
        [];

    double? progression = json
        ?.optNullableDouble("progression", remove: true)
        ?.takeIf((it) => 0.0 <= it && it <= 1.0);

    int? position =
        json?.optNullableInt("position", remove: true)?.takeIf((it) => it > 0);

    double? totalProgression = json
        ?.optNullableDouble("totalProgression", remove: true)
        ?.takeIf((it) => 0.0 <= it && it <= 1.0);

    return Locations(
        fragments: fragments,
        progression: progression,
        position: position,
        totalProgression: totalProgression,
        otherLocations: json ?? {});
  }

  String get json => JsonCodec().encode(toJson());

  @override
  Map<String, dynamic> toJson() => Map.of(otherLocations)
    ..putIterableIfNotEmpty("fragments", fragments)
    ..putOpt("progression", progression)
    ..putOpt("position", position)
    ..putOpt("totalProgression", totalProgression);

  @override
  List<Object?> get props => [
        position,
        progression,
        totalProgression,
        fragments,
        otherLocations,
      ];

  @override
  String toString() =>
      'Location{position: $position, progression: $progression, '
      'totalProgression: $totalProgression, fragments: $fragments}';
}

/// Textual context of the locator.
///
/// A Locator Text Object contains multiple text fragments, useful to give a context to the
/// [Locator] or for highlights.
/// https://github.com/readium/architecture/tree/master/models/locators#the-text-object
///
/// @param before The text before the locator.
/// @param highlight The text at the locator.
/// @param after The text after the locator.
class LocatorText with EquatableMixin implements JSONable {
  final String? before;
  final String? highlight;
  final String? after;

  const LocatorText({this.before, this.highlight, this.after});

  @override
  Map<String, dynamic> toJson() => {}
    ..putOpt("before", before)
    ..putOpt("highlight", highlight)
    ..putOpt("after", after);

  @override
  List<Object?> get props => [before, highlight, after];

  factory LocatorText.fromJson(Map<String, dynamic>? json) => LocatorText(
      before: json?.optNullableString("before"),
      highlight: json?.optNullableString("highlight"),
      after: json?.optNullableString("after"));
}

extension LinkLocator on Link {
  /// Creates a [Locator] from a reading order [Link].
  Locator toLocator() {
    List<String> components = href.split("#");
    String? fragment = (components.length > 1) ? components[1] : null;
    return Locator(
      href: components.firstOrDefault(href),
      type: type ?? "",
      title: title,
      locations: Locations(fragments: fragment?.let((it) => [it]) ?? []),
    );
  }
}
