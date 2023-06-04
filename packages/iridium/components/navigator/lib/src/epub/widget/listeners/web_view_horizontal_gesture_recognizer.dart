// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:mno_navigator/src/publication/reader_context.dart';
import 'package:mno_shared/publication.dart';

/// Inspired by https://stackoverflow.com/questions/57069716/scrolling-priority-when-combining-pageview-with-webview-in-flutter-1-7-8/57150906#57150906
///
class WebViewHorizontalGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  final int chapNumber;
  final Link link;
  ReaderContext readerContext;

  bool _leftOverlayVisible = false;
  bool _rightOverlayVisible = false;

  void setLeftOverlayVisible(bool visibility) {
    // Fimber.d(
    //     ">>> setLeftOverlayVisible[$chapNumber][${getSpineItemHref()}][${webView.address}][${webView.position}], visibility: $visibility");
    _leftOverlayVisible = visibility;
  }

  void setRightOverlayVisible(bool visibility) {
    // Fimber.d(
    //     ">>> setRightOverlayVisible[$chapNumber][${getSpineItemHref()}][${webView.position}], visibility: $visibility");
    _rightOverlayVisible = visibility;
  }

  WebViewHorizontalGestureRecognizer({
    required this.chapNumber,
    required this.link,
    PointerDeviceKind? kind,
    required this.readerContext,
  }) : super(supportedDevices: (kind != null) ? {kind} : const {}) {
    onUpdate = _onUpdate;
  }

  void _onUpdate(DragUpdateDetails details) {
    // Fimber.d(
    //     ">>> onUpdate[$chapNumber][${getSpineItemHref()}]: ${details.delta.direction}");
  }

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
    // Fimber.d(
    //     ">>> Pointer tracking STARTED, pointer[$chapNumber][${getSpineItemHref()}]: ${event.pointer}");
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {
    // Fimber.d(
    //     ">>> didStopTrackingLastPointer [$chapNumber][${getSpineItemHref()}]");
  }

  @override
  void handleEvent(PointerEvent event) {
    // TODO Fix this: readerContext.currentSpineItem?.title is null, so we are using this path to access the title of the current spine item
    // Fimber.d(
    //     ">>> handleEvent[$chapNumber][${link.href}] =============== i_leftOverlayVisible: $_leftOverlayVisible, _rightOverlayVisible: $_rightOverlayVisible");
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
        if ((_rightOverlayVisible && isDraggingTowardsLeft(event)) ||
            (_leftOverlayVisible && isDraggingTowardsRight(event))) {
          // The enclosing PageView must handle the drag since the webview cannot scroll anymore
          // Fimber.d(
          //     ">>> handleEvent[$chapNumber][$curHRef] =============== REJECT, _leftOverlayVisible: $_leftOverlayVisible, _rightOverlayVisible: $_rightOverlayVisible");
          stopTrackingPointer(event.pointer);
        } else {
          // horizontal drag - accept
          // Fimber.d(
          //     ">>> handleEvent[$chapNumber][$curHRef] =============== ACCEPT, _leftOverlayVisible: $_leftOverlayVisible, _rightOverlayVisible: $_rightOverlayVisible");
          resolve(GestureDisposition.accepted);
          _dragDistance = Offset.zero;
        }
      }
    }
  }

  String? getSpineItemHref() => readerContext.publication?.manifest.readingOrder
      .elementAt(chapNumber)
      .href;

  bool isVerticalDrag(double dy, double dx) => dy > dx && dy > kTouchSlop;

  bool isDraggingTowardsRight(PointerEvent event) => event.delta.dx > 0;

  bool isDraggingTowardsLeft(PointerEvent event) => (event.delta.dx < 0);
}
