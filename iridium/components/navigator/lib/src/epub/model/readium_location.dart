// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:fimber/fimber.dart';

class ReadiumLocation {
  static const String defaultFormat = "epub";
  static const int currentVersion = 2;
  final int version;
  final String idref;
  final String contentCFI;
  final String elementId;
  final String format;
  final double percent;

  ReadiumLocation._(this.version, this.idref, this.contentCFI, this.elementId,
      this.format, this.percent);

  static ReadiumLocation createLocation(
    String? location, {
    bool debug = false,
  }) {
    print('this is the location: $location');
    String idref = "";
    String contentCFI = "";
    String elementId = "";
    String format = "";
    double percent = 0;
    int version = 0;
    if (location != null) {
      try {
        Map<String, dynamic> json = const JsonCodec().decode(location);
        format = json["format"] ?? defaultFormat;
        if (format == defaultFormat) {
          idref = json["idref"];
          contentCFI =
              json["contentCFI"] ?? (json["contentCFI"] ?? json["cfi"]);
          elementId = json["elementId"] ?? "";
          percent = json["percent"] as double? ?? 0;
          version = json["version"] as int? ?? currentVersion;
        }
      } on Exception catch (ex, stacktrace) {
        if (debug) {
          Fimber.e("Location: " + location, ex: ex, stacktrace: stacktrace);
        }
      }
    }

    return ReadiumLocation._(
        version, idref, contentCFI, elementId, format, percent);
  }

  int getPercentPartAsInt() {
    double decimalPart = percent % 1;
    return (decimalPart * 100).round();
  }

  bool isValid() => format == defaultFormat && idref.isNotEmpty;

  @override
  String toString() =>
      'ReadiumLocation{version: $version, idref: $idref, contentCFI: $contentCFI, '
      'elementId: $elementId, format: $format, percent: $percent}';
}
