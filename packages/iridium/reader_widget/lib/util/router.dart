import 'package:flutter/material.dart';

class MyRouter {
  static Future pushPage(BuildContext context, Widget page) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => page,
        ),
      );

  static Future pushPageDialog(BuildContext context, Widget page) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => page,
          fullscreenDialog: true,
        ),
      );

  static Future pushPageReplacement(BuildContext context, Widget page) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => page,
        ),
      );
}
