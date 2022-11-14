import 'package:flutter/material.dart';

class ColorTheme {
  static const ColorTheme defaultColorTheme = ColorTheme("Default", null, null);
  static const ColorTheme sepiaColorTheme =
      ColorTheme("Sepia", Color(0xfffaf4e8), Color(0xff121212));
  static const ColorTheme nightColorTheme =
      ColorTheme("Night", Colors.black, Color(0xfffefefe));
  static const List<ColorTheme> values = [
    defaultColorTheme,
    sepiaColorTheme,
    nightColorTheme,
  ];
  final String name;
  final Color? backgroundColor;
  final Color? textColor;

  const ColorTheme(this.name, this.backgroundColor, this.textColor);

  @override
  String toString() =>
      'ColorTheme{name: $name, backgroundColor: $backgroundColor, textColor: $textColor}';
}
