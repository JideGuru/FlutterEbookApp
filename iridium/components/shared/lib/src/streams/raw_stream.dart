// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:mno_shared/src/streams/stream.dart';

/// Simple in-memory data stream.
class RawDataStream extends DataStream {
  RawDataStream(this._data);

  final List<int> _data;

  factory RawDataStream.fromString(String contents,
          {Encoding encoding = utf8}) =>
      RawDataStream(encoding.encode(contents));

  @override
  int get length => _data.length;

  @override
  Future<Stream<List<int>>> read({int? start, int? length}) async {
    List<int> range = validateRange(start, length);
    start = range[0];
    length = range[1];

    if (_data.isEmpty) {
      return Stream.empty();
    }
    Stream<List<int>> stream = Stream.fromFuture(
        Future.value(_data.sublist(start, start + length - 1)));
    return stream;
  }
}
