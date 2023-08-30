// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/io.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/mediatype/mediatype.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' hide Link;

class FileFetcher extends Fetcher {
  final Map<String, FileSystemEntity> paths;

  final List<Resource> _openedResources = [];

  FileFetcher(this.paths);

  factory FileFetcher.single(
          {required String href, required FileSystemEntity file}) =>
      FileFetcher({href: file});

  @override
  Future<List<Link>> links() async {
    List<Link> files = [];
    for (MapEntry<String, FileSystemEntity> entry in paths.entries) {
      String href = entry.key;
      if (entry.value is Directory) {
        Directory directory = entry.value as Directory;
        await directory
            .list(recursive: true)
            .toList()
            .then((List<FileSystemEntity> files) => files
                .whereType<File>()
                .map((f) async => await _toLink(href, f, entry.value)))
            .then((futures) => Future.wait(futures))
            .then((list) => files.addAll(list));
      } else if (entry.value is File) {
        File file = entry.value as File;
        files.add(await _toLink(href, file, file));
      }
    }
    return files;
  }

  Future<Link> _toLink(
      String href, FileSystemEntity file, FileSystemEntity root) async {
    String path = p
        .join(
            href,
            file.canonicalPath
                .removePrefix(root.canonicalPath)
                .replaceAll("\\", "/")
                .removePrefix("/"))
        .replaceAll("\\", "/");
    return Link(
      href: path,
      type: (await MediaType.ofFileWithSingleHint(file,
              fileExtension: p.extension(file.path)))
          ?.toString(),
    );
  }

  @override
  Resource get(Link link) {
    String linkHref = link.href.addPrefix("/");
    for (MapEntry<String, FileSystemEntity> entry in paths.entries) {
      String itemHref = entry.key.addPrefix("/");
      FileSystemEntity itemFile = entry.value;
      if (linkHref.startsWith(itemHref)) {
        String path = p.join(
            itemFile.path, linkHref.removePrefix(itemHref).removePrefix("/"));
        File resourceFile = File(path);
        // Make sure that the requested resource is [path] or one of its descendant.
        if (resourceFile.canonicalPath.startsWith(itemFile.canonicalPath)) {
          Resource resource = FileResource(link, resourceFile);
          _openedResources.add(resource);
          return resource;
        }
      }
    }
    return FailureResource(link, ResourceException.notFound);
  }

  @override
  Future<void> close() async {
    await Future.wait(_openedResources.mapNotNull((res) => res.close()));
    _openedResources.clear();
  }
}

extension FileExtension on FileSystemEntity {
  String get canonicalPath => absolute.path;
}

class FileResource extends Resource {
  final Link _link;
  final File _file;
  ResourceTry<RandomAccessFile>? _randomAccessFile;

  FileResource(this._link, this._file);

  @override
  File get file => _file;

  @override
  Future<Link> link() async => _link;

  Future<ResourceTry<RandomAccessFile>> get randomAccessFile async =>
      _randomAccessFile ??= await catching(() => file.open());

  @override
  Future<void> close() async {
    if (_randomAccessFile != null) {
      _randomAccessFile!.onSuccess((it) {
        try {
          it.close();
        } on Exception catch (e) {
          Fimber.e("ERROR closing file", ex: e);
        }
      });
    }
  }

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) =>
      catching(() => _readSync(range));

  Future<ByteData> _readSync(IntRange? range) async {
    if (!await file.exists()) {
      throw FileNotFoundException(file.path);
    }
    if (range == null) {
      return file.readAsBytes().then((value) => ByteData.sublistView(value));
    }
    IntRange range2 =
        IntRange(max(0, range.first), min(range.last, await _file.length()));

    if (range2.isEmpty) {
      return ByteData(0);
    }

    RandomAccessFile raf = (await randomAccessFile).getOrThrow();
    await raf.setPosition(range2.first);
    return raf.read(range2.length).then((value) => ByteData.sublistView(value));
  }

  @override
  Future<ResourceTry<int>> length() async {
    int? length = await metadataLength;
    if (length != null) {
      return ResourceTry.success(length);
    }
    return read()
        .then((data) => data.map((byteData) => byteData.lengthInBytes));
  }

  Future<int?> get metadataLength async {
    try {
      return file
          .exists()
          .then((exists) => (exists) ? file.length() : Future.value());
    } on Exception {
      return Future.value();
    }
  }

  @override
  String toString() => "FileResource(${file.path})";

  static Future<ResourceTry<T>> catching<T>(Future<T> Function() closure) =>
      closure().then((value) => ResourceTry.success(value)).catchError((e, st) {
        if (e is FileNotFoundException) {
          return ResourceTry<T>.failure(ResourceException.notFound);
        }
        if (e is Exception) {
          return ResourceTry<T>.failure(ResourceException.wrap(e));
        }
        if (e is OutOfMemoryError) {
          // We don't want to catch any Error, only OOM.
          return ResourceTry<T>.failure(ResourceException.wrap(e));
        }

        return ResourceTry<T>.failure(ResourceException.wrap(e));
      });
}
