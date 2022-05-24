// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';

class CbzController extends PublicationController {
  PageController? _pageController;

  CbzController(
    Function onServerClosed,
    Function? onPageJump,
    Future<String?> locationFuture,
    FileAsset fileAsset,
    Future<Streamer> streamerFuture,
    ReaderAnnotationRepository readerAnnotationRepository,
    Function0<List<RequestHandler>> handlersProvider,
  ) : super(
          onServerClosed,
          onPageJump,
          locationFuture,
          fileAsset,
          streamerFuture,
          readerAnnotationRepository,
          handlersProvider,
        );

  PageController get pageController => _pageController!;

  @override
  void jumpToPage(int page) => _pageController?.jumpToPage(page);

  @override
  bool get pageControllerAttached => _pageController?.hasClients == true;

  @override
  void initPageController(int initialPage) => _pageController =
      PageController(keepPage: true, initialPage: initialPage);

  @override
  void onPrevious() => _pageController?.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  void onNext() => _pageController?.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  void onPageChanged(int position) {
    super.onPageChanged(position);
    List<Link> spine = publication.readingOrder;
    Link spineItem = spine[position];
    LinkPagination linkPagination = publication.paginationInfo[spineItem]!;
    Map data = {
      "spineItem": {
        "idref": spineItem.href,
        "href": spineItem.href,
      },
      "location": {
        "version": ReadiumLocation.currentVersion,
        "idref": spineItem.href,
      },
      "openPages": [
        {
          "spineItemPageIndex": 0,
          "spineItemPageCount": 1,
          "idref": spineItem.href,
          "spineItemIndex": position,
        },
      ],
    };
    String json = const JsonCodec().encode(data);
    try {
      PaginationInfo paginationInfo =
          PaginationInfo.fromJson(json, linkPagination);
      readerContext!.notifyCurrentLocation(paginationInfo, spineItem);
    } catch (e, stacktrace) {
      Fimber.d("error: $e", ex: e, stacktrace: stacktrace);
    }
  }
}
