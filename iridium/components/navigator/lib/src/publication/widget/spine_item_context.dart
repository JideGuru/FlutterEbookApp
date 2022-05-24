// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class SpineItemContextWidget extends InheritedWidget {
  final SpineItemContext spineItemContext;

  const SpineItemContextWidget(
      {Key? key, required Widget child, required this.spineItemContext})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(SpineItemContextWidget oldWidget) =>
      spineItemContext != oldWidget.spineItemContext;
}

class SpineItemContext {
  final ReaderContext readerContext;
  final LinkPagination linkPagination;
  final StreamController<PaginationInfo> _paginationInfoStreamController;
  PaginationInfo? currentPaginationInfo;
  JsApi? jsApi;

  SpineItemContext({
    required this.readerContext,
    required this.linkPagination,
  }) : _paginationInfoStreamController = StreamController.broadcast();

  Publication get publication => readerContext.publication!;

  Stream<PaginationInfo> get paginationInfoStream =>
      _paginationInfoStreamController.stream;

  static SpineItemContext? of(BuildContext context) {
    SpineItemContextWidget? readerContextWidget =
        context.dependOnInheritedWidgetOfExactType();
    return readerContextWidget?.spineItemContext;
  }

  void notifyPaginationInfo(PaginationInfo paginationInfo) {
    currentPaginationInfo = paginationInfo;
    if (!_paginationInfoStreamController.isClosed) {
      _paginationInfoStreamController.add(paginationInfo);
    }
  }

  void onTap() => readerContext.onTap();

  void dispose() => _paginationInfoStreamController.close();
}
