// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:flutter/widgets.dart';

typedef JavaScriptHandlerCallback = dynamic Function(List<dynamic> arguments);

class InAppWebViewController {
  Future<dynamic> evaluateJavascript({required String source}) async {}

  void addJavaScriptHandler(
      {required String handlerName,
      required JavaScriptHandlerCallback callback}) {}

  Future<void> loadUrl(
      {required URLRequest urlRequest,
      @Deprecated('Use `allowingReadAccessTo` instead')
          Uri? iosAllowingReadAccessTo,
      Uri? allowingReadAccessTo}) async {}

  Future<Uint8List?> takeScreenshot() async => null;
}

class URLRequest {
  URLRequest({required Uri? url});
}

class InAppWebView extends StatefulWidget {
  const InAppWebView({
    super.key,
    URLRequest? initialUrlRequest,
    InAppWebViewGroupOptions? initialOptions,
    void Function(
            InAppWebViewController controller, ConsoleMessage consoleMessage)?
        onConsoleMessage,
    void Function(
            InAppWebViewController controller, WebResourceRequest request)?
        androidShouldInterceptRequest,
    shouldOverrideUrlLoading,
    onLoadStop,
    gestureRecognizers,
    contextMenu,
    onWebViewCreated,
  });

  @override
  State<StatefulWidget> createState() => _InAppWebViewState();
}

class _InAppWebViewState extends State<InAppWebView> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class WebResourceRequest {
  Uri url;
  Map<String, String>? headers;
  String? method;
  bool? hasGesture;
  bool? isForMainFrame;
  bool? isRedirect;

  WebResourceRequest(
      {required this.url,
      this.headers,
      required this.method,
      required this.hasGesture,
      required this.isForMainFrame,
      required this.isRedirect});
}

class InAppWebViewGroupOptions {
  late InAppWebViewOptions crossPlatform;
  late AndroidInAppWebViewOptions android;

  InAppWebViewGroupOptions(
      {InAppWebViewOptions? crossPlatform,
      AndroidInAppWebViewOptions? android}) {
    this.crossPlatform = crossPlatform ?? InAppWebViewOptions();
    this.android = android ?? AndroidInAppWebViewOptions();
  }
}

class AndroidInAppWebViewOptions {
  AndroidInAppWebViewOptions({
    bool useHybridComposition = false,
    bool useShouldInterceptRequest = false,
    bool safeBrowsingEnabled = true,
    AndroidCacheMode? cacheMode,
    AndroidActionModeMenuItem? disabledActionModeMenuItems,
  });
}

class InAppWebViewOptions {
  bool useShouldOverrideUrlLoading;
  bool verticalScrollBarEnabled;
  bool horizontalScrollBarEnabled;
  String? userAgent;

  InAppWebViewOptions({
    this.useShouldOverrideUrlLoading = false,
    this.verticalScrollBarEnabled = true,
    this.horizontalScrollBarEnabled = true,
    this.userAgent,
  });
}

class AndroidCacheMode {
  const AndroidCacheMode._internal();

  static const LOAD_DEFAULT = AndroidCacheMode._internal();
  static const LOAD_CACHE_ELSE_NETWORK = AndroidCacheMode._internal();
  static const LOAD_NO_CACHE = AndroidCacheMode._internal();
  static const LOAD_CACHE_ONLY = AndroidCacheMode._internal();
}

class AndroidActionModeMenuItem {
  final int _value;

  const AndroidActionModeMenuItem._internal(this._value);

  static final Set<AndroidActionModeMenuItem> values = {
    AndroidActionModeMenuItem.MENU_ITEM_NONE,
    AndroidActionModeMenuItem.MENU_ITEM_SHARE,
    AndroidActionModeMenuItem.MENU_ITEM_WEB_SEARCH,
    AndroidActionModeMenuItem.MENU_ITEM_PROCESS_TEXT,
  };

  int toValue() => _value;

