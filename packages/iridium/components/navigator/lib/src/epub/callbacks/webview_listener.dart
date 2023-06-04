import 'dart:math';
import 'dart:ui';

import 'package:mno_shared/publication.dart';

abstract class WebViewListener<WebView, Request> {
  static void emptyFunc() {}

  ReadingProgression get readingProgression;

  void onResourceLoaded(Link? link, WebView webView, String? url) {}

  void onPageLoaded();

  void onPageChanged(int pageIndex, int totalPages, String url);

  void onPageEnded(bool end);

  void onScroll();

  bool onTap(Offset point);

  Future<bool> onDecorationActivated(String id, String group,
          Rectangle<double> rect, Offset point) async =>
      false;

  void onProgressionChanged();

  void onHighlightActivated(String id);

  void onHighlightAnnotationMarkActivated(String id);

  bool goRight({bool animated = false, Function completion = emptyFunc});

  bool goLeft({bool animated = false, Function completion = emptyFunc});

  /// Returns the custom [ActionMode.Callback] to be used with the text selection menu.
//   ActionMode.Callback? get selectionActionModeCallback  => null;

  /// Offers an opportunity to override a request loaded by the given web view.
  bool shouldOverrideUrlLoading(WebView webView, Request request) => false;
}
