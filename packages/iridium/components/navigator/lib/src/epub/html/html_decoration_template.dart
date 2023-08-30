import 'package:flutter/material.dart' hide Decoration;
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_navigator/src/epub/decoration.dart';

/// Determines the number of created HTML elements and their position relative to the matching
/// DOM range.
class Layout {
  /// A single HTML element covering the smallest region containing all CSS border boxes. */
  static const Layout bounds = Layout("bounds");

  /// One HTML element for each CSS border box (e.g. line of text). */
  static const Layout boxes = Layout("boxes");
  final String value;

  const Layout(this.value);
}

/// Indicates how the width of each created HTML element expands in the viewport.
class Width {
  /// Smallest width fitting the CSS border box.
  static const Width wrap = Width("wrap");

  /// Fills the bounds layout.
  static const Width bounds = Width("bounds");

  /// Fills the anchor page, useful for dual page.
  static const Width viewport = Width("viewport");

  /// Fills the whole viewport.
  static const Width page = Width("page");
  final String value;

  const Width(this.value);
}

class _Padding {
  final int left;
  final int top;
  final int right;
  final int bottom;

  // ignore: unused_element
  _Padding({this.left = 0, this.top = 0, this.right = 0, this.bottom = 0});
}

String _defaultElement(decoration) => "<div/>";

/// An [HtmlDecorationTemplate] renders a [Decoration] into a set of HTML elements and associated
/// stylesheet.
///
/// @param layout Determines the number of created HTML elements and their position relative to the
///        matching DOM range.
/// @param width Indicates how the width of each created HTML element expands in the viewport.
/// @param element Closure used to generate a new HTML element for the given [Decoration]. Several
///        elements will be created for a single decoration when using the BOXES layout.
///        The Navigator will automatically position the created elements according to the
///        decoration's Locator. The template is only responsible for the look and feel of the
///        generated elements.
///        Every child elements with a `data-activable="1"` HTML attribute will handle tap events.
///        If no element has this attribute, the root element will handle taps.
/// @param stylesheet A CSS stylesheet which will be injected in the resource, which can be
///        referenced by the created elements. Make sure to use unique identifiers for your classes
///        and IDs to avoid conflicts with the HTML resource itself. Best practice is to prefix with
///        your app name. r2- and readium- are reserved by the Readium toolkit.
class HtmlDecorationTemplate implements JSONable {
  static const String highlightGroup = "highlights";
  static const String annotationSuffix = "annotation";
  static const String highlightSuffix = "highlight";
  static const String underlineSuffix = "underline";
  final Layout layout;
  final Width width;
  final String Function(Decoration) element;
  final String? stylesheet;

  static int _classNamesId = 0;

  static String _createUniqueClassName(String key) =>
      "r2-$key-${++_classNamesId}";

  HtmlDecorationTemplate(
      {required this.layout,
      this.width = Width.wrap,
      this.stylesheet,
      this.element = _defaultElement});

  @override
  Map<String, dynamic> toJson() => {
        "layout": layout.value,
        "width": width.value,
        if (stylesheet != null) "stylesheet": stylesheet,
      };

  /// Creates a new decoration template for the highlight style.
  factory HtmlDecorationTemplate.highlight(
          {required int defaultTint,
          required int lineWeight,
          required int cornerRadius,
          required double alpha}) =>
      HtmlDecorationTemplate.createTemplate(
          asHighlight: true,
          defaultTint: defaultTint,
          lineWeight: lineWeight,
          cornerRadius: cornerRadius,
          alpha: alpha);

  /// Creates a new decoration template for the underline style.
  factory HtmlDecorationTemplate.underline(
          {required int defaultTint,
          required int lineWeight,
          required int cornerRadius,
          required double alpha}) =>
      HtmlDecorationTemplate.createTemplate(
          asHighlight: false,
          defaultTint: defaultTint,
          lineWeight: lineWeight,
          cornerRadius: cornerRadius,
          alpha: alpha);

  /// @param asHighlight When true, the non active style is of an highlight. Otherwise, it is
  /// an underline.
  factory HtmlDecorationTemplate.createTemplate(
      {required bool asHighlight,
      required int defaultTint,
      required int lineWeight,
      required int cornerRadius,
      required double alpha}) {
    String className = _createUniqueClassName(
        (asHighlight) ? highlightSuffix : underlineSuffix);
    _Padding padding = _Padding(left: 1, right: 1);
    return HtmlDecorationTemplate(
        layout: Layout.boxes,
        element: (decoration) {
          int tint = (decoration.style as Tinted?)?.tint ?? defaultTint;
          bool isActive = (decoration.style as Activable?)?.isActive ?? false;
          String css = "";
          if (asHighlight || isActive) {
            css +=
                "background-color: ${tint.toCss(opacity: alpha)} !important;";
          }
          if (!asHighlight || isActive) {
            css += "border-bottom: ${lineWeight}px solid ${tint.toCss()};";
          }
          return """
            <div class="$className" style="$css"/>"
            """;
        },
        stylesheet: """
            .$className {
                margin-left: ${-padding.left}px;
                padding-right: ${padding.left + padding.right}px;
                margin-top: ${-padding.top}px;
                padding-bottom: ${padding.top + padding.bottom}px;
                border-radius: ${cornerRadius}px;
                box-sizing: border-box;
            }
            """);
  }
}

class HtmlDecorationTemplates implements JSONable {
  final Map<Type, HtmlDecorationTemplate> styles;

  HtmlDecorationTemplates._(this.styles);

  HtmlDecorationTemplate? get(Type style) => styles[style];

  void set(dynamic style, HtmlDecorationTemplate template) {
    styles[style] = template;
  }

  @override
  Map<String, dynamic> toJson() => {
        for (MapEntry<Type, HtmlDecorationTemplate> it in styles.entries)
          it.key.toString(): it.value.toJson()
      };

  HtmlDecorationTemplates copy() => HtmlDecorationTemplates._(Map.of(styles));

  /// Creates the default list of decoration styles with associated HTML templates.
  factory HtmlDecorationTemplates.defaultTemplates(
          {Color defaultTint = Colors.yellow,
          int lineWeight = 2,
          int cornerRadius = 3,
          double alpha = 0.3}) =>
      HtmlDecorationTemplates._({
        HighlightDecorationStyle: HtmlDecorationTemplate.highlight(
            defaultTint: defaultTint.value,
            lineWeight: lineWeight,
            cornerRadius: cornerRadius,
            alpha: alpha),
        UnderlineDecorationStyle: HtmlDecorationTemplate.underline(
            defaultTint: defaultTint.value,
            lineWeight: lineWeight,
            cornerRadius: cornerRadius,
            alpha: alpha),
      });
}

/// Converts the receiver color int to a CSS expression.
///
/// @param alpha When set, overrides the actual color alpha.
extension ColorInt on int {
  String toCss({double? opacity}) {
    Color c = Color(this);
    int r = c.red;
    int g = c.green;
    int b = c.blue;
    double a = opacity ?? c.opacity;
    return "rgba($r, $g, $b, $a)";
  }
}
