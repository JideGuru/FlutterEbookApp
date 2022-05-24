// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/strings.dart';

/// Represents an HREF, optionally relative to another one.
///
/// This is used to normalize the string representation.
class Href {
  final String href;
  final String baseHref;

  Href(this.href, {String baseHref = '/'})
      : this.baseHref = (baseHref.isEmpty) ? "/" : baseHref;

  /// Returns the normalized string representation for this HREF.
  String get string {
    if (href.isBlank) {
      return baseHref;
    }

    String resolved;
    try {
      Uri absoluteUri = Uri.parse(baseHref).resolve(href);
      String absoluteString = absoluteUri.toString(); // This is percent-decoded
      bool addSlash = !absoluteUri.hasScheme && !absoluteString.startsWith("/");
      resolved = ((addSlash) ? "/" : "") + absoluteString;
    } on Exception {
      if (href.startsWith("http://") || href.startsWith("https://")) {
        resolved = href;
      } else {
        resolved = baseHref.removeSuffix("/") + href.addPrefix("/");
      }
    }

    return Uri.decodeFull(resolved);
  }

  /// Returns the normalized string representation for this HREF, encoded for URL uses.
  ///
  /// Taken from https://stackoverflow.com/a/49796882/1474476
  String get percentEncodedString {
    String string = this.string;
    if (string.startsWith("/")) {
      string = string.addPrefix("file://");
    }

    try {
      Uri url = Uri.parse(string);
      Uri uri = url.replace(host: AsciiCodec().decode(url.host.toUtf8()));
      return String.fromCharCodes(AsciiCodec().encode(uri.toString()))
          .removePrefix("file://");
    } on Exception catch (e) {
      Fimber.e("ERROR in percentEncodedString", ex: e);
      return this.string;
    }
  }

  /// Returns the query parameters present in this HREF, in the order they appear.
  List<QueryParameter> get queryParameters => Uri.parse(percentEncodedString)
      .queryParameters
      .entries
      .map((it) => QueryParameter(it.key, value: it.value))
      .toList();
}

class QueryParameter {
  final String name;
  final String? value;

  QueryParameter(this.name, {this.value});

  @override
  String toString() => 'QueryParameter{name: $name, value: $value}';
}

extension QueryParameterExtension on List<QueryParameter> {
  String? firstNamedOrNull(String name) =>
      firstOrNullWhere((it) => it.name == name)?.value;

  List<String> allNamed(String name) =>
      where((it) => it.name == name).mapNotNull((it) => it.value).toList();
}
