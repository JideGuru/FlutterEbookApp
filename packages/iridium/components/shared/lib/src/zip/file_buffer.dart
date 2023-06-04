// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:archive/archive.dart' as archive;
import 'package:universal_io/io.dart' hide Link;

/// A simple buffer to read files efficiently.
class FileBuffer {
  FileBuffer._(this._file, this.length);

  /// Creates [FileBuffer] from [file]
  static Future<FileBuffer> from(File file) async {
    final args = await Future.wait([
      file.open(),
      file.length(),
    ]);
    return FileBuffer._(args[0] as RandomAccessFile, args[1] as int);
  }

  static const _blockShift = 14; // 16KB
  static const _blockSize = 1 << _blockShift;
  static const _blockMask = _blockSize - 1;

  final List<int> _buffer = List.filled(_blockSize, 0);
  int _blockIndex = -1;

  final RandomAccessFile _file;

  /// Returns file size
  final int length;
  int _position = 0;
  int _fileBlockIndex = 0;

  /// Indicator whether current position reached the end
  bool get isEnd => position >= length;

  void _setPosition(int pos) {
    if (pos < 0) {
      _position = 0;
    } else if (pos > length) {
      _position = length;
    } else {
      _position = pos;
    }
  }

  /// Closes [file] object
  Future<void> close() => _file.close();

  /// Current [position]
  int get position => _position;

  set position(int value) {
    _setPosition(value < 0 ? length + value : value);
  }

  /// Move [position] by giving [delta] rather than set to an absolute value.
  void addToPosition(int delta) {
    _setPosition(position + delta);
  }

  int _normalizeCount(int count) {
    if (count <= 0) return 0;
    final remained = length - position;
    return count > remained ? remained : count;
  }

  Future<List<int>> _read(final int count) async {
    final List<int> result = List.filled(count, 0);
    if (count == 0) return result;

    int start = 0;
    int blkIndexStart = _position >> _blockShift;
    int blkOffsetStart = _position & _blockMask;
    final int end = _position + count;
    if (blkIndexStart == _blockIndex) {
      // read from current buffer
      final int remained = _blockSize - blkOffsetStart;
      start = count > remained ? remained : count;
      result.setRange(0, start, _buffer, blkOffsetStart);

      _position += start;
      if (_position >= end) return result;

      blkIndexStart += 1;
      blkOffsetStart = 0;
    }

    final int blkIndexEnd = end >> _blockShift;
    final int lastBlockPos = blkIndexEnd << _blockShift;
    // directly read blocks
    if (blkIndexStart != blkIndexEnd) {
      if (_blockIndex != _fileBlockIndex) {
        await _file.setPosition(_position);
      }

      final int stopOffset = lastBlockPos - _position;
      await _file.readInto(result, start, stopOffset);
      start = stopOffset;
      blkOffsetStart = 0;
    } else {
      if (_fileBlockIndex != blkIndexEnd) {
        await _file.setPosition(lastBlockPos);
      }
    }

    // read to buffer
    await _file.readInto(_buffer, 0, _blockSize);
    _blockIndex = blkIndexEnd;
    _fileBlockIndex = blkIndexEnd + 1;

    result.setRange(start, count, _buffer, blkOffsetStart);
    _position = end;
    return result;
  }

  Future<archive.InputStream> subset(int position, [int length = 1]) async {
    _position = position;
    List<int> bytes = await read(length);
    return archive.InputStream(bytes, start: 0, length: length);
  }

  /// Reads [count] bytes from current [position].
  Future<List<int>> read([final int count = 1]) =>
      _read(_normalizeCount(count));

  /// Reads [count] bytes from current [position].
  Future<String> readString([final int count = 1]) async =>
      Utf8Decoder().convert(await read((count)));

  /// Reads 1 byte as unsigned int8 from current [position].
  Future<int> readByte() async {
    final buff = await read();
    return buff[0];
  }

  /// Reads 2 bytes as unsigned int16 from current [position].
  Future<int> readUint16() async {
    final buff = await read(2);
    final b0 = buff[0] & 0xff;
    final b1 = buff[1] & 0xff;
    return (b1 << 8) | b0;
  }

  /// Reads 4 bytes as unsigned int32 from current [position].
  Future<int> readUint32() async {
    final buff = await read(4);
    final b0 = buff[0] & 0xff;
    final b1 = buff[1] & 0xff;
    final b2 = buff[2] & 0xff;
    final b3 = buff[3] & 0xff;
    return (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
  }

  /// Reads 4 bytes as unsigned int32 from current [position].
  Future<int> readUint64() async {
    final buff = await read(8);
    final b0 = buff[0] & 0xff;
    final b1 = buff[1] & 0xff;
    final b2 = buff[2] & 0xff;
    final b3 = buff[3] & 0xff;
    final b4 = buff[4] & 0xff;
    final b5 = buff[5] & 0xff;
    final b6 = buff[6] & 0xff;
    final b7 = buff[7] & 0xff;
    return (b7 << 56) |
        (b6 << 48) |
        (b5 << 40) |
        (b4 << 32) |
        (b3 << 24) |
        (b2 << 16) |
        (b1 << 8) |
        b0;
  }

  /// Reads [count] bytes as UTF-8 string from current [position].
  Future<String> readUtf8(int count) async => utf8.decode(await read(count));
}
