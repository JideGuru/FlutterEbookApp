// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_navigator/epub.dart';
import 'package:rxdart/rxdart.dart';

class WidgetKeepAliveListener {
  final Map<int, WebViewScreenState> keepAliveWidgets =
      <int, WebViewScreenState>{};
  ReplaySubject<void> subject = ReplaySubject<void>();
  int _position = 0;

  WidgetKeepAliveListener() {
    subject.throttleTime(const Duration(seconds: 1)).listen(_refreshPages);
  }

  int get position => _position;

  set position(int value) {
    _position = value;
    Future(() {
      keepAliveWidgets.forEach((index, state) {
//        state.updateKeepAlive();
        if (index == value) {
          state.refreshPage();
        }
      });
    });
  }

  void register(int index, WebViewScreenState state) {
    Future(() => keepAliveWidgets[index] = state);
  }

  void unregister(int position) {
    Future(() => keepAliveWidgets.remove(position));
  }

  void refreshPages() {
    subject.add(null);
  }

  void _refreshPages(void event) {
    keepAliveWidgets.forEach((index, state) {
      state.refreshPage();
    });
  }
}
