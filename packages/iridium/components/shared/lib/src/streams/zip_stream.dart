// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:mno_shared/streams.dart';
import 'package:mno_shared/zip.dart';

/// Random access stream to a file compressed in a ZIP archive.
class ZipStream extends DataStream {
  ZipStream(this._package, this._entry);

  final ZipPackage _package;
  final ZipLocalFile _entry;

  @override
  int get length => _entry.uncompressedSize;

  @override
  Future<Stream<List<int>>> read({int? start, int? length}) async {
    IntRange? range;
    if (start != null || length != null) {
      List<int> validatedRange = validateRange(start, length);
      start = validatedRange[0];
      length = validatedRange[1];
      range = IntRange(start, start + length - 1);
    }

    Stream<List<int>>? stream =
        await _package.extractStream(_entry.filename, range: range);
    if (stream == null) {
      throw DataStreamException.readError(
          "Can't read file at ${_entry.filename}");
    }
    return stream;
  }
}
