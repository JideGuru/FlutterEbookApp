// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';

class ReaderContextWidget extends InheritedWidget {
  final ReaderContext readerContext;

  const ReaderContextWidget({
    super.key,
    required super.child,
    required this.readerContext,
  });

  @override
  bool updateShouldNotify(ReaderContextWidget oldWidget) =>
      readerContext != oldWidget.readerContext;
}

class ReaderContext {
  static const Map<Type, ReaderCommandProcessor>
      _defaultReaderCommandProcessors = {
    GoToHrefCommand: GoToHrefCommandProcessor(),
    GoToLocationCommand: GoToLocationCommandProcessor(),
    GoToPageCommand: GoToPageCommandProcessor(),
  };
  final UserException? userException;
  final PublicationAsset asset;
  final MediaType mediaType;
  final Publication? publication;
  final String? location;
  final Map<int, SpineItemContext> spineItemContextMap;
  final ReaderAnnotationRepository readerAnnotationRepository;
  final bool displayEditAnnotationIcon;
  late List<Link> _tableOfContents;
  late List<Link> _flattenedTableOfContents;
  late Map<Link, int> _tableOfContentsToSpineItemIndex;
  late Map<Type, ReaderCommandProcessor> readerCommandProcessors;
  Link? currentSpineItem;
  SpineItemContext? currentSpineItemContext;
  SelectionListenerFactory selectionListenerFactory;

  ReadingProgression? readingProgression;

  Fetcher get fetcher => publication!.fetcher;

  List<Link> get tableOfContents => _tableOfContents;

  List<Link> get flattenedTableOfContents => _flattenedTableOfContents;

  Map<Link, int> get tableOfContentsToSpineItemIndex =>
      _tableOfContentsToSpineItemIndex;

  bool toolbarVisibility;
  final StreamController<bool> _toolbarStreamController =
      StreamController.broadcast();

  Stream<bool> get toolbarStream => _toolbarStreamController.stream;

  int _viewportWidth = 0;

  int get viewportWidth => _viewportWidth;

  set viewportWidth(int viewportWidth) {
    _viewportWidth = viewportWidth;
    _viewportWidthController.add(viewportWidth);
  }

  final StreamController<int> _viewportWidthController =
      StreamController.broadcast();

  Stream<int> get viewportWidthStream => _viewportWidthController.stream;

  ReaderCommand? readerCommand;

  /// [ReaderCommand]s Bus.
  final StreamController<ReaderCommand> _commandsStreamController =
      StreamController.broadcast();

  Stream<ReaderCommand> get commandsStream => _commandsStreamController.stream;

  PaginationInfo? paginationInfo;

  /// [PaginationInfo]s Bus.
  final StreamController<PaginationInfo> _currentLocationController =
      StreamController.broadcast();

  Stream<PaginationInfo> get currentLocationStream =>
      _currentLocationController.stream;

  ReaderContext({
    required this.userException,
    required this.asset,
    required this.mediaType,
    required this.publication,
    required this.location,
    required this.readerAnnotationRepository,
    required this.selectionListenerFactory,
    this.displayEditAnnotationIcon = true,
    Map<Type, ReaderCommandProcessor> readerCommandProcessorMap = const {},
  })  : assert(userException != null || publication != null),
        spineItemContextMap = {},
        toolbarVisibility = false {
    readerCommandProcessors = Map.of(_defaultReaderCommandProcessors)
      ..addAll(readerCommandProcessorMap);
    _tableOfContents = publication?.tableOfContents ?? [];
    _flattenedTableOfContents = TocUtils.flatten(_tableOfContents);
    _tableOfContentsToSpineItemIndex =
        TocUtils.mapTableOfContentToSpineItemIndex(
            publication, _flattenedTableOfContents);
    _toolbarStreamController.add(toolbarVisibility);
    currentSpineItem = publication?.readingOrder.firstOrNull;
    readerCommand = locator?.let((it) => GoToLocationCommand.locator(it));
    readingProgression = publication?.metadata.effectiveReadingProgression;
  }

  bool get hasError => userException != null;

  Locator? get locator => location?.let((it) => Locator.fromJsonString(it));

  int get currentPageNumber =>
      publication!.paginationInfo[currentSpineItem]?.firstPageNumber ?? 1;

  void dispose() {
    _toolbarStreamController.close();
    _commandsStreamController.close();
    _currentLocationController.close();
  }

  static ReaderContext? of(BuildContext context) {
    final ReaderContextWidget? readerContextWidget =
        context.dependOnInheritedWidgetOfExactType<ReaderContextWidget>();
    return readerContextWidget?.readerContext;
  }

  void onTap() {
    toolbarVisibility = !toolbarVisibility;
    _toolbarStreamController.add(toolbarVisibility);
  }

  void toggleBookmark() {
    PaginationInfo? paginationInfo = this.paginationInfo;
    if (paginationInfo != null) {
      readerAnnotationRepository.createBookmark(paginationInfo);
    }
  }

  List<String> getElementIdsFromSpineItem(int spineItemIndex) =>
      getTocItemsFromSpineItem(spineItemIndex)
          .map((link) => link.elementId)
          .whereNotNull()
          .toList();

  Iterable<Link> getTocItemsFromSpineItem(int spineItemIndex) {
    Link? spineItem = publication?.readingOrder.elementAtOrNull(spineItemIndex);
    return (spineItem != null)
        ? _flattenedTableOfContents
            .where((tocItem) => spineItem.href == tocItem.hrefPart)
        : const [];
  }

  void notifyCurrentLocation(PaginationInfo paginationInfo, Link spineItem) {
    this.paginationInfo = paginationInfo;
    this.currentSpineItem = spineItem;
    _currentLocationController.add(paginationInfo);
  }

  /// Sends the given [ReaderCommand] on the command bus, to be executed by the
  /// relevant component.
  void execute(ReaderCommand command) {
    // Fimber.d("command: $command");
    _updateSpineItemIndexForCommand(command);
    _createOpenPageRequestForCommand(command);
    this.readerCommand = command;
    // Fimber.d("readerCommand: $readerCommand");
    _commandsStreamController.add(command);
  }

  void _updateSpineItemIndexForCommand(ReaderCommand command) {
    Publication publication = this.publication!;
    ReaderCommandProcessor<ReaderCommand>? readerCommandProcessor =
        readerCommandProcessors[command.runtimeType];
    if (readerCommandProcessor != null) {
      command.spineItemIndex =
          readerCommandProcessor.findSpineItemIndex(command, publication);
    }
    if (command.spineItemIndex != null && command.spineItemIndex! >= 0) {
      currentSpineItem = publication.pageLinks[command.spineItemIndex!];
    }
  }

  void _createOpenPageRequestForCommand(ReaderCommand command) {
    OpenPageRequest? openPageRequestData;
    ReaderCommandProcessor<ReaderCommand>? readerCommandProcessor =
        readerCommandProcessors[command.runtimeType];
    if (readerCommandProcessor != null) {
      openPageRequestData =
          readerCommandProcessor.createOpenPageRequestForCommand(command);
    }
    command.openPageRequest = openPageRequestData;
  }
}
