// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Decoration;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_webview/webview.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/decoration.dart';
import 'package:mno_navigator/src/epub/extensions/decoration_change.dart';
import 'package:mno_navigator/src/epub/model/annotation_mark_template.dart';
import 'package:mno_navigator/src/epub/model/decoration_style_annotation_mark.dart';
import 'package:mno_navigator/src/publication/model/annotation_type_and_idref_predicate.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';

@protected
class WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey _webViewKey = GlobalKey();
  JsApi? _jsApi;
  late ServerBloc _serverBloc;
  late ReaderThemeBloc _readerThemeBloc;
  late ViewerSettingsBloc _viewerSettingsBloc;
  late CurrentSpineItemBloc _currentSpineItemBloc;
  late SpineItemContext _spineItemContext;
  late WebViewHorizontalGestureRecognizer webViewHorizontalGestureRecognizer;
  StreamSubscription<ReaderThemeState>? _readerThemeSubscription;
  StreamSubscription<ViewerSettingsState>? _viewerSettingsSubscription;
  StreamSubscription<CurrentSpineItemState>? _currentSpineItemSubscription;
  StreamSubscription<ReaderCommand>? _readerCommandSubscription;
  StreamSubscription<PaginationInfo>? _paginationInfoSubscription;
  late EpubCallbacks epubCallbacks;
  late bool currentSelectedSpineItem;
  late SelectionListener selectionListener;
  late StreamController<Selection?> selectionController;
  late StreamSubscription<Selection?> selectionSubscription;
  late StreamSubscription<ReaderAnnotation> bookmarkSubscription;
  late StreamSubscription<List<String>> deletedAnnotationIdsSubscription;
  late StreamSubscription<int> viewportWidthSubscription;

  bool isLoaded = false;

  InAppWebViewController? _controller;

  int get position => widget.position;

  Link get spineItem => widget.link;

  Locator get currentLocator => spineItem.toLocator();

  ReaderContext get readerContext => widget.readerContext;

  Publication get publication => readerContext.publication!;

  Offset webViewOffset() {
    RenderBox? renderBox =
        _webViewKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition (see https://pub.dev/packages/webview_flutter/versions/2.8.0)
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView(); // For Hybrid Composition C (faster) - Default on 3.0.0
    // if (Platform.isAndroid) WebView.platform = AndroidWebView(); // For Virtual Display (slower)
    // Fix for blank WebViews with 3.0.0 (https://github.com/flutter/flutter/issues/74626)
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      setState(() {
        isLoaded = true;
      });
    });
    LinkPagination linkPagination = publication.paginationInfo[spineItem]!;
    _spineItemContext = SpineItemContext(
      spineItemIndex: position,
      readerContext: readerContext,
      linkPagination: linkPagination,
    );
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    _readerThemeBloc = BlocProvider.of<ReaderThemeBloc>(context);
    _viewerSettingsBloc = BlocProvider.of<ViewerSettingsBloc>(context);
    _currentSpineItemBloc = BlocProvider.of<CurrentSpineItemBloc>(context);
    webViewHorizontalGestureRecognizer = WebViewHorizontalGestureRecognizer(
        chapNumber: position, link: spineItem, readerContext: readerContext);
    selectionListener =
        readerContext.selectionListenerFactory.create(readerContext, context);
    epubCallbacks = EpubCallbacks(
        _spineItemContext,
        _viewerSettingsBloc,
        readerContext.readerAnnotationRepository,
        webViewHorizontalGestureRecognizer,
        EpubWebViewListener(_spineItemContext, _viewerSettingsBloc,
            widget.publicationController,
            selectionListener: selectionListener,
            webViewOffset: webViewOffset));
    currentSelectedSpineItem = false;
    selectionController = StreamController.broadcast();
    selectionSubscription = selectionController.stream.listen((selection) {
      if (selection != null) {
        selectionListener.displayPopup(selection);
      }
    });
    bookmarkSubscription = readerContext
        .readerAnnotationRepository.bookmarkStream
        .listen((ReaderAnnotation bookmark) {
      if (bookmark.locator?.href == spineItem.href) {
        _spineItemContext.bookmarks.add(bookmark);
        readerContext.paginationInfo
            ?.let((paginationInfo) => _updateBookmarks(paginationInfo));
      }
    });
    deletedAnnotationIdsSubscription = readerContext
        .readerAnnotationRepository.deletedIdsStream
        .listen((List<String> deletedIds) {
      _jsApi?.deleteDecorations({
        HtmlDecorationTemplate.highlightGroup: deletedIds
            .map((id) => [
                  "$id-${HtmlDecorationTemplate.highlightSuffix}",
                  "$id-${HtmlDecorationTemplate.annotationSuffix}"
                ])
            .flatten()
            .toList(),
      });
      _spineItemContext.bookmarks
          .removeWhere((annotation) => deletedIds.contains(annotation.id));
      readerContext.paginationInfo
          ?.let((paginationInfo) => _updateBookmarks(paginationInfo));
    });
    viewportWidthSubscription = readerContext.viewportWidthStream
        .listen((viewportWidth) => _jsApi?.setViewportWidth(viewportWidth));
  }

  @override
  void dispose() {
    super.dispose();
    _spineItemContext.dispose();
    _readerThemeSubscription?.cancel();
    _viewerSettingsSubscription?.cancel();
    _currentSpineItemSubscription?.cancel();
    _readerCommandSubscription?.cancel();
    _paginationInfoSubscription?.cancel();
    bookmarkSubscription.cancel();
    viewportWidthSubscription.cancel();
    deletedAnnotationIdsSubscription.cancel();
    selectionSubscription.cancel();
    selectionController.close();
    selectionListener.hidePopup();
  }

  @override
  Widget build(BuildContext context) => buildWebView();

  Widget buildWebView() => SpineItemContextWidget(
        spineItemContext: _spineItemContext,
        child: buildWebViewComponent(spineItem),
      );

  Widget buildWebViewComponent(Link link) => isLoaded
      ? InAppWebView(
          key: _webViewKey,
          initialUrlRequest: URLRequest(
              url: Uri.parse(
                  '${widget.address}/${link.href.removePrefix("/")}')),
          initialOptions: InAppWebViewGroupOptions(
            android: AndroidInAppWebViewOptions(
              useHybridComposition: true,
              useShouldInterceptRequest: true,
              safeBrowsingEnabled: false,
              cacheMode: AndroidCacheMode.LOAD_NO_CACHE,
              disabledActionModeMenuItems:
                  AndroidActionModeMenuItem.MENU_ITEM_SHARE |
                      AndroidActionModeMenuItem.MENU_ITEM_WEB_SEARCH |
                      AndroidActionModeMenuItem.MENU_ITEM_PROCESS_TEXT,
            ),
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
              verticalScrollBarEnabled: false,
              horizontalScrollBarEnabled: false,
            ),
          ),
          onConsoleMessage: (InAppWebViewController controller,
              ConsoleMessage consoleMessage) {
            Fimber.d(
                "WebView[${consoleMessage.messageLevel}]: ${consoleMessage.message}");
          },
          androidShouldInterceptRequest: (InAppWebViewController controller,
              WebResourceRequest request) async {
            if (!_serverBloc.startHttpServer &&
                request.url.toString().startsWith(_serverBloc.address)) {
              _serverBloc
                  .onRequest(AndroidRequest(request))
                  .then((androidResponse) => androidResponse.response);
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async =>
              NavigationActionPolicy.ALLOW,
          onLoadStop: _onPageFinished,
          gestureRecognizers: {
            Factory<WebViewHorizontalGestureRecognizer>(
                () => webViewHorizontalGestureRecognizer),
            Factory<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer()),
          },
          contextMenu: ContextMenu(
            options:
                ContextMenuOptions(hideDefaultSystemContextMenuItems: true),
            onCreateContextMenu: (hitTestResult) async {
              _jsApi?.let((jsApi) async {
                Selection? selection =
                    await jsApi.getCurrentSelection(currentLocator);
                selection?.offset = webViewOffset();
                selectionController.add(selection);
              });
            },
            onHideContextMenu: () {
              selectionController.add(null);
            },
          ),
          onWebViewCreated: _onWebViewCreated,
        )
      : const SizedBox.shrink();

  void _onPageFinished(InAppWebViewController controller, Uri? url) async {
    // Fimber.d("_onPageFinished[$position]: $url");
    try {
      OpenPageRequest? openPageRequestData =
          _getOpenPageRequestFromCommand(readerContext.readerCommand);
      List<String> elementIds =
          readerContext.getElementIdsFromSpineItem(position);
      _jsApi?.setElementIds(elementIds);
      if (openPageRequestData != null) {
        _jsApi?.openPage(openPageRequestData);
      }
      _jsApi?.setStyles(_readerThemeBloc.state.readerTheme,
          _viewerSettingsBloc.viewerSettings);
      _updateSpineItemPosition(_currentSpineItemBloc.state);
      await _loadDecorations();
      await _loadBookmarks();
    } catch (e, stacktrace) {
      Fimber.d("_onPageFinished ERROR", ex: e, stacktrace: stacktrace);
    }
  }

  Future _loadDecorations() async {
    String activeId = "";
    List<ReaderAnnotation> highlights =
        await readerContext.readerAnnotationRepository.allWhere(
            predicate: AnnotationTypeAndDocumentPredicate(
                spineItem.href, AnnotationType.highlight));
    Map<String, List<Decoration>> decorators = {
      HtmlDecorationTemplate.highlightGroup: highlights.fold(
          [],
          (list, highlight) => list
            ..addAll(
                highlight.toDecorations(isActive: highlight.id == activeId)))
    };
    _jsApi?.registerDecorationTemplates(decorators);
  }

  void _onWebViewCreated(InAppWebViewController webViewController) async {
    await initJsHandlers(webViewController);
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

  Future initJsHandlers(InAppWebViewController webViewController) async {
    // Fimber.d("_onWebViewCreated: $webViewController");
    _controller = webViewController;
    HtmlDecorationTemplates decorationTemplates =
        HtmlDecorationTemplates.defaultTemplates();
    decorationTemplates.styles[DecorationStyleAnnotationMark] =
        await annotationMarkTemplate(
            displayIcon: readerContext.displayEditAnnotationIcon);
    _jsApi = JsApi(position, decorationTemplates, (javascript) {
      if (mounted) {
        return webViewController.evaluateJavascript(source: javascript);
      }
      return Future.value();
    });
    _spineItemContext.jsApi = _jsApi;
    for (MapEntry<String, HandlerCallback> entry
        in epubCallbacks.channels.entries) {
      // Fimber.d("========== Adding Handler: ${entry.key}");
      _controller?.addJavaScriptHandler(
          handlerName: entry.key, callback: entry.value);
    }
    epubCallbacks.jsApi = _jsApi!;
    _paginationInfoSubscription =
        _spineItemContext.paginationInfoStream.listen(_onPaginationInfo);
  }

  void _onReaderThemeChanged(ReaderThemeState state) {
    ViewerSettings settings = _viewerSettingsBloc.state.viewerSettings;
    _jsApi?.setStyles(state.readerTheme, settings);
  }

  void _onViewerSettingsChanged(ViewerSettingsState state) {
    _jsApi?.updateFontSize(state.viewerSettings);
    _jsApi?.updateScrollSnapStop(state.viewerSettings.scrollSnapShouldStop);
  }

  void _updateSpineItemPosition(CurrentSpineItemState state) {
    this.currentSelectedSpineItem = state.spineItemIdx == position;
    _jsApi?.initPagination();
    if (state.spineItemIdx > position) {
      _jsApi?.navigateToEnd();
      _jsApi?.clearSelection();
    } else if (state.spineItemIdx < position) {
      _jsApi?.navigateToStart();
      _jsApi?.clearSelection();
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
      _updateBookmarks(paginationInfo);
      readerContext.notifyCurrentLocation(paginationInfo, spineItem);
      readerContext.currentSpineItemContext = _spineItemContext;
    }
  }

  void _updateBookmarks(PaginationInfo paginationInfo) {
    int nbColumns = paginationInfo.openPage.spineItemPageCount;
    Set<int> bookmarkIndexes = _spineItemContext.getBookmarkIndexes(nbColumns);
    _jsApi?.setBookmarkIndexes(bookmarkIndexes);
  }

  Future<void> _loadBookmarks() async {
    _spineItemContext.bookmarks.addAll(
        await readerContext.readerAnnotationRepository.allWhere(
            predicate: AnnotationTypeAndDocumentPredicate(
                spineItem.href, AnnotationType.bookmark)));
    _jsApi?.initPagination();
  }
}
