// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';

const String fontSizeRef = "fontSize";
const String fontFamilyRef = "fontFamily";
const String fontOverrideRef = "fontOverride";
const String appearanceRef = "appearance";
const String scrollRef = "scroll";
const String publisherDefaultRef = "advancedSettings";
const String textAlignmentRef = "textAlign";
const String columnCountRef = "colCount";
const String wordSpacingRef = "wordSpacing";
const String letterSpacingRef = "letterSpacing";
const String pageMarginsRef = "pageMargins";
const String lineHeightRef = "lineHeight";

const String fontSizeName = "--USER__$fontSizeRef";
const String fontFamilyName = "--USER__$fontFamilyRef";
const String fontOverrideName = "--USER__$fontOverrideRef";
const String appearanceName = "--USER__$appearanceRef";
const String scrollName = "--USER__$scrollRef";
const String publisherDefaultName = "--USER__$publisherDefaultRef";
const String textAlignmentName = "--USER__$textAlignmentRef";
const String columnCountName = "--USER__$columnCountRef";
const String wordSpacingName = "--USER__$wordSpacingRef";
const String letterSpacingName = "--USER__$letterSpacingRef";
const String pageMarginsName = "--USER__$pageMarginsRef";
const String lineHeightName = "--USER__$lineHeightRef";

// List of strings that can identify the name of a CSS custom property
// Also used for storing UserSettings in UserDefaults
class ReadiumCSSName {
  static const ReadiumCSSName fontSize =
      ReadiumCSSName._(fontSizeRef, fontSizeName);
  static const ReadiumCSSName fontFamily =
      ReadiumCSSName._(fontFamilyRef, fontFamilyName);
  static const ReadiumCSSName fontOverride =
      ReadiumCSSName._(fontOverrideRef, fontOverrideName);
  static const ReadiumCSSName appearance =
      ReadiumCSSName._(appearanceRef, appearanceName);
  static const ReadiumCSSName scroll = ReadiumCSSName._(scrollRef, scrollName);
  static const ReadiumCSSName publisherDefault =
      ReadiumCSSName._(publisherDefaultRef, "--USER__advancedSettings");
  static const ReadiumCSSName textAlignment =
      ReadiumCSSName._(textAlignmentRef, textAlignmentName);
  static const ReadiumCSSName columnCount =
      ReadiumCSSName._(columnCountRef, columnCountName);
  static const ReadiumCSSName wordSpacing =
      ReadiumCSSName._(wordSpacingRef, wordSpacingName);
  static const ReadiumCSSName letterSpacing =
      ReadiumCSSName._(letterSpacingRef, letterSpacingName);
  static const ReadiumCSSName pageMargins =
      ReadiumCSSName._(pageMarginsRef, pageMarginsName);
  static const ReadiumCSSName lineHeight =
      ReadiumCSSName._(lineHeightRef, lineHeightName);
  static const ReadiumCSSName paraIndent =
      ReadiumCSSName._("paraIndent", "--USER__paraIndent");
  static const ReadiumCSSName hyphens =
      ReadiumCSSName._("hyphens", "--USER__bodyHyphens");
  static const ReadiumCSSName ligatures =
      ReadiumCSSName._("ligatures", "--USER__ligatures");
  static const List<ReadiumCSSName> _values = [
    fontSize,
    fontFamily,
    fontOverride,
    appearance,
    scroll,
    publisherDefault,
    textAlignment,
    columnCount,
    wordSpacing,
    letterSpacing,
    pageMargins,
    lineHeight,
    paraIndent,
    hyphens,
    ligatures,
  ];

  final String ref;
  final String name;

  const ReadiumCSSName._(this.ref, this.name);

  static ReadiumCSSName? from(String name) =>
      _values.firstOrNullWhere((element) => element.name == name);
}
