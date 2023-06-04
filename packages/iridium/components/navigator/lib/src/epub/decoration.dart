import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

/// A type of [Style] which has a tint color.
mixin Tinted {
  int get tint;
}

/// A type of [Style] which can be in an "active" state.
mixin Activable {
  bool get isActive;
}

/// The Decoration Style determines the look and feel of a decoration once rendered by a
/// Navigator.
///
/// It is media type agnostic, meaning that each Navigator will translate the style into a set of
/// rendering instructions which makes sense for the resource type.
class DecorationStyle {
  DecorationStyle();

  static HighlightDecorationStyle highlight(
          {required int tint, bool isActive = false}) =>
      HighlightDecorationStyle._(tint: tint, isActive: isActive);

  static UnderlineDecorationStyle underline(
          {required int tint, bool isActive = false}) =>
      UnderlineDecorationStyle._(tint: tint, isActive: isActive);

  static MarginLineDecorationStyle marginLine(
          {required int tint, bool isActive = false}) =>
      MarginLineDecorationStyle._(tint: tint, isActive: isActive);
}

class HighlightDecorationStyle extends DecorationStyle with Tinted, Activable {
  @override
  final int tint;
  @override
  final bool isActive;

  HighlightDecorationStyle._({required this.tint, this.isActive = false});
}

class UnderlineDecorationStyle extends DecorationStyle with Tinted, Activable {
  @override
  final int tint;
  @override
  final bool isActive;

  UnderlineDecorationStyle._({required this.tint, this.isActive = false});
}

class MarginLineDecorationStyle extends DecorationStyle with Tinted, Activable {
  @override
  final int tint;
  @override
  final bool isActive;

  MarginLineDecorationStyle._({required this.tint, this.isActive = false});
}

/// A decoration is a user interface element drawn on top of a publication. It associates a [style]
/// to be rendered with a discrete [locator] in the publication.
///
/// For example, decorations can be used to draw highlights, images or buttons.
///
/// @param id An identifier for this decoration. It must be unique in the group the decoration is applied to.
/// @param locator Location in the publication where the decoration will be rendered.
/// @param style Declares the look and feel of the decoration.
/// @param extras Additional context data specific to a reading app. Readium does not use it.
class Decoration implements JSONable {
  final String id;
  final Locator locator;
  final DecorationStyle style;

  Decoration({
    required this.id,
    required this.locator,
    required this.style,
  });

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "locator": locator.toJson(),
        "style": style.runtimeType.toString(),
      };
}
