// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_navigator/epub.dart';

class ReaderThemeConfig with EquatableMixin implements JSONable {
  final String name;
  Color? textColor;
  Color? backgroundColor;
  TextAlign? textAlign;
  LineHeight? lineHeight;
  WordSpacing? wordSpacing;
  LetterSpacing? letterSpacing;
  TextMargin? textMargin;
  String? fontFamily;
  String? fontWeight;
  bool advanced;
  bool scroll;

  ReaderThemeConfig(
      this.name,
      this.textColor,
      this.backgroundColor,
      this.textAlign,
      this.lineHeight,
      this.wordSpacing,
      this.letterSpacing,
      this.textMargin,
      this.fontFamily,
      this.fontWeight,
      this.advanced,
      this.scroll);

  ReaderThemeConfig._none()
      : name = "None",
        textColor = null,
        backgroundColor = null,
        textAlign = null,
        lineHeight = null,
        wordSpacing = null,
        letterSpacing = null,
        textMargin = null,
        fontFamily = null,
        fontWeight = null,
        advanced = true,
        scroll = false;

  ReaderThemeConfig copy({
    String? name,
    Color? textColor,
    Color? backgroundColor,
    TextAlign? textAlign,
    LineHeight? lineHeight,
    WordSpacing? wordSpacing,
    LetterSpacing? letterSpacing,
    TextMargin? textMargin,
    String? fontFamily,
    String? fontWeight,
    bool? advanced,
    bool? scroll,
  }) =>
      ReaderThemeConfig(
        name ?? this.name,
        textColor ?? this.textColor,
        backgroundColor ?? this.backgroundColor,
        textAlign ?? this.textAlign,
        lineHeight ?? this.lineHeight,
        wordSpacing ?? this.wordSpacing,
        letterSpacing ?? this.letterSpacing,
        textMargin ?? this.textMargin,
        fontFamily ?? this.fontFamily,
        fontWeight ?? this.fontWeight,
        advanced ?? this.advanced,
        scroll ?? this.scroll,
      );

  static final ReaderThemeConfig defaultTheme = ReaderThemeConfig._none();

  @override
  Map<String, dynamic> toJson() => {
        "name": name,
        if (textColor != null) "textColor": textColor!.value,
        if (backgroundColor != null) "backgroundColor": backgroundColor!.value,
        if (textAlign != null) "textAlign": textAlign!.id,
        if (lineHeight != null) "lineHeight": lineHeight!.id,
        if (wordSpacing != null) "wordSpacing": wordSpacing!.id,
        if (letterSpacing != null) "letterSpacing": letterSpacing!.id,
        if (textMargin != null) "textMargin": textMargin!.id,
        if (fontFamily != null) "fontFamily": fontFamily,
        if (fontWeight != null) "fontWeight": fontWeight,
        "advanced": advanced,
        "scroll": scroll,
      };

  factory ReaderThemeConfig.fromJson(
          Map<String, dynamic>
              data) => // changed Object to dynamic because you do indeed have null values -- advanced and scroll for example
      ReaderThemeConfig(
        data["name"] as String,
        _asColor(data["textColor"]),
        _asColor(data["backgroundColor"]),
        _asTextAlign(data["textAlign"]),
        _asLineHeight(data["lineHeight"]),
        _asWordSpacing(data["wordSpacing"]),
        _asLetterSpacing(data["letterSpacing"]),
        _asTextMargin(data["textMargin"]),
        data["fontFamily"] as String?,
        data["fontWeight"] as String?,
        data["advanced"] as bool? ?? false,
        data["scroll"] as bool? ?? false,
      );

  static Color? _asColor(dynamic color) =>
      (color != null) ? Color(color as int) : null;

  static TextAlign? _asTextAlign(dynamic textAlign) =>
      (textAlign != null) ? TextAlign.from(textAlign as int) : null;

  static LineHeight? _asLineHeight(dynamic lineHeight) =>
      (lineHeight != null) ? LineHeight.from(lineHeight as int) : null;

  static WordSpacing? _asWordSpacing(dynamic wordSpacing) =>
      (wordSpacing != null) ? WordSpacing.from(wordSpacing as int) : null;

  static LetterSpacing? _asLetterSpacing(dynamic letterSpacing) =>
      (letterSpacing != null) ? LetterSpacing.from(letterSpacing as int) : null;

  static TextMargin? _asTextMargin(dynamic textMargin) =>
      (textMargin != null) ? TextMargin.from(textMargin as int) : null;

  @override
  String toString() => 'ReaderThemeConfig{name: $name, '
      'textColor: $textColor, '
      'backgroundColor: $backgroundColor, '
      'textAlign: $textAlign, '
      'lineHeight: $lineHeight, '
      'wordSpacing: $wordSpacing, '
      'letterSpacing: $letterSpacing, '
      'textMargin: $textMargin, '
      'fontFamily: $fontFamily, '
      'fontWeight: $fontWeight, '
      'advanced: $advanced, '
      'scroll: $scroll}';

  @override
  List<Object?> get props => [
        name,
        textColor,
        backgroundColor,
        textAlign,
        lineHeight,
        wordSpacing,
        letterSpacing,
        textMargin,
        fontFamily,
        fontWeight,
        advanced,
        scroll,
      ];
}
