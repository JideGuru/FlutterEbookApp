import 'package:dfunc/dfunc.dart';
import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/selection/annotation_popup.dart';
import 'package:mno_navigator/src/epub/selection/highlight_popup.dart';
import 'package:mno_navigator/src/epub/selection/new_selection_popup.dart';

class SimpleSelectionListener extends SelectionListener {
  final State state;
  NewSelectionPopup? _newSelectionPopup;
  HighlightPopup? _highlightPopup;

  SimpleSelectionListener(
      this.state, ReaderContext readerContext, BuildContext context)
      : super(readerContext, context);

  @override
  void displayPopup(Selection selection) {
    _newSelectionPopup = NewSelectionPopup(this);
    _newSelectionPopup!.displaySelectionPopup(context, selection);
  }

  @override
  void hidePopup() {
    _hideSelectionPopup();
    _hideHighlightPopup();
  }

  void _hideSelectionPopup() {
    _newSelectionPopup?.hidePopup();
    _newSelectionPopup = null;
  }

  void _hideHighlightPopup() {
    _highlightPopup?.hidePopup();
    _highlightPopup = null;
  }

  @override
  void showHighlightPopup(Selection selection, HighlightStyle style, Color tint,
      {String? highlightId}) {
    _hideSelectionPopup();
    _highlightPopup = HighlightPopup(this);
    _highlightPopup!
        .showHighlightPopup(context, selection, style, tint, highlightId);
  }

  @override
  void showAnnotationPopup(Selection selection,
      {HighlightStyle? style, Color? tint, String? highlightId}) async {
    hidePopup();
    jsApi?.clearSelection();
    style ??= HighlightStyle.highlight;
    tint ??= HighlightPopup.highlightTints[0];
    ReaderAnnotation? highlight;
    if (highlightId != null) {
      highlight = await readerAnnotationRepository.get(highlightId);
      style = highlight?.style ?? style;
      tint = highlight?.tint?.let((it) => Color(it)) ?? tint;
    }
    if (state.mounted) {
      AnnotationPopup.showAnnotationPopup(context, this, selection, style, tint,
          highlight?.annotation, highlightId);
    }
  }
}
