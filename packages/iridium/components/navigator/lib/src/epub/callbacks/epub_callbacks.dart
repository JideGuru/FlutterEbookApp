// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/callbacks/webview_listener.dart';

class EpubCallbacks {
  final LauncherUIChannels _launcherUIChannels;
  final ReadiumChannels _readiumGesturesChannels;

  set jsApi(JsApi jsApi) {
    _launcherUIChannels.jsApi = jsApi;
    _readiumGesturesChannels.jsApi = jsApi;
  }

  EpubCallbacks(
      SpineItemContext spineItemContext,
      ViewerSettingsBloc? viewerSettingsBloc,
      ReaderAnnotationRepository? bookmarkRepository,
      WebViewHorizontalGestureRecognizer? webViewHorizontalGestureRecognizer,
      WebViewListener listener)
      : _launcherUIChannels = LauncherUIChannels(),
        _readiumGesturesChannels = ReadiumChannels(
            spineItemContext,
            bookmarkRepository,
            viewerSettingsBloc,
            webViewHorizontalGestureRecognizer,
            listener);

  Map<String, HandlerCallback> get channels => {
        ..._launcherUIChannels.channels,
        ..._readiumGesturesChannels.channels,
      };
}
