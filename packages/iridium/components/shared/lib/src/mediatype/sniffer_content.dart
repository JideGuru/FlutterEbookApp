// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:fimber/fimber.dart';
import 'package:http/http.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:universal_io/io.dart' hide Link;

/// Provides an access to a file's content to sniff its format.
abstract class SnifferContent {
  /// Reads the whole content as raw bytes.
  Future<ByteData> read();

  /// Raw bytes stream of the content.
  ///
  /// A byte stream can be useful when sniffers only need to read a few bytes at the beginning of
  /// the file.
  Future<Stream<List<int>>> stream();
}

class SnifferFileContent extends SnifferContent {
  final FileSystemEntity file;

  SnifferFileContent(this.file);

  @override
  Future<ByteData> read() async {
    if (file is File) {
      try {
        // We only read files smaller than 100KB to avoid an [OutOfMemoryError].
        if (await (file as File).length() > 100000) {
          return ByteData(0);
        } else {
          return (file as File)
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes));
        }
      } on Exception catch (ex) {
        Fimber.e("ERROR reading file: $file", ex: ex);
        return ByteData(0);
      }
    }
    return ByteData(0);
  }

  @override
  Future<Stream<List<int>>> stream() async {
    if (file is File) {
      try {
        return (file as File).openRead();
      } on Exception catch (ex) {
        Fimber.e("ERROR reading file: $file", ex: ex);
        return Stream.empty();
      }
    }
    return Stream.empty();
  }
}

/// Used to sniff a bytes array.
class SnifferBytesContent extends SnifferContent {
  final Future<ByteData> Function() bytes;
  ByteData? _byteData;

  SnifferBytesContent(this.bytes);

  Future<ByteData> _bytes() async => _byteData ??= await bytes();

  @override
  Future<ByteData> read() async => _bytes();

  @override
  Future<Stream<List<int>>> stream() =>
      _bytes().then((data) => data.asStream());
}

/// Used to sniff a content URI.
class SnifferUriContent extends SnifferContent {
  final Uri uri;

  SnifferUriContent(this.uri);

  @override
  Future<ByteData> read() => stream()
      .then((stream) => ByteStream(stream).toBytes())
      .then((bytes) => ByteData.sublistView(bytes));

  @override
  Future<Stream<List<int>>> stream() async {
    final HttpClientRequest request = await HttpClient().getUrl(uri);
    final HttpClientResponse response = await request.close();
    return response;
  }
}
