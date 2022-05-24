// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:mno_shared/src/zip/lazy_archive_file.dart';

/// A collection of files
class LazyArchive extends IterableBase<LazyArchiveFile> {
  /// The list of files in the archive.
  List<LazyArchiveFile> files = [];

  /// A global comment for the archive.
  String? comment;

  /// Add a file to the archive.
  void addFile(LazyArchiveFile file) {
    files.add(file);
  }

  /// The number of files in the archive.
  @override
  int get length => files.length;

  /// Get a file from the archive.
  LazyArchiveFile operator [](int index) => files[index];

  /// Find a file with the given [name] in the archive. If the file isn't found,
  /// null will be returned.
  LazyArchiveFile? findFile(String name) {
    for (LazyArchiveFile f in files) {
      if (f.name == name) {
        return f;
      }
    }
    return null;
  }

  /// The number of files in the archive.
  int numberOfFiles() => files.length;

  /// The name of the file at the given [index].
  String fileName(int index) => files[index].name;

  /// The decompressed size of the file at the given [index].
  int fileSize(int index) => files[index].size;

  @override
  LazyArchiveFile get first => files.first;

  @override
  LazyArchiveFile get last => files.last;

  @override
  bool get isEmpty => files.isEmpty;

  // Returns true if there is at least one element in this collection.
  @override
  bool get isNotEmpty => files.isNotEmpty;

  @override
  Iterator<LazyArchiveFile> get iterator => files.iterator;
}