  static const MENU_ITEM_NONE = AndroidActionModeMenuItem._internal(0);
  static const MENU_ITEM_SHARE = AndroidActionModeMenuItem._internal(1);
  static const MENU_ITEM_WEB_SEARCH = AndroidActionModeMenuItem._internal(2);
  static const MENU_ITEM_PROCESS_TEXT = AndroidActionModeMenuItem._internal(4);

  AndroidActionModeMenuItem operator |(AndroidActionModeMenuItem value) =>
      AndroidActionModeMenuItem._internal(value.toValue() | _value);
}

class ConsoleMessageLevel {
  final int _value;

  const ConsoleMessageLevel._internal(this._value);

  static final Set<ConsoleMessageLevel> values = {
    ConsoleMessageLevel.TIP,
    ConsoleMessageLevel.LOG,
    ConsoleMessageLevel.WARNING,
    ConsoleMessageLevel.ERROR,
    ConsoleMessageLevel.DEBUG,
  };

  int toValue() => _value;

  static const TIP = ConsoleMessageLevel._internal(0);
  static const LOG = ConsoleMessageLevel._internal(1);
  static const WARNING = ConsoleMessageLevel._internal(2);
  static const ERROR = ConsoleMessageLevel._internal(3);
  static const DEBUG = ConsoleMessageLevel._internal(4);
}

class ConsoleMessage {
  String message;
  ConsoleMessageLevel messageLevel;

  ConsoleMessage(
      {this.message = "", this.messageLevel = ConsoleMessageLevel.LOG});
}

class NavigationActionPolicy {
  const NavigationActionPolicy._internal();

  static const CANCEL = NavigationActionPolicy._internal();
  static const ALLOW = NavigationActionPolicy._internal();
}

class ContextMenu {
  final void Function(InAppWebViewHitTestResult hitTestResult)?
      onCreateContextMenu;

  final void Function()? onHideContextMenu;

  final ContextMenuOptions? options;

  ContextMenu({this.onCreateContextMenu, this.onHideContextMenu, this.options});
}

class ContextMenuOptions {
  bool hideDefaultSystemContextMenuItems;

  ContextMenuOptions({this.hideDefaultSystemContextMenuItems = false});
}

class InAppWebViewHitTestResultType {
  final int _value;

  const InAppWebViewHitTestResultType._internal(this._value);

  static final Set<InAppWebViewHitTestResultType> values = {
    InAppWebViewHitTestResultType.UNKNOWN_TYPE,
    InAppWebViewHitTestResultType.PHONE_TYPE,
    InAppWebViewHitTestResultType.GEO_TYPE,
    InAppWebViewHitTestResultType.EMAIL_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.EDIT_TEXT_TYPE,
  };

  static const UNKNOWN_TYPE = InAppWebViewHitTestResultType._internal(0);
  static const PHONE_TYPE = InAppWebViewHitTestResultType._internal(2);
  static const GEO_TYPE = InAppWebViewHitTestResultType._internal(3);
  static const EMAIL_TYPE = InAppWebViewHitTestResultType._internal(4);
  static const IMAGE_TYPE = InAppWebViewHitTestResultType._internal(5);
  static const SRC_ANCHOR_TYPE = InAppWebViewHitTestResultType._internal(7);
  static const SRC_IMAGE_ANCHOR_TYPE =
      InAppWebViewHitTestResultType._internal(8);
  static const EDIT_TEXT_TYPE = InAppWebViewHitTestResultType._internal(9);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppWebViewHitTestResultType &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}

class InAppWebViewHitTestResult {
  ///The type of the hit test result.
  InAppWebViewHitTestResultType? type;

  ///Additional type-dependant information about the result.
  String? extra;

  InAppWebViewHitTestResult({this.type, this.extra});
}

class WebResourceResponse {
  String contentType;
  String contentEncoding;
  Uint8List? data;
  Map<String, String>? headers;
  int? statusCode;
  String? reasonPhrase;

  WebResourceResponse(
      {this.contentType = "",
      this.contentEncoding = "utf-8",
      this.data,
      this.headers,
      this.statusCode,
      this.reasonPhrase});
}

class AndroidInAppWebViewController {
  static Future<void> setWebContentsDebuggingEnabled(bool enabled) async {}
}
