// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_commons/utils/functions.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:preload_page_view/preload_page_view.dart';

class EpubNavigator extends PublicationNavigator {
  final EpubController epubController;

  EpubNavigator({
    Key? key,
    required WidgetBuilder waitingScreenBuilder,
    required WidgetErrorBuilder displayErrorBuilder,
    required Consumer<ReaderContext> onReaderContextCreated,
    required WrapperWidgetBuilder? wrapper,
    required this.epubController,
  }) : super(
          key: key,
          waitingScreenBuilder: waitingScreenBuilder,
          displayErrorBuilder: displayErrorBuilder,
          onReaderContextCreated: onReaderContextCreated,
          wrapper: wrapper,
          publicationController: epubController,
        );

  @override
  State<StatefulWidget> createState() => EpubNavigatorState();
}

class EpubNavigatorState extends PublicationNavigatorState<EpubNavigator> {
  EpubController get epubController => widget.epubController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<CurrentSpineItemBloc>(
        create: (BuildContext context) =>
            publicationController.currentSpineItemBloc,
        child: super.build(context),
      );

  @override
  Widget buildReaderView(List<Link> spine, ServerStarted serverState) =>
      PreloadPageView.builder(
        controller: epubController.pageController,
        scrollDirection: Axis.horizontal,
        // TODO Currently, with Hybrid Composition activated, preloadPagesCount > 1 provides erratic behavior.
        // To investigate!
        // preloadPagesCount: Platform.isAndroid ? 2 : 1,
        preloadPagesCount: 1,
        onPageChanged: epubController.onPageChanged,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: spine.length,
        itemBuilder: (context, position) => WebViewScreen(
          widgetKeepAliveListener: epubController.widgetKeepAliveListener,
          // book: book,
          address: serverState.address,
          link: spine[position],
          position: position,
          readerContext: readerContext!,
        ),
      );
}
