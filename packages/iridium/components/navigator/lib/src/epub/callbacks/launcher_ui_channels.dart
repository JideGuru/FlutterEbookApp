// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LauncherUIChannels extends JavascriptChannels {
  final SpineItemContext _spineItemContext;
  final ReaderAnnotationRepository? _bookmarkRepository;
  late JsApi jsApi;

  LauncherUIChannels(this._spineItemContext, this._bookmarkRepository);

  @override
  List<JavascriptChannel> get channels => [
        JavascriptChannel(
          name: "LauncherUIOnPaginationChanged",
          onMessageReceived: _onPaginationChanged,
        ),
        JavascriptChannel(
          name: "LauncherUIOnToggleBookmark",
          onMessageReceived: _onToggleBookmark,
        ),
        JavascriptChannel(
          name: "LauncherUIContentRefUrlsPageComputed",
          onMessageReceived: _contentRefUrlsPageComputed,
        ),
        JavascriptChannel(
          name: "LauncherUIImageZoomed",
          onMessageReceived: _imageZoomed,
        ),
        JavascriptChannel(
          name: "LauncherUIOpenSpineItemForTts",
          onMessageReceived: _openSpineItemForTts,
        ),
        JavascriptChannel(
          name: 'flutter_log',
          onMessageReceived: _flutterLog,
        ),
      ];

  void _onPaginationChanged(JavascriptMessage message) {
    // Fimber.d("onPaginationChanged: ${message.message}");
    try {
      PaginationInfo paginationInfo = PaginationInfo.fromJson(
          message.message, _spineItemContext.linkPagination);
      _spineItemContext.notifyPaginationInfo(paginationInfo);
    } on Object catch (e, stacktrace) {
      Fimber.d("onPaginationChanged error: $e, $stacktrace",
          ex: e, stacktrace: stacktrace);
    }
  }

  void _onToggleBookmark(JavascriptMessage message) {
    // Fimber.d("onToggleBookmark: ${message.message}");
    try {
      PaginationInfo paginationInfo = PaginationInfo.fromJson(
          message.message, _spineItemContext.linkPagination);
      if (paginationInfo.pageBookmarks.isNotEmpty) {
        _bookmarkRepository?.delete(paginationInfo.pageBookmarks);
        jsApi.removeBookmark(paginationInfo);
      } else {
        _bookmarkRepository
            ?.createReaderAnnotation(paginationInfo)
            .then((ReaderAnnotation bookmark) => jsApi.addBookmark(bookmark));
      }
    } on Object catch (e, stacktrace) {
      Fimber.d("onToggleBookmark error: $e, $stacktrace",
          ex: e, stacktrace: stacktrace);
    }
  }

  void _contentRefUrlsPageComputed(JavascriptMessage message) {
//    Fimber.d("contentRefUrlsPageComputed: ${message.message}");
    Map<String, dynamic> jsonMap = const JsonCodec().decode(message.message);
    Map<String, int> result =
        jsonMap.map((String key, dynamic value) => MapEntry(key, value as int));
    Fimber.d("contentRefUrlsPageComputed, result: $result");
  }

  void _imageZoomed(JavascriptMessage message) {
//    Fimber.d("imageZoomed, url: ${message.message}");
  }

  void _openSpineItemForTts(JavascriptMessage message) {
//    Fimber.d("openSpineItemForTts: ${message.message}");
    Map<String, dynamic> result = const JsonCodec().decode(message.message);
    String idref = result["idref"];
    bool lastPage = result["lastPage"] == true.toString();
    OpenPageRequest request =
        OpenPageRequest.fromIdrefAndLastPageWithTts(idref, lastPage: lastPage);
    Fimber.d("openSpineItemForTts, request: $request");
  }

  void _flutterLog(JavascriptMessage message) {
    Fimber.d(message.message);
  }
}
