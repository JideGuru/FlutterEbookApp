// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

abstract class ReaderAnnotationRepository {
  final StreamController<ReaderAnnotation> _bookmarkController;
  final StreamController<List<String>> _deletedIdsController;

  ReaderAnnotationRepository()
      : this._bookmarkController = StreamController.broadcast(),
        this._deletedIdsController = StreamController.broadcast();

  Future<ReaderAnnotation> createBookmark(PaginationInfo paginationInfo);

  @protected
  void notifyBookmark(ReaderAnnotation bookmark) =>
      _bookmarkController.add(bookmark);

  Future<ReaderAnnotation?> savePosition(PaginationInfo paginationInfo);

  Future<ReaderAnnotation?> getPosition();

  Future<ReaderAnnotation> createHighlight(PaginationInfo? paginationInfo,
      Locator locator, HighlightStyle? style, int? tint, String? annotation);

  Future<ReaderAnnotation?> get(String id);

  void delete(Iterable<String> deletedIds) => notifyDeletedIds(deletedIds);

  Future<List<ReaderAnnotation>> allWhere({
    Predicate<ReaderAnnotation> predicate = const AcceptAllPredicate(),
  });

  void notifyDeletedIds(Iterable<String> deletedIds) =>
      _deletedIdsController.add(deletedIds.toList());

  Stream<ReaderAnnotation> get bookmarkStream => _bookmarkController.stream;

  Stream<List<String>> get deletedIdsStream => _deletedIdsController.stream;

  void save(ReaderAnnotation readerAnnotation);
}
