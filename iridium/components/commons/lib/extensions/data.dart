// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart' as archive;
import 'package:crypto/crypto.dart' as crypto;
import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';

extension IntListExtension on List<int> {
  ByteData toByteData() => ByteData.sublistView(Uint8List.fromList(this));
}

extension ByteDataExtension on ByteData {
  /// Returns an array containing elements at indices in the specified [indices] range.
  ByteData sliceArray(IntRange indices) {
    if (indices.isEmpty) {
      return ByteData(0);
    }
    return buffer.asByteData(indices.start, indices.length);
  }

  /// Inflates a ZIP-compressed [ByteData].
  ByteData inflate() =>
      archive.Inflate.buffer(archive.InputStream(buffer.asUint8List()))
          .getBytes()
          .toByteData();

  /// Computes the MD5 hash of the byte array.
  Future<String?> md5() async {
    try {
      return await crypto.md5
          .bind(asStream())
          .first
          .then((digest) => digest.toString());
    } on Exception catch (e) {
      Fimber.e("ERROR when computing md5", ex: e);
      return null;
    }
  }

  String asUtf8() => utf8.decode(buffer.asUint8List());

  Stream<List<int>> asStream() => Stream.value(buffer.asUint8List());
}
