import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class AnnotationPopup extends StatefulWidget {
  final SelectionListener selectionListener;
  final Selection selection;
  final HighlightStyle style;
  final Color tint;
  final String? annotation;
  final String? highlightId;

  AnnotationPopup(
    this.selectionListener,
    this.selection,
    this.style,
    this.tint,
    this.annotation,
    this.highlightId,
  );

  static void showAnnotationPopup(
    BuildContext context,
    SelectionListener selectionListener,
    Selection selection,
    HighlightStyle style,
    Color tint,
    String? annotation,
    String? highlightId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AnnotationPopup(
          selectionListener, selection, style, tint, annotation, highlightId),
    );
  }

  @override
  State<StatefulWidget> createState() => AnnotationPopupState();
}

class AnnotationPopupState extends State<AnnotationPopup> {
  static const double borderWidth = 4.0;
  late TextEditingController _controller;

  SelectionListener get selectionListener => widget.selectionListener;

  Selection get selection => widget.selection;

  HighlightStyle get style => widget.style;

  Color get tint => widget.tint;

  String? get annotation => widget.annotation;

  String? get highlightId => widget.highlightId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: annotation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text("Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: tint, width: borderWidth),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: borderWidth),
                child: Text(selection.locator.text.highlight ?? ""),
              ),
            ),
            TextField(
              controller: _controller,
              onSubmitted: (value) => saveHighlight(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              saveHighlight(_controller.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      );

  void saveHighlight(String text) {
    String? id = highlightId;
    if (id == null) {
      selectionListener.createHighlight(selection, style, tint,
          annotation: text);
    } else {
      selectionListener.updateHighlight(selection, style, tint, id,
          annotation: text);
    }
  }
}
