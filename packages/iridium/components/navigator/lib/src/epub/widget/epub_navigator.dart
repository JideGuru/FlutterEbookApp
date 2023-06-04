// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:universal_io/io.dart' hide Link;

class EpubNavigator extends PublicationNavigator {
  final EpubController epubController;

  EpubNavigator({
    super.key,
    required super.waitingScreenBuilder,
    required super.displayErrorBuilder,
    required super.onReaderContextCreated,
    required super.wrapper,
    required this.epubController,
  }) : super(
          publicationController: epubController,
        );

  @override
  State<StatefulWidget> createState() => EpubNavigatorState();
}

class EpubNavigatorState extends PublicationNavigatorState<EpubNavigator> {
  EpubController get epubController => widget.epubController;

  double get verticalPadding =>
      MediaQuery.of(context).orientation == Orientation.portrait ? 40.0 : 20.0;

  @override
  EdgeInsets get readerPadding =>
      EdgeInsets.symmetric(vertical: verticalPadding);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) =>
                publicationController.currentSpineItemBloc,
          ),
          BlocProvider(
            create: (BuildContext context) => publicationController.serverBloc,
          ),
        ],
        child: super.build(context),
      );

  @override
  Widget buildReaderView(List<Link> spine, ServerStarted serverState) =>
      PreloadPageView.builder(
        controller: epubController.pageController,
        scrollDirection: Axis.horizontal,
        // TODO Currently, with Hybrid Composition activated, preloadPagesCount > 1 provides erratic behavior.
        // To investigate!
        // preloadPagesCount: min(spine.length, 2),
        preloadPagesCount: 1,
        onPageChanged: epubController.onPageChanged,
        physics: const AlwaysScrollableScrollPhysics(),
        reverse: readerContext?.readingProgression?.isReverseOrder() ?? false,
        itemCount: spine.length,
        itemBuilder: (context, position) =>
            (Platform.isAndroid || Platform.isIOS)
                ? WebViewScreen(
                    address: serverState.address,
                    link: spine[position],
                    position: position,
                    readerContext: readerContext!,
                    publicationController: epubController,
                  )
                : const SizedBox.shrink(),
      );
}
