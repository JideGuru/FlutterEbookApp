// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_shared/src/streams/stream.dart';
import 'package:universal_io/io.dart' hide Link;

/// Random access stream to a file.
class FileStream extends DataStream {
  FileStream._(this._file, this._length);

  static Future<FileStream> fromFile(File file) async {
    RandomAccessFile raFile = await file.open();
    int length = await raFile.length();
    return FileStream._(raFile, length);
  }

  final RandomAccessFile _file;
  final int _length;

  @override
  int get length => _length;

  @override
  Future<Stream<List<int>>> read({int? start, int? length}) async {
    List<int> range = validateRange(start, length);
    start = range[0];
    length = range[1];

    await _file.setPosition(start);
    Future<Uint8List> bytes = _file.read(length);
    return Stream.fromFuture(bytes);
  }
}
