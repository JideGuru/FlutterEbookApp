// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/publication/model/annotation_type_and_idref_predicate.dart';
import 'package:mno_shared/publication.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final WidgetKeepAliveListener widgetKeepAliveListener;
  final Link link;
  final int position;
  final String address;
  final ReaderContext readerContext;

  WebViewScreen(
      {required this.widgetKeepAliveListener,
      required this.link,
      required this.position,
      required this.address,
      required this.readerContext})
      : super(key: PageStorageKey(link.id ?? link.href));

  @override
  State<StatefulWidget> createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  JsApi? _jsApi;
  late ReaderThemeBloc _readerThemeBloc;
  late ViewerSettingsBloc _viewerSettingsBloc;
  late CurrentSpineItemBloc _currentSpineItemBloc;
  late SpineItemContext _spineItemContext;
  late WebViewHorizontalGestureRecognizer webViewHorizontalGestureRecognizer;
  StreamSubscription<List<String>>? _annotationsSubscription;
  StreamSubscription<ReaderThemeState>? _readerThemeSubscription;
  StreamSubscription<ViewerSettingsState>? _viewerSettingsSubscription;
  StreamSubscription<CurrentSpineItemState>? _currentSpineItemSubscription;
  StreamSubscription<ReaderCommand>? _readerCommandSubscription;
  StreamSubscription<PaginationInfo>? _paginationInfoSubscription;
  late EpubCallbacks epubCallbacks;
  late bool currentSelectedSpineItem;

  bool isLoaded = false;

  int get position => widget.position;

  Link get spineItem => widget.link;
  ReaderContext get readerContext => widget.readerContext;
  Publication get publication => readerContext.publication!;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition (see https://pub.dev/packages/webview_flutter/versions/2.8.0)
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView(); // For Hybrid Composition C (faster) - Default on 3.0.0
    // if (Platform.isAndroid) WebView.platform = AndroidWebView(); // For Virtual Display (slower)
    // Fix for blank WebViews with 3.0.0 (https://github.com/flutter/flutter/issues/74626)
    WidgetsBinding.instance!.addPostFrameCallback((callback) {
      setState(() {
        isLoaded = true;
      });
    });
    LinkPagination linkPagination = publication.paginationInfo[spineItem]!;
    _spineItemContext = SpineItemContext(
      readerContext: readerContext,
      linkPagination: linkPagination,
    );
    _readerThemeBloc = BlocProvider.of<ReaderThemeBloc>(context);
    _viewerSettingsBloc = BlocProvider.of<ViewerSettingsBloc>(context);
    _currentSpineItemBloc = BlocProvider.of<CurrentSpineItemBloc>(context);
    webViewHorizontalGestureRecognizer = WebViewHorizontalGestureRecognizer(
      chapNumber: position,
      webView: widget,
    );
    epubCallbacks = EpubCallbacks(
        _spineItemContext,
        _viewerSettingsBloc,
        readerContext.readerAnnotationRepository,
        webViewHorizontalGestureRecognizer);
  }

  @override
  void dispose() {
    super.dispose();
    widget.widgetKeepAliveListener.unregister(position);
    _spineItemContext.dispose();
    _annotationsSubscription?.cancel();
    _readerThemeSubscription?.cancel();
    _viewerSettingsSubscription?.cancel();
    _currentSpineItemSubscription?.cancel();
    _readerCommandSubscription?.cancel();
    _paginationInfoSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    widget.widgetKeepAliveListener.register(position, this);
    currentSelectedSpineItem = false;
    print(
        '=== INITIAL URL: ${widget.address}/${spineItem.href.removePrefix("/")}');
    return buildWebView(spineItem);
  }

  Widget buildWebView(Link link) => SpineItemContextWidget(
        spineItemContext: _spineItemContext,
        child: buildWebViewComponent(link),
      );

  Widget buildWebViewComponent(Link link) => isLoaded
      ? WebView(
          debuggingEnabled: true,
          initialUrl: '${widget.address}/${link.href.removePrefix("/")}',
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: epubCallbacks.channels,
          navigationDelegate: _navigationDelegate,
          onPageFinished: _onPageFinished,
          gestureRecognizers: {
            Factory(() => webViewHorizontalGestureRecognizer),
          },
          onWebViewCreated: _onWebViewCreated,
        )
      : const SizedBox.shrink();

