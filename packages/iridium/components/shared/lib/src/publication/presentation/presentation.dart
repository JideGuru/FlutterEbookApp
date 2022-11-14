// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

/// The Presentation Hints extension defines a number of hints for User Agents about the way content
/// should be presented to the user.
///
/// https://readium.org/webpub-manifest/extensions/presentation.html
/// https://readium.org/webpub-manifest/schema/extensions/presentation/metadata.schema.json
///
/// These properties are nullable to avoid having default values when it doesn't make sense for a
/// given [Publication]. If a navigator needs a default value when not specified,
/// Presentation.DEFAULT_X and Presentation.X.DEFAULT can be used.
///
/// @param [clipped] Specifies whether or not the parts of a linked resource that flow out of the
///     viewport are clipped.
/// @param [continuous] Indicates how the progression between resources from the [readingOrder] should
///     be handled.
/// @param [fit] Suggested method for constraining a resource inside the viewport.
/// @param [orientation] Suggested orientation for the device when displaying the linked resource.
/// @param [overflow] Suggested method for handling overflow while displaying the linked resource.
/// @param [spread] Indicates the condition to be met for the linked resource to be rendered within a
///     synthetic spread.
/// @param [layout] Hints how the layout of the resource should be presented (EPUB extension).
class Presentation with EquatableMixin, JSONable {
  Presentation({
    this.layout,
    this.orientation,
    this.overflow,
    this.spread,
    this.fit,
    this.clipped,
    this.continuous,
  });

  /// Creates a [Properties] from its RWPM JSON representation.
  factory Presentation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Presentation();
    }
    return Presentation(
        clipped: json.optNullableBoolean("clipped"),
        continuous: json.optNullableBoolean("continuous"),
        fit: PresentationFit.from(json.optString("fit")),
        orientation:
            PresentationOrientation.from(json.optString("orientation")),
        overflow: PresentationOverflow.from(json.optString("overflow")),
        spread: PresentationSpread.from(json.optString("spread")),
        layout: EpubLayout.from(json.optString("layout")));
  }

  /// Hints how the layout of the resource should be presented.
  final EpubLayout? layout;

  /// Suggested orientation for the device when displaying the linked resource.
  final PresentationOrientation? orientation;

  /// Suggested method for handling overflow while displaying the linked resource.
  final PresentationOverflow? overflow;

  /// Indicates the condition to be met for the linked resource to be rendered within a synthetic spread.
  final PresentationSpread? spread;

  final PresentationFit? fit;
  final bool? clipped;
  final bool? continuous;

  @override
  List<Object?> get props =>
      [layout, orientation, overflow, spread, fit, clipped, continuous];

  /// Determines the layout of the given resource in this publication.
  /// The default layout is reflowable.
  EpubLayout layoutOf(Link link) =>
      link.properties.layout ?? layout ?? EpubLayout.reflowable;

  /// Serializes a [Presentation] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() => {}
    ..putOpt("clipped", clipped)
    ..putOpt("continuous", continuous)
    ..putOpt("fit", fit?.value)
    ..putOpt("orientation", orientation?.value)
    ..putOpt("overflow", overflow?.value)
    ..putOpt("spread", spread?.value)
    ..putOpt("layout", layout?.value);

  @override
  String toString() => 'Presentation(${toJson()})';
}

/// Suggested method for constraining a resource inside the viewport.
class PresentationFit with EquatableMixin {
  static const PresentationFit width = PresentationFit._("width");
  static const PresentationFit height = PresentationFit._("height");
  static const PresentationFit contain = PresentationFit._("contain");
  static const PresentationFit cover = PresentationFit._("cover");
  static const List<PresentationFit> _values = [width, height, contain, cover];

  final String value;

  const PresentationFit._(this.value);

  @override
  List<Object> get props => [value];

  static PresentationFit? from(String? value) =>
      _values.firstOrNullWhere((element) => element.value == value);
}

