// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

import 'package:fimber/fimber.dart';
import 'package:flutter/widgets.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/callbacks/model/tap_event.dart';
import 'package:mno_navigator/src/epub/callbacks/webview_listener.dart';
import 'package:mno_shared/publication.dart';

class ReadiumChannels extends JavascriptChannels {
  static const bool logArguments = false;
  final SpineItemContext _spineItemContext;
  final ReaderAnnotationRepository? _readerAnnotationRepository;
  final ViewerSettingsBloc? viewerSettingsBloc;
  final WebViewHorizontalGestureRecognizer? webViewHorizontalGestureRecognizer;
  final WebViewListener listener;
  final Locator locator;
  late JsApi jsApi;

  ReadiumChannels(
      this._spineItemContext,
      this._readerAnnotationRepository,
      this.viewerSettingsBloc,
      this.webViewHorizontalGestureRecognizer,
      this.listener)
      : locator = Locator(
          href: _spineItemContext.spineItem.href,
          type: _spineItemContext.spineItem.type ?? "text/html",
          title: _spineItemContext.spineItem.title,
        );

  @override
  Map<String, HandlerCallback> get channels => {
        "onPaginationInfo": _onPaginationChanged,
        "onToggleBookmark": _onToggleBookmark,
        "onTap": _onTap,
        "onSwipeUp": _onSwipeUp,
        "onSwipeDown": _onSwipeDown,
        "scrollRight": (args) => _scrollRight(args.first),
        "scrollLeft": (args) => _scrollLeft(args.first),
        "onDecorationActivated": _onDecorationActivated,
        "highlightAnnotationMarkActivated": _highlightAnnotationMarkActivated,
        "highlightActivated": _highlightActivated,
        "getViewportWidth": _getViewportWidth,
        "onLeftOverlayVisibilityChanged": _onLeftOverlayVisibilityChanged,
        "onRightOverlayVisibilityChanged": _onRightOverlayVisibilityChanged,
      };

