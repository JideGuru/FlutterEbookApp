// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

import 'package:mno_shared/xml.dart';
import 'package:xml/xml.dart' as xml;

class DataStreamException implements Exception {
  /// Error while reading data.
  factory DataStreamException.readError(String message) =>
      DataStreamException("Read error: $message");

  /// Invalid start or length parameters.
  factory DataStreamException.outOfRange(int start, int length) =>
      DataStreamException("Read out of range (start: $start, length: $length)");

  const DataStreamException(this.message);

  final String message;

  @override
  String toString() => 'DataStreamException{message: $message}';
}

/// An interface providing (optionally random) access to a stream of data.
/// Note: this is not a stream in the Dart sense, but a stream of bytes.
abstract class DataStream {
  /// The total length of the data.
  int get length;

  /// Reads from [start] offset a maximum amount of [length] bytes. If [start]
  /// is null, then starts from the beginning of the data. If [length] is null,
  /// then reads up to the end.
  Future<Stream<List<int>>> read({int? start, int? length});

  /// Read the bytes as a data buffer.
  Future<List<int>> readData({int? start, int? length}) async =>
      (await read(start: start, length: length)).expand((b) => b).toList();

  /// Returns the data as text contents, decoded with the given [encoding]
  /// (defaults is UTF-8).
  Future<String> readText({Encoding encoding = utf8}) async =>
      (await read()).transform(encoding.decoder).join();

  /// Returns the data parsed as a [XmlDocument].
  Future<XmlDocument> readXml() async => XmlDocument.parse(await readText());

  Future<xml.XmlDocument> readXmlDocument() async =>
      xml.XmlDocument.parse(await readText());

  /// Validates the given [start] and [length] range components and return them
  /// (or the default ones if null). Throws an exception if the range is not
  /// valid.
  List<int> validateRange(int? start, int? length) {
    start = max(0, start ?? 0);
    length = min(this.length, length ?? this.length - start);
    // if (start < 0 ||
    //     start >= this.length ||
    //     length < 1 ||
    //     length - 1 > this.length - start) {
    //   throw DataStreamException.outOfRange(start, length);
    // }
    return [start, length];
  }
}
