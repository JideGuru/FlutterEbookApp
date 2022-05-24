// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GesturesChannels extends JavascriptChannels {
  final SpineItemContext _spineItemContext;
  final ViewerSettingsBloc? viewerSettingsBloc;
  final WebViewHorizontalGestureRecognizer? webViewHorizontalGestureRecognizer;
  late JsApi jsApi;

  GesturesChannels(this._spineItemContext, this.viewerSettingsBloc,
      this.webViewHorizontalGestureRecognizer);

  @override
  List<JavascriptChannel> get channels => [
        JavascriptChannel(
          name: "GestureCallbacksOnTap",
          onMessageReceived: _onTap,
        ),
        JavascriptChannel(
          name: "GestureCallbacksOnSwipeUp",
          onMessageReceived: _onSwipeUp,
        ),
        JavascriptChannel(
          name: "GestureCallbacksOnSwipeDown",
          onMessageReceived: _onSwipeDown,
        ),
        JavascriptChannel(
          name: 'GestureCallbacksOnBeginningVisibilityChanged',
          onMessageReceived: _onBeginningVisibilityChanged,
        ),
        JavascriptChannel(
          name: 'GestureCallbacksOnEndVisibilityChanged',
          onMessageReceived: _onEndVisibilityChanged,
        ),
      ];

  void _onTap(JavascriptMessage message) {
    Fimber.d("onTap: ${message.message}");
    try {
      Coord coord = Coord.fromJson(message.message);
      Fimber.d("onTap, coord: $coord");
      _spineItemContext.onTap();
    } on Exception catch (e, stacktrace) {
      Fimber.d("onTap: $e, $stacktrace");
    }
  }

  void _onSwipeUp(JavascriptMessage message) {
    viewerSettingsBloc?.add(IncrFontSizeEvent());
  }

  void _onSwipeDown(JavascriptMessage message) {
    viewerSettingsBloc?.add(DecrFontSizeEvent());
  }

  void _onBeginningVisibilityChanged(JavascriptMessage message) {
//    Fimber.d("================== _onBeginningVisibilityChanged, message: " +
//        message.message);
    bool visibility = message.message.toLowerCase() == 'true' ||
        message.message.toLowerCase() == '1';
    webViewHorizontalGestureRecognizer?.setBeginningVisible(visibility);
  }

  void _onEndVisibilityChanged(JavascriptMessage message) {
//    Fimber.d("================== _onEndVisibilityChanged, message: " +
//        message.message);
    bool visibility = message.message.toLowerCase() == 'true' ||
        message.message.toLowerCase() == '1';
    webViewHorizontalGestureRecognizer?.setEndVisible(visibility);
  }
}
