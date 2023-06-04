// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/href.dart';

/// A lightweight implementation of URI Template (RFC 6570).
///
/// Only handles simple cases, fitting Readium's use cases.
/// See https://tools.ietf.org/html/rfc6570
class UriTemplate {
  final String uri;

  UriTemplate(this.uri);

  /// List of URI template parameter keys, if the [Link] is templated.
  // Escaping the last } is somehow required, otherwise the regex can't be parsed on a Pixel
  // 3a. However, without it works with the unit tests.
  Iterable<String> get parameters => RegExp("\\{\\??([^}]+)\\}")
      .allMatches(uri)
      .toList()
      .expand((it) => it.group(1)!.split(","))
      .toSet();

  /// Expands the HREF by replacing URI template variables by the given parameters.
  String expand(Map<String, String> parameters) {
    // `+` is considered like an encoded space, and will not be properly encoded in parameters.
    // This is an issue for ISO 8601 date for example.
    // As a workaround, we encode manually this character. We don't do it in the full URI,
    // because it could contain some legitimate +-as-space characters.
    Map<String, String> params = parameters
        .map((key, value) => MapEntry(key, value.replaceFirst("+", "~~+~~")));

    // Escaping the last } is somehow required, otherwise the regex can't be parsed on a Pixel
    // 3a. However, without it works with the unit tests.
    String expanded = uri.replaceAllMapped(RegExp("\\{(\\??)([^}]+)\\}"), (it) {
      if (it.group(1)?.isEmpty == true) {
        return _expandSimpleString(it.group(2)!, params);
      } else {
        return _expandFormStyle(it.group(2)!, params);
      }
    });

    return Href(expanded)
        .percentEncodedString
        .replaceAll("~~+~~", "%2B")
        .replaceAll("~~%20~~", "%2B");
  }

  String _expandSimpleString(String string, Map<String, String> parameters) =>
      string.split(",").map((it) => parameters[it] ?? "").join(",");

  String _expandFormStyle(String string, Map<String, String> parameters) =>
      "?${string.split(",").map((it) => '$it=${parameters[it] ?? ""}').join("&")}";
}
