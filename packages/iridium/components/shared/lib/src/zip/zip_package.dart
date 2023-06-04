// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/src/zip/file_buffer.dart';
import 'package:mno_shared/src/zip/lazy_archive.dart';
import 'package:mno_shared/src/zip/lazy_archive_file.dart';
import 'package:mno_shared/src/zip/lazy_zip_decoder.dart';
import 'package:mno_shared/src/zip/zip_header.dart';
import 'package:universal_io/io.dart' hide Link;

class ZipPackage implements JSONable {
  ZipPackage(this.file);

  final File file;

  Map<String, ZipLocalFile> entries = {};
  List<ZipCentralDirectory> centralDirectories = [];
  late ZipEndCentralDirectory cdEnd;

  late int stopOffset;

  @override
  Map<String, dynamic> toJson() => {
        'file': file.path,
        'entries': entries,
        'cdEnd': cdEnd,
        'centralDirectories': centralDirectories,
        'stopOffset': stopOffset,
      };

  ZipLocalFile entry(String path) {
    ZipLocalFile? entry = entries[path];
    if (entry == null) {
      throw Exception("No file entry at path $path.");
    }
    return entry;
  }

  static Future<ZipPackage?> from(File file) async {
    if (!(await file.exists())) return null;

    final zp = ZipPackage(file);
    final package = await FileBuffer.from(file);
    try {
      final entries = <ZipLocalFile>[];
      final cds = <ZipCentralDirectory>[];

      while (!package.isEnd) {
        final pk = await package.readUint16();
        if (pk != 0x4b50) {
          // print(jsonEncode(zp));
          throw UnsupportedError('Unsupported format');
        }

        final sign = await package.readUint16();
        final ZipHeader? header = await ZipHeader.readNext(package, sign);

        /*
        if (sign == 0x0806) {
          // 0608: Archive extra data record
          print('[Archive extra data record]');
          break;
        } else if (sign == 0x0505) {
          // 0505: Digital signature
          print('[Digital signature]');
          break;
        } else if (sign == 0x0606) {
          // 0x0606: Zip64 end of central directory record
          print('[Zip64 end of central directory record]');
          break;
        } else if (sign == 0x0706) {
          // 0x0607: Zip64 end of central directory locator
          print('[Zip64 end of central directory locator]');
          break;
        } else if (sign == 0x0605) {
          // 0x0506: End of central directory record
          print('[End of central directory record]');
          break;
        }
        */
        if (header == null) {
          throw UnsupportedError(
              'Unsupported Header: ${sign.toRadixString(16).padLeft(4, '0')}');
        }

        if (header.isCentralDirectoryEnd) {
          zp.cdEnd = header as ZipEndCentralDirectory;
          zp.stopOffset = package.position;
          break;
        }

        if (header.isLocalFile) {
          final ZipLocalFile f = header as ZipLocalFile;
          entries.add(f);
          package.addToPosition(f.compressedSize);
        } else if (header.isCentralDirectory) {
          final ZipCentralDirectory cd = header as ZipCentralDirectory;
          cds.add(cd);
        }
      }

      zp.entries = Map.fromEntries(entries.map((f) => MapEntry(f.filename, f)));
      zp.centralDirectories = cds;
      return zp;
    } finally {
      await package.close();
    }
  }