/// Hints how the layout of the resource should be presented.
class EpubLayout with EquatableMixin {
  // Fixed layout.
  static const EpubLayout fixed = EpubLayout._("fixed");

  // Apply dynamic pagination when rendering.
  static const EpubLayout reflowable = EpubLayout._("reflowable");
  static const List<EpubLayout> _values = [fixed, reflowable];

  final String value;

  const EpubLayout._(this.value);

  @override
  List<Object> get props => [value];

  static EpubLayout? from(String? value) =>
      _values.firstOrNullWhere((element) => element.value == value);
}

/// Suggested orientation for the device when displaying the linked resource.
class PresentationOrientation with EquatableMixin {
  // Specifies that the Reading System can determine the orientation to rendered the spine item in.
  static const PresentationOrientation auto = PresentationOrientation._("auto");

  // Specifies that the given spine item is to be rendered in landscape orientation.
  static const PresentationOrientation landscape =
      PresentationOrientation._("landscape");

  // Specifies that the given spine item is to be rendered in portrait orientation.
  static const PresentationOrientation portrait =
      PresentationOrientation._("portrait");
  static const List<PresentationOrientation> _values = [
    auto,
    landscape,
    portrait
  ];

  final String value;

  const PresentationOrientation._(this.value);

  @override
  List<Object> get props => [value];

  static PresentationOrientation? from(String? value) =>
      _values.firstOrNullWhere((element) => element.value == value);
}

/// Suggested method for handling overflow while displaying the linked resource.
class PresentationOverflow with EquatableMixin {
  // Indicates no preference for overflow content handling by the Author.
  static const PresentationOverflow auto = PresentationOverflow._("auto");

  // Indicates the Author preference is to dynamically paginate content overflow.
  static const PresentationOverflow paginated =
      PresentationOverflow._("paginated");

  // Indicates the Author preference is to provide a scrolled view for overflow content, and each spine item with this property is to be rendered as separate scrollable document.
  static const PresentationOverflow scrolled =
      PresentationOverflow._("scrolled");
  static const List<PresentationOverflow> _values = [auto, paginated, scrolled];

  final String value;

  const PresentationOverflow._(this.value);

  @override
  List<Object> get props => [value];

  static PresentationOverflow? from(String? value) =>
      _values.firstOrNullWhere((element) => element.value == value);
}

/// Indicates how the linked resource should be displayed in a reading
/// environment that displays synthetic spreads.
class PresentationPage with EquatableMixin {
  static const PresentationPage left = PresentationPage._("left");
  static const PresentationPage right = PresentationPage._("right");
  static const PresentationPage center = PresentationPage._("center");
  static const List<PresentationPage> _values = [left, right, center];

  final String value;

  const PresentationPage._(this.value);

  @override
  List<Object> get props => [value];

  static PresentationPage? from(String? value) =>
      _values.firstOrNullWhere((element) => element.value == value);
}

/// Indicates the condition to be met for the linked resource to be rendered within a synthetic spread.
class PresentationSpread with EquatableMixin {
  // Specifies the Reading System can determine when to render a synthetic spread for the readingOrder item.
  static const PresentationSpread auto = PresentationSpread._("auto");

  // Specifies the Reading System should render a synthetic spread for the readingOrder item in both portrait and landscape orientations.
  static const PresentationSpread both = PresentationSpread._("both");

  // Specifies the Reading System should not render a synthetic spread for the readingOrder item.
  static const PresentationSpread none = PresentationSpread._("none");

  // Specifies the Reading System should render a synthetic spread for the readingOrder item only when in landscape orientation.
  static const PresentationSpread landscape = PresentationSpread._("landscape");
  static const List<PresentationSpread> _values = [auto, both, none, landscape];

  final String value;

  const PresentationSpread._(this.value);

  @override
  List<Object> get props => [value];

  static PresentationSpread? from(String? value) =>
      _values.firstOrNullWhere((element) => element.value == value);
}
