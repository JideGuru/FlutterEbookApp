import 'package:flutter/material.dart';

extension ThemeExtensions on ThemeData {
  Color get accentColor => colorScheme.secondary;
  bool get isDark => brightness == Brightness.dark;
}