  static Future<ZipPackage?> fromArchive(File file) async {
    if (!(await file.exists())) return null;
    final zp = ZipPackage(file);
    final entries = <ZipLocalFile>[];
    final cds = <ZipCentralDirectory>[];

    try {
      LazyArchive archive = await LazyZipDecoder().decodeBuffer(file);
      for (LazyArchiveFile archiveFile in archive) {
        if (archiveFile.isFile) {
          final ZipLocalFile f = ZipLocalFile(0x0403);
          f.offsetStart = archiveFile.header.file.offsetStart;
          f.offsetEnd = archiveFile.header.file.offsetEnd;
          f.versionToExtract = archiveFile.header.versionNeededToExtract;
          f.generalFlag = archiveFile.header.generalPurposeBitFlag;
          f.compressionMethod = archiveFile.header.compressionMethod;
          f.lastModTime = archiveFile.header.lastModifiedFileTime;
          f.lastModDate = archiveFile.header.lastModifiedFileDate;
          f.crc32 = archiveFile.header.crc32;
          f.compressedSize = archiveFile.header.compressedSize;
          f.uncompressedSize = archiveFile.header.uncompressedSize;
          f.filenameSize = archiveFile.header.filename.length;
          f.extraFieldSize = archiveFile.header.extraField.length;
          f.filename = archiveFile.header.filename;
          f.extraField = archiveFile.header.extraField;
          entries.add(f);
        } else {
          final ZipCentralDirectory cd = ZipCentralDirectory(0x0201);
          cd.offsetStart = archiveFile.header.localHeaderOffset;
          cd.offsetEnd = cd.offsetStart + archiveFile.header.uncompressedSize;
          cd.versionMade = archiveFile.header.versionMadeBy;
          cd.commentLength = archiveFile.header.fileComment.length;
          cd.comment = archiveFile.header.fileComment;
          cd.diskNumberStart = archiveFile.header.diskNumberStart;
          cd.internalAttributes = archiveFile.header.internalFileAttributes;
          cd.externalAttributes = archiveFile.header.externalFileAttributes;
          cd.relativeOffset = archiveFile.header.localHeaderOffset;
          cds.add(cd);
        }
      }
    } on Exception {
      // Fimber.d("Error loading epub", ex: e, stacktrace: stacktrace);
      return null;
    }
    zp.entries = Map.fromEntries(entries.map((f) => MapEntry(f.filename, f)));
    zp.centralDirectories = cds;
    return zp;
  }

  static final ZLibDecoder zlibDecoder = ZLibDecoder(raw: true);

  static Future<Stream<List<int>>> extract(
    File file, {
    required final int entryStart,
    required final int entryEnd,
    required final int compressionMethod,
    IntRange? range,
  }) async {
    if (range == null) {
      Stream<List<int>> stream = file.openRead(entryStart, entryEnd);
      if (compressionMethod == 0) return stream;
      if (compressionMethod == 8) return stream.transform(zlibDecoder);
    }
    if (range != null) {
      if (compressionMethod == 0) {
        int start = min(entryStart + range.start, entryEnd);
        int end = min(entryStart + range.length, entryEnd);
        return file.openRead(start, end);
      }
      if (compressionMethod == 8) {
        return file
            .openRead(entryStart, entryEnd)
            .transform(zlibDecoder)
            .transform(_RangeStreamTransformer(range));
      }
    }
    throw UnsupportedError('Unsupported compress method: $compressionMethod');
  }

  static Stream<List<int>> raw(File file, {int? start, int? end}) =>
      file.openRead(start, end);

  Future<Stream<List<int>>?> extractStream(String filename,
      {IntRange? range}) async {
    final zip = entries[filename];
    return zip == null
        ? null
        : extract(file,
            entryStart: zip.offsetEnd,
            entryEnd: zip.offsetEnd + zip.compressedSize,
            compressionMethod: zip.compressionMethod,
            range: range);
  }

  Future<String?> extractAsUtf8(String filename) async {
    final stream = await extractStream(filename);
    if (stream == null) return null;

    return stream.transform(utf8.decoder).join();
  }
}

class _RangeStreamTransformer
    extends StreamTransformerBase<List<int>, List<int>> {
  final IntRange range;

  _RangeStreamTransformer(this.range);

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) {
    int offsetUncompressed = 0;
    return stream.map((uncompressedData) {
      List<int> data = [];
      if (offsetUncompressed + uncompressedData.length >= range.start &&
          offsetUncompressed <= range.endInclusive) {
        data = uncompressedData.sublist(
            max(0, range.start - offsetUncompressed),
            min(uncompressedData.length,
                range.endInclusive - offsetUncompressed));
      }
      offsetUncompressed += uncompressedData.length;
      return data;
    });
  }
}
