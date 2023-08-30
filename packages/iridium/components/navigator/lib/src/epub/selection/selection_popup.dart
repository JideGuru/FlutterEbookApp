import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

abstract class SelectionPopup {
  final SimpleSelectionListener selectionListener;
  OverlayEntry? entry;

  SelectionPopup(this.selectionListener);

  ReaderContext get readerContext => selectionListener.readerContext;

  double get optionsWidth;

  double get optionsHeight;

  Rect getPopupRect(BuildContext context, Rectangle<double> rect) {
    Size size = MediaQuery.of(context).size;
    double left = max(
        16.0,
        min((rect.left + rect.right - optionsWidth) / 2,
            size.width - optionsWidth - 16.0));
    double top = rect.top - 8.0 - optionsHeight;
    double width = optionsWidth;
    double height = optionsHeight;
    return Rect.fromLTWH(left, top, width, height);
  }

  @protected
  void displayPopup(BuildContext context, Selection selection,
      {required Widget child}) {
    Rectangle<double>? rect = selection.rectOnScreen;
    OverlayEntry entry = OverlayEntry(
        builder: (context) => Stack(
              children: [
                GestureDetector(
                  onTap: close,
                ),
                if (rect != null)
                  Positioned.fromRect(
                    rect: getPopupRect(context, rect),
                    child: child,
                  ),
              ],
            ));
    this.entry = entry;
    Overlay.of(context)?.insert(entry);
  }

  void hidePopup() {
    entry?.remove();
    entry = null;
  }

  void close() {
    selectionListener.jsApi?.clearSelection();
    selectionListener.hidePopup();
  }
}
