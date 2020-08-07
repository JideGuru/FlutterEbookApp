import 'package:flutter/material.dart';

class Functions {
  static isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static bool checkConnectionError(e) {
    if (e.toString().contains('SocketException') ||
        e.toString().contains('HandshakeException')) {
      return true;
    } else {
      return false;
    }
  }
}
