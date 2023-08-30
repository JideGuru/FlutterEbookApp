// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class CbzController extends PublicationController {
  PageController? _pageController;

  CbzController(
      super.onServerClosed,
      super.onPageJump,
      super.locationFuture,
      super.fileAsset,
      super.streamerFuture,
      super.readerAnnotationRepository,
      super.handlersProvider,
      super.selectionListenerFactory);

  PageController get pageController => _pageController!;

  @override
  void jumpToPage(int page) => _pageController?.jumpToPage(page);

  @override
  bool get pageControllerAttached => _pageController?.hasClients == true;

  @override
  void initPageController(int initialPage) => _pageController =
      PageController(keepPage: true, initialPage: initialPage);

  @override
  void onSkipLeft({bool animated = true}) {
    if (animated) {
      _pageController?.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _pageController?.jumpToPage((_pageController!.page ?? 0).round() - 1);
    }
  }

  @override
  void onSkipRight({bool animated = true}) {
    if (animated) {
      _pageController?.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _pageController?.jumpToPage((_pageController!.page ?? 0).round() + 1);
    }
  }

  @override
  void onPageChanged(int position) {
    super.onPageChanged(position);
    List<Link> spine = publication.readingOrder;
    Link spineItem = spine[position];
    LinkPagination linkPagination = publication.paginationInfo[spineItem]!;
    Map data = {
      "location": {
        "idref": spineItem.href,
        "progression": 0.0,
      },
      "openPage": {
        "spineItemPageIndex": 0,
        "spineItemPageCount": 1,
      },
    };
    String json = const JsonCodec().encode(data);
    Locator locator = spineItem.toLocator();
    try {
      PaginationInfo paginationInfo =
          PaginationInfo.fromJson(json, position, locator, linkPagination);
      readerContext!.notifyCurrentLocation(paginationInfo, spineItem);
    } catch (e, stacktrace) {
      Fimber.d("error: $e", ex: e, stacktrace: stacktrace);
    }
  }
}
