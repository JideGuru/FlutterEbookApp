import 'dart:ui';

import 'package:mno_webview/src/flutter_inappwebview_stub.dart';

class HeadlessInAppWebView {
  final Size initialSize;
  final URLRequest? initialUrlRequest;
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStop;
  final void Function(InAppWebViewController controller)? onWebViewCreated;
  HeadlessInAppWebView({
    this.initialSize = const Size(-1, -1),
    this.initialUrlRequest,
    this.onLoadStop,
    this.onWebViewCreated,
  });
  void dispose() {}
  void run() {}
}
