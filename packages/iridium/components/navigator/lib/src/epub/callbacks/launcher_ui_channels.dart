// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:mno_navigator/epub.dart';

class LauncherUIChannels extends JavascriptChannels {
  late JsApi jsApi;

  LauncherUIChannels();

  @override
  Map<String, HandlerCallback> get channels => {
        "LauncherUIContentRefUrlsPageComputed": _contentRefUrlsPageComputed,
        "LauncherUIImageZoomed": _imageZoomed,
        "LauncherUIOpenSpineItemForTts": _openSpineItemForTts,
      };

  void _contentRefUrlsPageComputed(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
//    Fimber.d("contentRefUrlsPageComputed: ${arguments.first}");
      Map<String, dynamic> jsonMap = const JsonCodec().decode(arguments.first);
      Map<String, int> result = jsonMap
          .map((String key, dynamic value) => MapEntry(key, value as int));
      Fimber.d("contentRefUrlsPageComputed, result: $result");
    }
  }

  void _imageZoomed(List<dynamic> arguments) {
//    Fimber.d("imageZoomed, url: ${arguments.first}");
  }

  void _openSpineItemForTts(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
//    Fimber.d("openSpineItemForTts: ${arguments.first}");
      Map<String, dynamic> result = const JsonCodec().decode(arguments.first);
      String idref = result["idref"];
      bool lastPage = result["lastPage"] == true.toString();
      OpenPageRequest request = OpenPageRequest.fromIdrefAndLastPageWithTts(
          idref,
          lastPage: lastPage);
      Fimber.d("openSpineItemForTts, request: $request");
    }
  }
}
