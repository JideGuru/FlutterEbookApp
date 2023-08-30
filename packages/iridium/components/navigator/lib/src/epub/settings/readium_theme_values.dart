// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:dfunc/dfunc.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_shared/publication.dart';

class ReadiumThemeValues {
  final ReaderThemeConfig readerTheme;
  final ViewerSettings viewerSettings;

  ReadiumThemeValues(this.readerTheme, this.viewerSettings);

  // c.f. ReadiumCSS-after.css
  Map<String, String> get cssVarsAndValues => {
        ReadiumCSSName.pageMargins.name: textMargin,
        // "--RS__verticalMargin": verticalMargin,
        "--RS__backgroundColor": backgroundColor,
        "--RS__textColor": textColor,
        "--RS__scroll-snap-stop": scrollSnapShouldStop,
        ReadiumCSSName.textAlignment.name: textAlign,
        ReadiumCSSName.lineHeight.name: lineHeight,
        ReadiumCSSName.wordSpacing.name: wordSpacing,
        ReadiumCSSName.letterSpacing.name: letterSpacing,
        ReadiumCSSName.fontSize.name: fontSize,
        ReadiumCSSName.publisherDefault.name: readerTheme.advanced
            ? "readium-advanced-on"
            : "readium-advanced-off",
        ReadiumCSSName.scroll.name:
            readerTheme.scroll ? "readium-scroll-on" : "readium-scroll-off",
        ReadiumCSSName.fontOverride.name:
            (fontFamily != "inherit") ? "readium-font-on" : "readium-font-off",
        ReadiumCSSName.fontFamily.name: fontFamily,
      };

  String get verticalMargin => "${verticalMarginInt}px";

  int get verticalMarginInt =>
      (!viewerSettings.scrollViewDoc) ? TextMargin.margin_1_0.value.toInt() : 0;

  String get textMargin =>
      readerTheme.textMargin?.let((it) => "${it.value}") ??
      "${TextMargin.margin_1_0.value}";

  String get backgroundColor => _colorAsString(readerTheme.backgroundColor);

  String get textColor => _colorAsString(readerTheme.textColor);

  String _colorAsString(Color? color) =>
      (color != null) ? _formatColor(color.value) : "inherit";

  String _fontFamilyAsString() => formatFontFamily(readerTheme.fontFamily);

  String get fontFamily => _fontFamilyAsString();

  String get textAlign => readerTheme.textAlign?.let((it) => it.name) ?? "";

  String get lineHeight =>
      readerTheme.lineHeight?.let((it) => "${it.value}") ?? "";

  String get wordSpacing =>
      readerTheme.wordSpacing?.let((it) => "${it.value}rem") ?? "";

  String get letterSpacing =>
      readerTheme.letterSpacing?.let((it) => "${it.value}em") ?? "";

  String get scrollSnapShouldStop =>
      viewerSettings.scrollSnapShouldStop ? "always" : "normal";

  String get fontSize => '${viewerSettings.fontSize}%';

  static String _formatColor(int color) =>
      "#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}";

  static String formatFontFamily(String? fontFamily) => fontFamily ?? "inherit";

  static String formatFontWeight(String? fontWeight) => fontWeight ?? "inherit";
}
