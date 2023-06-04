// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dartx/dartx.dart';
import 'package:mno_commons/extensions/data.dart';

extension StringExtension on String {
  /// If this string starts with the given [prefix], returns this string.
  /// Otherwise, returns a copy of this string after adding the [prefix].
  String addPrefix(String prefix) => startsWith(prefix) ? this : "$prefix$this";

  String? ifBlank(String? Function() defaultValue) =>
      isBlank ? defaultValue() : this;

  String insert(int index, String value) =>
      substring(0, index) + value + substring(index);

  String substringBefore(String? separator) {
    if (isEmpty) {
      return this;
    }
    if (separator == null) {
      return this;
    }
    int pos = indexOf(separator);
    if (pos < 0) {
      return this;
    }
    return substring(0, pos);
  }

  String substringAfter(String delimiter) {
    int index = indexOf(delimiter);
    return (index == -1) ? this : substring(index + delimiter.length, length);
  }

  ByteData toByteData() => this.toUtf8().toByteData();

  DateTime? iso8601ToDate() {
    try {
      // We assume that a date without a time zone component is in UTC. To handle this properly,
      // we need to set the default time zone of Joda to UTC, since by default it uses the local
      // time zone. This ensures that apps see exactly the same dates (e.g. published) no matter
      // where they are located.
      // For the same reason, the output Date will be in UTC. Apps should convert it to the local
      // time zone for display purposes, or keep it as UTC for storage.
      DateTime dateTime = DateTime.parse(this);
      if (!dateTime.isUtc) {
        return DateTime.utc(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
            dateTime.second,
            dateTime.millisecond,
            dateTime.microsecond);
      }
      return dateTime;
    } on Exception {
      return null;
    }
  }

  Uri? toUrlOrNull({Uri? context}) {
    try {
      return (context != null) ? context.resolve(this) : Uri.parse(this);
    } on Exception {
      return null;
    }
  }

  Map<String, dynamic>? toJsonOrNull() {
    try {
      return json.decode(this);
    } on Exception {
      return null;
    }
  }

  List? toJsonArrayOrNull() {
    try {
      return json.decode(this);
    } on Exception {
      return null;
    }
  }

  bool? toBooleanOrNull() {
    String normalized = this.toLowerCase();
    if (normalized == "true") {
      return true;
    }
    if (normalized == "false") {
      return false;
    }
    return null;
  }

  Map<String, String> queryParameters() =>
      Uri.tryParse(this)?.queryParameters ?? {};

  /// Returns a string containing the first characters that satisfy the given [predicate].
  ///
  /// @sample samples.text.Strings.take
  String takeWhile(bool Function(String) predicate) =>
      this.characters.takeWhile(predicate).string;
}

extension StringHashExtension on String {
  String hashWith(crypto.Hash algorithm) =>
      algorithm.convert(toUtf8()).toString();

  /// Calculates the SHA1 digest and returns the value as a [String] of
  /// hexadecimal digits.
  String get sha1 => crypto.sha1.convert(toUtf8()).toString();
}
