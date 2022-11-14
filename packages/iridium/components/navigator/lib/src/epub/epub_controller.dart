// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:preload_page_view/preload_page_view.dart';

class EpubController extends PublicationController {
  PreloadPageController? _pageController;
  final WidgetKeepAliveListener widgetKeepAliveListener;

  EpubController(
    Function onServerClosed,
    Function? onPageJump,
    Future<String?> locationFuture,
    FileAsset fileAsset,
    Future<Streamer> streamerFuture,
    ReaderAnnotationRepository readerAnnotationRepository,
    Function0<List<RequestHandler>> handlersProvider,
  )   : widgetKeepAliveListener = WidgetKeepAliveListener(),
        super(
          onServerClosed,
          onPageJump,
          locationFuture,
          fileAsset,
          streamerFuture,
          readerAnnotationRepository,
          handlersProvider,
        );

  PreloadPageController get pageController => _pageController!;

  @override
  void jumpToPage(int page) => _pageController?.jumpToPage(page);

  @override
  bool get pageControllerAttached => _pageController?.hasClients == true;

  @override
  void initPageController(int initialPage) => _pageController = PreloadPageController(
      // With Hybrid Composition, on both Android and iOS we must set viewportFraction
      // to < 1.0, in order to get the WebViews to render! Otherwise they do load the data but don't render...
      keepPage: true,
      initialPage: initialPage,
      viewportFraction: 0.9999);

  @override
  void onPrevious() => _pageController?.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  void onNext() => _pageController?.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
}
