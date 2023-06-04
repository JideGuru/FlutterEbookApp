import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mno_shared/publication.dart';

class Selection {
  final Locator locator;
  final Rectangle<double>? rect;
  Offset offset;

  Selection({required this.locator, this.rect}) : offset = Offset.zero;

  double get inverseDevicePixelRatio =>
      1 / WidgetsBinding.instance.window.devicePixelRatio;

  Rectangle<double>? get rectOnScreen {
    if (rect != null) {
      Point<double> offset = Point(this.offset.dx, this.offset.dy);
      Point<double> topLeft = rect!.topLeft * inverseDevicePixelRatio + offset;
      Point<double> bottomRight =
          rect!.bottomRight * inverseDevicePixelRatio + offset;
      return Rectangle.fromPoints(topLeft, bottomRight);
    }
    return null;
  }

  static Selection fromJson(Map<String, dynamic> json, Locator locator) {
    Map<String, dynamic> jsonRect = json["rect"];
    return Selection(
      locator: locator.copy(text: LocatorText.fromJson(json["text"])),
      rect: jsonRect.rect,
    );
  }

  @override
  String toString() => 'Selection{locator: $locator, rect: $rect}';
}

extension JsonToRectangle on Map<String, dynamic> {
  Rectangle<double> get rect => Rectangle(
      (this["left"] as num).toDouble(),
      (this["top"] as num).toDouble(),
      (this["width"] as num).toDouble(),
      (this["height"] as num).toDouble());
}
