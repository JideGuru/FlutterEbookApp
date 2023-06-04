import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/extensions/decoration_change.dart';

abstract class SelectionListener {
  final ReaderContext readerContext;
  final BuildContext context;

  SelectionListener(this.readerContext, this.context);

  JsApi? get jsApi => readerContext.currentSpineItemContext?.jsApi;

  ReaderAnnotationRepository get readerAnnotationRepository =>
      readerContext.readerAnnotationRepository;

  void displayPopup(Selection selection);

  void hidePopup();

  void showHighlightPopup(Selection selection, HighlightStyle style, Color tint,
      {String? highlightId});

  void showAnnotationPopup(Selection selection,
      {HighlightStyle? style, Color? tint, String? highlightId});

  void updateHighlight(Selection selection, HighlightStyle? style, Color? color,
          String? highlightId,
          {String? annotation}) =>
      color != null && highlightId != null
          ? readerAnnotationRepository.get(highlightId).then((highlight) {
              if (highlight != null) {
                highlight.style = style ?? HighlightStyle.highlight;
                highlight.tint = color.value;
                if (annotation != null) {
                  highlight.annotation = annotation;
                }
                readerAnnotationRepository.save(highlight);
                jsApi?.updateDecorations({
                  HtmlDecorationTemplate.highlightGroup:
                      highlight.toDecorations(isActive: false)
                });
                if (highlight.annotation == null ||
                    highlight.annotation!.isEmpty) {
                  jsApi?.deleteDecorations({
                    HtmlDecorationTemplate.highlightGroup: [
                      "${highlight.id}-${HtmlDecorationTemplate.annotationSuffix}"
                    ]
                  });
                }
              }
            })
          : null;

  void createHighlight(Selection selection, HighlightStyle? style, Color? color,
          {String? annotation}) =>
      readerAnnotationRepository
          .createHighlight(readerContext.paginationInfo, selection.locator,
              style, color?.value, annotation)
          .then((highlight) {
        jsApi?.addDecorations({
          HtmlDecorationTemplate.highlightGroup:
              highlight.toDecorations(isActive: false)
        });
      });

  void deleteHighlight(String? highlightId) {
    if (highlightId == null) {
      return;
    }
    readerAnnotationRepository.delete([highlightId]);
  }
}
