// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:preload_page_view/preload_page_view.dart';

class EpubController extends PublicationController {
  PreloadPageController? _pageController;

  EpubController(
      Function onServerClosed,
      Function? onPageJump,
      Future<String?> locationFuture,
      PublicationAsset fileAsset,
      Future<Streamer> streamerFuture,
      ReaderAnnotationRepository readerAnnotationRepository,
      Function0<List<RequestHandler>> handlersProvider,
      SelectionListenerFactory selectionListenerFactory,
      [bool displayEditAnnotationIcon = true])
      : super(
          onServerClosed,
          onPageJump,
          locationFuture,
          fileAsset,
          streamerFuture,
          readerAnnotationRepository,
          handlersProvider,
          selectionListenerFactory,
          true,
          displayEditAnnotationIcon,
        );

  PreloadPageController get pageController => _pageController!;

  /// false if progression is null: we make the assumption that it is ltr
  bool get isReverseOrder =>
      readerContext?.readingProgression?.isReverseOrder() ?? false;

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
      viewportFraction: Platform.isAndroid ? 0.99 : 1);

  @override
  void onSkipLeft({bool animated = true}) {
    /*
        R2 - EpubNavigatorFragment:
        override fun goBackward(animated: Boolean, completion: () -> Unit): Boolean {
          if (publication.metadata.presentation.layout == EpubLayout.FIXED) {
              return goToPreviousResource(animated, completion)
          }
        etc.
      }
     */
    PreloadPageController? pageController = _pageController;
    Fimber.d("animated: $animated");
    if (pageController != null) {
      if (animated) {
        var fn = isReverseOrder
            ? _pageController?.nextPage
            : _pageController?.previousPage;
        skip(fn);
      } else {
        int page =
            (pageController.page ?? 0).round() + (isReverseOrder ? 1 : -1);
        Fimber.d("page: $page");
        pageController.jumpToPage(page);
      }
    }
  }

  @override
  void onSkipRight({bool animated = true}) {
    /*
        R2 - EpubNavigatorFragment:
        override fun goForward(animated: Boolean, completion: () -> Unit): Boolean {
          if (publication.metadata.presentation.layout == EpubLayout.FIXED) {
              return goToNextResource(animated, completion)
          }
          etc.
      }
     */
    PreloadPageController? pageController = _pageController;
    Fimber.d("animated: $animated");
    if (pageController != null) {
      if (animated) {
        var fn = isReverseOrder
            ? pageController.previousPage
            : pageController.nextPage;
        skip(fn);
      } else {
        int page =
            (pageController.page ?? 0).round() + (isReverseOrder ? -1 : 1);
        Fimber.d("page: $page");
        pageController.jumpToPage(page);
      }
    }
  }

  void skip(
      Future<void> Function({required Duration duration, required Curve curve})?
          fn) {
    if (fn != null) {
      fn(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      throw Exception("Navigation function is null, should never happen");
    }
  }
}
