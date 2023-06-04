// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';

abstract class PublicationController extends NavigationController {
  final Function onServerClosed;
  final Function? onPageJump;
  final Future<String?> locationFuture;
  final PublicationAsset publicationAsset;
  final Future<Streamer> streamerFuture;
  final ReaderAnnotationRepository readerAnnotationRepository;
  final Function0<List<RequestHandler>> handlersProvider;
  final ServerBloc serverBloc;
  final CurrentSpineItemBloc currentSpineItemBloc;
  final SelectionListenerFactory selectionListenerFactory;
  final bool displayEditAnnotationIcon;
  ReaderContext? readerContext;

  StreamSubscription<ReaderCommand>? readerCommandSubscription;

  PublicationController(
    this.onServerClosed,
    this.onPageJump,
    this.locationFuture,
    this.publicationAsset,
    this.streamerFuture,
    this.readerAnnotationRepository,
    this.handlersProvider,
    this.selectionListenerFactory, [
    bool startHttpServer = true,
    this.displayEditAnnotationIcon = true,
  ])  : serverBloc = ServerBloc(startHttpServer: startHttpServer),
        currentSpineItemBloc = CurrentSpineItemBloc();

  void init() {
    serverBloc.stream.listen((ServerState state) {
      if (state is ServerStarted) {
        _onServerStarted(readerContext!);
      }
      if (state is ServerClosed) {
        onServerClosed();
      }
    });
  }

  String get serverAddress => serverBloc.address;

  void startServer() {
    if (!serverBloc.isClosed) {
      serverBloc.add(StartServer(handlersProvider()));
    }
  }

  void stopServer() {
    if (!serverBloc.isClosed) {
      serverBloc.add(ShutdownServer());
    }
  }

  Publication get publication => readerContext!.publication!;

  Future<ReaderContext> createReaderContext(BuildContext context) async {
    UserException? userException;
    Publication? publication;
    try {
      Streamer streamer = await streamerFuture;
      PublicationTry<Publication> publicationResult = await streamer
          .open(publicationAsset, true, sender: context)
          .onError((error, stackTrace) {
        if (error is UserException) {
          return PublicationTry.failure(error);
        }
        return PublicationTry.failure(OpeningException.unsupportedFormat);
      });
      publication = publicationResult.onFailure((ex) {
        userException = ex;
      }).getOrNull();
    } on UserException catch (ex) {
      userException = ex;
    }
    String? location = await locationFuture;
    return ReaderContext(
      userException: userException,
      asset: publicationAsset,
      mediaType: await publicationAsset.mediaType,
      publication: publication,
      location: location,
      readerAnnotationRepository: readerAnnotationRepository,
      selectionListenerFactory: selectionListenerFactory,
      displayEditAnnotationIcon: displayEditAnnotationIcon,
    );
  }

  void initReaderContext(ReaderContext readerContext) {
    this.readerContext = readerContext;
    int initialPage =
        readerContext.locator?.let((it) => _initPageFromLocation(it)) ?? 0;
    initPageController(initialPage);
    onPageChanged(initialPage);
  }

  int _initPageFromLocation(Locator locator) {
    int? page = publication.readingOrder.indexOfFirstWithHref(locator.href) ??
        publication.pageList.indexOfFirstWithHref(locator.href);
    return max(0, page ?? -1);
  }

  void jumpToPage(int page);

  bool get pageControllerAttached;

  void initPageController(int initialPage);

  void onPageChanged(int position) =>
      currentSpineItemBloc.add(CurrentSpineItemEvent(position));

  void _onServerStarted(ReaderContext readerContext) {
    readerCommandSubscription?.cancel();
    readerCommandSubscription =
        readerContext.commandsStream.listen(_onReaderCommand);
    readerContext.locator
        ?.let((it) => readerContext.execute(GoToLocationCommand.locator(it)));
  }

  void _onReaderCommand(ReaderCommand command) {
    if (pageControllerAttached && command.spineItemIndex != null) {
      jumpToPage(command.spineItemIndex!);
      onPageJump?.call();
    }
  }
}
