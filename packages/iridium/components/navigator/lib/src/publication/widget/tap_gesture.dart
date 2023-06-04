// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TapGesture extends StatefulWidget {
  final Widget child;
  final GestureTapCallback onTap;

  const TapGesture({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => TapGestureState();
}

class TapGestureState extends State<TapGesture> {
  PointerDownEvent? _downEvent;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (event) {
          _downEvent = event;
        },
        onPointerCancel: (event) {
          if (_downEvent != null && event.pointer == _downEvent!.pointer) {
            _downEvent = null;
          }
        },
        onPointerUp: (event) {
          if (_downEvent != null && event.pointer == _downEvent!.pointer) {
            double distance = (event.position - _downEvent!.position).distance;
            _downEvent = null;
            if (distance < kDoubleTapTouchSlop) {
              widget.onTap();
            }
          }
        },
        child: widget.child,
      );
}