//  @override
//  bool get wantKeepAlive {
//    int position = position;
//    WidgetKeepAliveListener widgetKeepAliveListener = widget._widgetKeepAliveListener;
//    if (widgetKeepAliveListener != null) {
//      bool keepAlive = (position - widgetKeepAliveListener.position).abs() < 2;
//      if (!keepAlive) {
//        widgetKeepAliveListener.unregister(position);
//      }
//      return keepAlive;
//    }
//    return true;
//  }

  void refreshPage() {
//    Fimber.d("refreshPage[${position}]: ${spineItem.href}");
  }

  NavigationDecision _navigationDelegate(NavigationRequest navigation) =>
      NavigationDecision.navigate;

  void _onPageFinished(String url) {
    Fimber.d("_onPageFinished[$position]: $url");
    ReaderThemeConfig theme = _readerThemeBloc.currentTheme;
    try {
      OpenPageRequest? openPageRequestData =
          _getOpenPageRequestFromCommand(readerContext.readerCommand);
      List<String> elementIds =
          readerContext.getElementIdsFromSpineItem(position);
      ViewerSettings settings = _viewerSettingsBloc.viewerSettings;
      _jsApi?.initSpineItem(
        publication,
        spineItem,
        settings,
        openPageRequestData,
        elementIds,
      );
      refreshPage();
      _jsApi?.setStyles(theme, settings);
      _updateSpineItemPosition(_currentSpineItemBloc.state);
      readerContext.readerAnnotationRepository
          .allWhere(
              predicate: AnnotationTypeAndDocumentPredicate(
                  spineItem.id!, AnnotationType.bookmark))
          .then((annotations) => _jsApi?.computeAnnotationsInfo(annotations));
      _annotationsSubscription = readerContext
          .readerAnnotationRepository.deletedIdsStream
          .listen((deletedIds) => _jsApi?.removeBookmarks(deletedIds));
    } catch (e, stacktrace) {
      Fimber.d("_onPageFinished ERROR", ex: e, stacktrace: stacktrace);
    }
  }

  void _onWebViewCreated(WebViewController webViewController) {
    JsApi jsApi = JsApi(position, webViewController.runJavascript);
    _jsApi = jsApi;
    _spineItemContext.jsApi = jsApi;
    epubCallbacks.jsApi = jsApi;
    _readerThemeSubscription =
        _readerThemeBloc.stream.listen(_onReaderThemeChanged);
    _viewerSettingsSubscription =
        _viewerSettingsBloc.stream.listen(_onViewerSettingsChanged);
    _currentSpineItemSubscription =
        _currentSpineItemBloc.stream.listen(_updateSpineItemPosition);
    _readerCommandSubscription =
        readerContext.commandsStream.listen(_onReaderCommand);
    _paginationInfoSubscription =
        _spineItemContext.paginationInfoStream.listen(_onPaginationInfo);
  }

  void _onReaderThemeChanged(ReaderThemeState state) {
    ViewerSettings settings = _viewerSettingsBloc.state.viewerSettings;
    _jsApi?.setStyles(state.readerTheme, settings);
  }

  void _onViewerSettingsChanged(ViewerSettingsState state) =>
      _jsApi?.updateFontSize(state.viewerSettings);

  void _updateSpineItemPosition(CurrentSpineItemState state) {
    this.currentSelectedSpineItem = state.spineItemIdx == position;
    _jsApi?.initPagination();
    if (state.spineItemIdx > position) {
      _jsApi?.navigateToEnd();
    } else if (state.spineItemIdx < position) {
      _jsApi?.navigateToStart();
    } else {
      _onPaginationInfo(_spineItemContext.currentPaginationInfo);
    }
  }

  void _onReaderCommand(ReaderCommand command) {
    OpenPageRequest? openPageRequestData =
        _getOpenPageRequestFromCommand(command);
    if (openPageRequestData != null) {
      _jsApi?.openPage(openPageRequestData);
    }
  }

  OpenPageRequest? _getOpenPageRequestFromCommand(ReaderCommand? command) {
    if (command != null && command.spineItemIndex == position) {
      readerContext.readerCommand = null;
      return command.openPageRequest;
    }
    return null;
  }

  void _onPaginationInfo(PaginationInfo? paginationInfo) {
    if (currentSelectedSpineItem && paginationInfo != null) {
      readerContext.notifyCurrentLocation(paginationInfo, spineItem);
      readerContext.currentSpineItemContext = _spineItemContext;
    }
  }
}
