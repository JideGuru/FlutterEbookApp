// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' hide Decoration;
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/widget/webview_screen_state.dart'
    if (dart.library.html) 'package:mno_navigator/src/epub/widget/webview_screen_state_stub.dart'
    if (dart.library.js) 'package:mno_navigator/src/epub/widget/webview_screen_state_stub.dart';
import 'package:mno_shared/publication.dart';

class WebViewScreen extends StatefulWidget {
  final Link link;
  final int position;
  final String address;
  final ReaderContext readerContext;
  final PublicationController publicationController;

  WebViewScreen(
      {required this.link,
      required this.position,
      required this.address,
      required this.readerContext,
      required this.publicationController})
      : super(key: PageStorageKey(link.id ?? link.href));

  @override
  State<StatefulWidget> createState() => WebViewScreenState();
}
