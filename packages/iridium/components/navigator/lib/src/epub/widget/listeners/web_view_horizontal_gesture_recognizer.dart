// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:mno_navigator/epub.dart';

/// Inspired by https://stackoverflow.com/questions/57069716/scrolling-priority-when-combining-pageview-with-webview-in-flutter-1-7-8/57150906#57150906
///
class WebViewHorizontalGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  final int chapNumber;
  final WebViewScreen webView;

  bool isBeginningVisible = true;
  bool isEndVisible = false;

  void setBeginningVisible(bool visibility) {
//    Fimber.d(">>> setBeginningVisible[$chapNumber], visibility: $visibility");
    isBeginningVisible = visibility;
  }

  void setEndVisible(bool visibility) {
//    Fimber.d(">>> setEndVisible[$chapNumber], visibility: $visibility");
    isEndVisible = visibility;
  }

  WebViewHorizontalGestureRecognizer({
    required this.chapNumber,
    required this.webView,
    PointerDeviceKind? kind,
  }) : super(supportedDevices: (kind != null) ? {kind} : const {}) {
    onUpdate = _onUpdate;
  }

  void _onUpdate(DragUpdateDetails details) {
//    Fimber.d(">>> onUpdate[$chapNumber]: ${details.delta.direction}");
  }

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
//    Fimber.d(
//        ">>> Pointer tracking STARTED, pointer[$chapNumber]: ${event.pointer}");
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {
//    Fimber.d(">>> didStopTrackingLastPointer");
  }

  @override
  void handleEvent(PointerEvent event) {
//     Fimber.d(">>> handleEvent[$chapNumber] =============== $event");
//     Fimber.d(">>> handleEvent[$chapNumber] =============== isBeginningVisible: $isBeginningVisible, isEndVisible: $isEndVisible");
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (isVerticalDrag(dy, dx)) {
        // vertical drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
        //} else if (dx > kTouchSlop && dx > dy) {
      } else if (dx > dy) {
        // horizontal drag
        if ((isEndVisible && isDraggingTowardsLeft(event)) ||
            (isBeginningVisible && isDraggingTowardsRight(event))) {
          // The enclosing PageView must handle the drag since the webview cannot scroll anymore
          stopTrackingPointer(event.pointer);
        } else {
          // horizontal drag - accept
          resolve(GestureDisposition.accepted);
          _dragDistance = Offset.zero;
        }
      }
    }
  }

  bool isVerticalDrag(double dy, double dx) => dy > dx && dy > kTouchSlop;

  bool isDraggingTowardsRight(PointerEvent event) => event.delta.dx > 0;

  bool isDraggingTowardsLeft(PointerEvent event) => (event.delta.dx < 0);
}
