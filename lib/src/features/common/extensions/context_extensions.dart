import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);
  double get screenTextScaleFactor => MediaQuery.textScaleFactorOf(this);
  void showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
