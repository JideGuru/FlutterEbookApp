// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_navigator/epub.dart';
import 'package:mno_shared/publication.dart';

abstract class ReaderCommand {
  int? spineItemIndex;
  OpenPageRequest? openPageRequest;
}

class GoToHrefCommand extends ReaderCommand {
  final String href;
  final String? fragment;

  GoToHrefCommand(this.href, this.fragment);

  @override
  String toString() => '$runtimeType{href: $href, fragment: $fragment, '
      'spineItemIndex: $spineItemIndex, openPageRequest: $openPageRequest}';
}

class GoToLocationCommand extends ReaderCommand {
  final String location;
  final Locator locator;

  GoToLocationCommand(this.location)
      : locator = Locator.fromJsonString(location)!;

  GoToLocationCommand.locator(this.locator) : location = locator.toString();

  @override
  String toString() => '$runtimeType{location: $location, '
      'spineItemIndex: $spineItemIndex, openPageRequest: $openPageRequest}';
}

class GoToPageCommand extends ReaderCommand {
  final int page;
  String? href;
  int? percent;

  GoToPageCommand(this.page);

  /// percent value between 0.0 and 1.0
  double get normalizedPercent => percent! / 100;

  @override
  String toString() => '$runtimeType{href: $href, page: $page, '
      'spineItemIndex: $spineItemIndex, openPageRequest: $openPageRequest}';
}
