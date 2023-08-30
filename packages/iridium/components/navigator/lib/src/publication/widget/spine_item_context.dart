// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dfunc/dfunc.dart';
import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class SpineItemContextWidget extends InheritedWidget {
  final SpineItemContext spineItemContext;

  const SpineItemContextWidget(
      {super.key, required super.child, required this.spineItemContext});

  @override
  bool updateShouldNotify(SpineItemContextWidget oldWidget) =>
      spineItemContext != oldWidget.spineItemContext;
}

class SpineItemContext {
  final int spineItemIndex;
  final ReaderContext readerContext;
  final List<ReaderAnnotation> bookmarks;
  final LinkPagination linkPagination;
  final StreamController<PaginationInfo> _paginationInfoStreamController;
  PaginationInfo? currentPaginationInfo;
  JsApi? jsApi;

  SpineItemContext({
    required this.spineItemIndex,
    required this.readerContext,
    required this.linkPagination,
  })  : bookmarks = [],
        _paginationInfoStreamController = StreamController.broadcast();

  Publication get publication => readerContext.publication!;

  ReaderAnnotationRepository get readerAnnotationRepository =>
      readerContext.readerAnnotationRepository;

  Link get spineItem => publication.readingOrder[spineItemIndex];

  Stream<PaginationInfo> get paginationInfoStream =>
      _paginationInfoStreamController.stream;

  static SpineItemContext? of(BuildContext context) {
    final SpineItemContextWidget? readerContextWidget =
        context.dependOnInheritedWidgetOfExactType<SpineItemContextWidget>();
    return readerContextWidget?.spineItemContext;
  }

  void notifyPaginationInfo(PaginationInfo paginationInfo) {
    currentPaginationInfo = paginationInfo;
    // debugPrint('paginfo: ${currentPaginationInfo?.json}');
    if (!_paginationInfoStreamController.isClosed) {
      _paginationInfoStreamController.add(paginationInfo);
    }
  }

  void onTap() => readerContext.onTap();

  void dispose() => _paginationInfoStreamController.close();

  Set<int> getBookmarkIndexes(int nbColumns) {
    Set<int> bookmarkIndexes = {};
    for (ReaderAnnotation bookmark in bookmarks) {
      bookmark.locator?.let((locator) {
        int? index = locator.getIndex(nbColumns);
        if (index != null) {
          bookmarkIndexes.add(index);
        }
      });
    }
    return bookmarkIndexes;
  }

  List<ReaderAnnotation> getVisibleBookmarks(int columnIndex, int nbColumns) {
    List<ReaderAnnotation> visibleBookmarks = [];
    for (ReaderAnnotation bookmark in bookmarks) {
      bookmark.locator?.let((locator) {
        int? index = locator.getIndex(nbColumns);
        if (index != null && index == columnIndex) {
          visibleBookmarks.add(bookmark);
        }
      });
    }
    return visibleBookmarks;
  }
}

extension LocatorIndex on Locator {
  int? getIndex(int nbColumns) => (locations.progression != null)
      ? (locations.progression! * nbColumns + 0.5).floor()
      : null;
}
