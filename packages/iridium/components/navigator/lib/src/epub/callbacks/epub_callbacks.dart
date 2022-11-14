// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EpubCallbacks {
  final LauncherUIChannels _launcherUIChannels;
  final GesturesChannels _gesturesChannels;

  set jsApi(JsApi jsApi) {
    _launcherUIChannels.jsApi = jsApi;
    _gesturesChannels.jsApi = jsApi;
  }

  EpubCallbacks(
      SpineItemContext spineItemContext,
      ViewerSettingsBloc? viewerSettingsBloc,
      ReaderAnnotationRepository? bookmarkRepository,
      WebViewHorizontalGestureRecognizer? webViewHorizontalGestureRecognizer)
      : _launcherUIChannels =
            LauncherUIChannels(spineItemContext, bookmarkRepository),
        _gesturesChannels = GesturesChannels(spineItemContext,
            viewerSettingsBloc, webViewHorizontalGestureRecognizer);

  Set<JavascriptChannel> get channels => [
        _launcherUIChannels,
        _gesturesChannels
      ].expand((c) => c.channels).toSet();
}
