import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/src/epub/model/decoration_style_annotation_mark.dart';

Future<HtmlDecorationTemplate> annotationMarkTemplate(
    {int? defaultTint, bool displayIcon = true}) async {
  // Converts the pen icon to a base 64 data URL, to be embedded in the decoration stylesheet.
  // Alternatively, serve the image with the local HTTP server and use its URL.
  String imageUrl = "";
  if (displayIcon) {
    ByteData imageData = await rootBundle
        .load("packages/mno_navigator/assets/readium/assets/edit.svg");
    Uint8List list = imageData.buffer
        .asUint8List(imageData.offsetInBytes, imageData.lengthInBytes);
    imageUrl = "data:image/svg+xml;utf8,${utf8.decode(list).urlEncode}";
  }

  String className = "testapp-annotation-mark";
  return HtmlDecorationTemplate(
      layout: Layout.bounds,
      width: Width.page,
      element: (decoration) {
        DecorationStyleAnnotationMark? style =
            decoration.style as DecorationStyleAnnotationMark?;
        int tint = style?.tint ?? defaultTint ?? Colors.yellow.value;
        // Using `data-activable=1` prevents the whole decoration container from being
        // clickable. Only the icon will respond to activation events.
        return """
            <div><div data-activable="1" class="$className" style="background-color: ${tint.toCss()} !important"/></div>"
            """;
      },
      stylesheet: """
            .$className {
                float: left;
                margin-left: 8px;
                width: 30px;
                height: 30px;
                border-radius: 50%;
                background: url('$imageUrl') no-repeat center;
                background-size: auto 50%;
                opacity: 0.8;
            }
            """);
}