  void _onPaginationChanged(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      if (logArguments) {
        Fimber.d("onPaginationChanged: ${arguments.first}");
      }
      try {
        PaginationInfo paginationInfo = PaginationInfo.fromJson(
            arguments.first,
            _spineItemContext.spineItemIndex,
            locator,
            _spineItemContext.linkPagination);
        _spineItemContext.notifyPaginationInfo(paginationInfo);
      } on Object catch (e, stacktrace) {
        Fimber.d("onPaginationChanged error: $e, $stacktrace",
            ex: e, stacktrace: stacktrace);
      }
    }
  }

  void _onToggleBookmark(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      if (logArguments) {
        Fimber.d("onToggleBookmark: ${arguments.first}");
      }
      try {
        PaginationInfo paginationInfo = PaginationInfo.fromJson(
            arguments.first,
            _spineItemContext.spineItemIndex,
            locator,
            _spineItemContext.linkPagination);
        List<ReaderAnnotation> visibleBookmarks =
            _spineItemContext.getVisibleBookmarks(
                paginationInfo.openPage.spineItemPageIndex,
                paginationInfo.openPage.spineItemPageCount);
        if (visibleBookmarks.isNotEmpty) {
          _readerAnnotationRepository
              ?.delete(visibleBookmarks.map((b) => b.id));
        } else {
          _readerAnnotationRepository?.createBookmark(paginationInfo);
        }
      } on Object catch (e, stacktrace) {
        Fimber.d("onToggleBookmark error: $e, $stacktrace",
            ex: e, stacktrace: stacktrace);
      }
    }
  }

  bool _onTap(List<dynamic> arguments) {
    TapEvent? event = TapEvent.fromJSON(arguments.first);
    if (event == null) {
      return false;
    }
    if (logArguments) {
      Fimber.d("event: $event");
    }

    // The script prevented the default behavior.
    if (event.defaultPrevented) {
      return false;
    }

    // FIXME: Let the app handle edge taps and footnotes.

    // We ignore taps on interactive element, unless it's an element we handle ourselves such as
    // pop-up footnotes.
    if (event.interactiveElement != null) {
      return handleFootnote(event.targetElement);
    }

    // Skips to previous/next pages if the tap is on the content edges.
    double clientWidth = computeHorizontalScrollExtent();
    double thresholdRange = 0.2 * clientWidth;

    // FIXME: Call listener.onTap if scrollLeft|Right fails
    if (event.point.dx < thresholdRange) {
      _scrollLeft(false);
      return true;
    }
    if (clientWidth - event.point.dx < thresholdRange) {
      _scrollRight(false);
      return true;
    }
    return listener.onTap(event.point);
  }

  double get devicePixelRatio =>
      WidgetsBinding.instance.window.devicePixelRatio;

  double computeHorizontalScrollExtent() =>
      _spineItemContext.readerContext.viewportWidth.toDouble();

  /// TODO implement display footnote
  bool handleFootnote(String targetElement) => true;

  void _onSwipeUp(List<dynamic> arguments) {
    viewerSettingsBloc?.add(IncrFontSizeEvent());
  }

  void _onSwipeDown(List<dynamic> arguments) {
    viewerSettingsBloc?.add(DecrFontSizeEvent());
  }

  void _scrollRight(bool animated) {
    if (logArguments) {
      Fimber.d("animated: $animated");
    }
    jsApi.scrollRight().then((success) {
      if (success is bool && !success) {
        listener.goRight(animated: animated);
      }
    });
  }

  void _scrollLeft(bool animated) {
    if (logArguments) {
      Fimber.d("animated: $animated");
    }
    jsApi.scrollLeft().then((success) {
      if (success is bool && !success) {
        listener.goLeft(animated: animated);
      }
    });
  }

  Future<bool> _onDecorationActivated(List<dynamic> arguments) async {
    if (logArguments) {
      Fimber.d("arguments: $arguments");
    }
    String eventJson = arguments.first;
    Map<String, dynamic>? obj = json.decode(eventJson);
    String? id = obj?.optNullableString("id");
    String? group = obj?.optNullableString("group");
    Rectangle<double>? rect = obj?.optJSONObject("rect")?.rect;
    TapEvent? click = TapEvent.fromJSONObject(obj?.optJSONObject("click"));
    if (id == null || group == null || rect == null || click == null) {
      Fimber.e("Invalid JSON for onDecorationActivated: $eventJson");
      return false;
    }
    return listener.onDecorationActivated(id, group, rect, click.point);
  }

  void _highlightAnnotationMarkActivated(List<dynamic> arguments) {
    String highlightId = arguments.first;
    if (logArguments) {
      Fimber.d("highlightId: $highlightId");
    }
  }

  void _highlightActivated(List<dynamic> arguments) {
    String highlightId = arguments.first;
    if (logArguments) {
      Fimber.d("highlightId: $highlightId");
    }
  }

  int _getViewportWidth(List<dynamic> arguments) =>
      _spineItemContext.readerContext.viewportWidth;

  void _onLeftOverlayVisibilityChanged(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      if (logArguments) {
        Fimber.d(
            "================== _onLeftOverlayVisibilityChanged, message: ${arguments.first}, "
            "${arguments.first.runtimeType}, recognizer: $webViewHorizontalGestureRecognizer");
      }
      bool visibility = arguments.first;
      webViewHorizontalGestureRecognizer?.setLeftOverlayVisible(visibility);
    }
  }

  void _onRightOverlayVisibilityChanged(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      if (logArguments) {
        Fimber.d(
            "================== _onRightOverlayVisibilityChanged, message: ${arguments.first}, "
            "${arguments.first.runtimeType}, recognizer: $webViewHorizontalGestureRecognizer");
      }
      bool visibility = arguments.first;
      webViewHorizontalGestureRecognizer?.setRightOverlayVisible(visibility);
    }
  }
}
