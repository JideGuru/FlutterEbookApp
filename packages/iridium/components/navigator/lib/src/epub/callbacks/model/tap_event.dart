import 'dart:convert';
import 'dart:ui';
import 'package:mno_commons/utils/exceptions.dart';
import 'package:mno_commons/utils/jsonable.dart';

/// Produced by gestures.js
class TapEvent {
  final bool defaultPrevented;
  final Offset point;
  final String targetElement;
  final String? interactiveElement;

  TapEvent(
      {required this.defaultPrevented,
      required this.point,
      required this.targetElement,
      this.interactiveElement});

  static TapEvent? fromJSONObject(Map<String, dynamic>? obj) {
    if (obj == null) {
      return null;
    }

    double x = obj.optDouble("x");
    double y = obj.optDouble("y");

    return TapEvent(
        defaultPrevented: obj.optBoolean("defaultPrevented"),
        point: Offset(x, y),
        targetElement: obj.optString("targetElement"),
        interactiveElement: obj.optNullableString("interactiveElement"));
  }

  static TapEvent? fromJSON(String json) =>
      fromJSONObject(tryOrNull(() => jsonDecode(json)));

  @override
  String toString() => 'TapEvent{defaultPrevented: $defaultPrevented, '
      'point: $point, '
      'targetElement: $targetElement, '
      'interactiveElement: $interactiveElement}';
}
