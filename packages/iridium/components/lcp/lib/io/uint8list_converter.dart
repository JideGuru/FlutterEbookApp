// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

class ToUint8List extends Converter<List<int>, Uint8List> {
  const ToUint8List();

  @override
  Uint8List convert(List<int> input) => Uint8List.fromList(input);

  @override
  Sink<List<int>> startChunkedConversion(Sink<Uint8List> sink) =>
      _Uint8ListConversionSink(sink);
}

class _Uint8ListConversionSink implements Sink<List<int>> {
  const _Uint8ListConversionSink(this._target);

  final Sink<Uint8List> _target;

  @override
  void add(List<int> data) {
    _target.add(Uint8List.fromList(data));
  }

  @override
  void close() {
    _target.close();
  }
}
