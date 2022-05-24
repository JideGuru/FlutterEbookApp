// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';

/// Parse clock values as defined in
/// https://www.w3.org/TR/SMIL/smil-timing.html#q22
class ClockValueParser {
  /// Parse clock values from [rawValue].
  static double? parse(String rawValue) {
    String value = rawValue.trim();
    if (value.contains(":")) {
      return _parseClockValue(value);
    } else {
      int metricStart = value.indexOf(RegExp(r'[A-Za-z]'));
      if (metricStart == -1) {
        return _parseTimeCount(value.toDouble(), "");
      } else {
        double? count = value.substring(0, metricStart).toDoubleOrNull();
        if (count == null) {
          return null;
        }
        String metric = value.substring(metricStart, value.length);
        return _parseTimeCount(count, metric);
      }
    }
  }

  static double? _parseClockValue(String value) {
    List<double?> rawParts =
        value.split(":").map((it) => it.toDoubleOrNull()).toList();
    if (rawParts.contains(null)) {
      return null;
    }
    List<double> parts = rawParts.whereType<double>().toList();
    double minSec = parts.last + parts[parts.length - 2] * 60;
    return (parts.length > 2)
        ? minSec + parts[parts.length - 3] * 3600
        : minSec;
  }

  static double? _parseTimeCount(double value, String metric) {
    switch (metric) {
      case "h":
        return value * 3600;
      case "min":
        return value * 60;
      case "s":
      case "":
        return value;
      case "ms":
        return value / 1000;
      default:
        return null;
    }
  }
}
