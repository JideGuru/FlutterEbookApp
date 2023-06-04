// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_server/src/blocs/server/html_injector.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

/// Serves the resources of a [Publication] [Fetcher] from a [ServerBloc].
class FetcherRequestHandler extends RequestHandler {
  /// The [publication] where to find the resource
  final Publication publication;
  final ValueGetter<int> viewportWidthGetter;
  final HtmlInjector _htmlInjector;

  /// Creates an instance of [FetcherRequestHandler] for a [publication].
  ///
  /// A [transformData] parameter is optional.
  FetcherRequestHandler(this.publication, this.viewportWidthGetter,
      {List<String> googleFonts = const []})
      : _htmlInjector = HtmlInjector(publication, viewportWidthGetter,
            googleFonts: googleFonts);

  Fetcher get _fetcher => publication.fetcher;

  @override
  Future<bool> handle(int requestId, Request request, String href) async {
    Link? link = publication.linkWithHref(href);
    if (link == null) {
      return false;
    }
    Resource resource = _fetcher.get(link);
    if (!(await _exist(resource))) {
      return false;
    }

    await sendResource(
      request,
      resource: _htmlInjector.transform(resource),
      mediaType: link.mediaType,
    );

    return true;
  }

  Future<bool> _exist(Resource resource) async =>
      (await resource.length()).isSuccess;
}
