import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/decoration.dart';
import 'package:mno_navigator/src/epub/decoration_change.dart';
import 'package:mno_navigator/src/epub/html/html_decoration_template.dart';
import 'package:mno_navigator/src/epub/model/decoration_style_annotation_mark.dart';
import 'package:mno_shared/publication.dart';

extension DecorationChangeExt on DecorationChange {
  String? javascript(HtmlDecorationTemplates templates) {
    Map<String, dynamic>? toJson(Decoration decoration) {
      HtmlDecorationTemplate? template =
          templates.get(decoration.style.runtimeType);
      if (template == null) {
        Fimber.e(
            "Decoration style not registered: ${decoration.style.runtimeType}");
        return null;
      }
      return decoration.toJson()..["element"] = template.element(decoration);
    }

    if (this is DecorationChangeAdded) {
      return toJson((this as DecorationChangeAdded).decoration)
          ?.let((it) => "group.add(${json.encode(it)});");
    } else if (this is DecorationChangeUpdated) {
      return toJson((this as DecorationChangeUpdated).decoration)
          ?.let((it) => "group.update(${json.encode(it)});");
    } else if (this is DecorationChangeRemoved) {
      return "group.remove('${(this as DecorationChangeRemoved).id}');";
    } else if (this is DecorationChangeMoved) {
      // Not supported for now
      return null;
    }
    return null;
  }
}

extension DecorationChangeList on Iterable<DecorationChange> {
  String? javascriptForGroup(String group, HtmlDecorationTemplates templates) {
    if (this.isEmpty) return null;

    return """
        // Using requestAnimationFrame helps to make sure the page is fully laid out before adding the
        // decorations.
        requestAnimationFrame(function () {
            let group = readium.getDecorations('$group');
            ${mapNotNull((it) => it.javascript(templates)).joinToString(separator: "\n")}
        });
        """;
  }
}

extension ReaderAnnotationDecoration on ReaderAnnotation {
  /// Creates a list of [Decoration] for the receiver [Highlight].
  List<Decoration> toDecorations({required bool isActive}) {
    Decoration createDecoration(
            {required String idSuffix, required DecorationStyle style}) =>
        Decoration(
          id: "$id-$idSuffix",
          locator: Locator.fromJsonString(location)!,
          style: style,
        );

    DecorationStyle? decorationStyle;
    if (tint != null) {
      switch (style) {
        case HighlightStyle.highlight:
          decorationStyle =
              DecorationStyle.highlight(tint: tint!, isActive: isActive);
          break;
        case HighlightStyle.underline:
          decorationStyle =
              DecorationStyle.underline(tint: tint!, isActive: isActive);
          break;
      }
    }
    return [
      // Decoration for the actual highlight / underline.
      if (decorationStyle != null)
        createDecoration(
          idSuffix: HtmlDecorationTemplate.highlightSuffix,
          style: decorationStyle,
        ),
      // TODO Add support for DecorationStyleAnnotationMark
      // Additional page margin icon decoration, if the highlight has an associated note.
      if (annotation != null && annotation!.isNotEmpty)
        createDecoration(
          idSuffix: HtmlDecorationTemplate.annotationSuffix,
          style: DecorationStyleAnnotationMark(tint: tint!),
        ),
    ];
  }
}
