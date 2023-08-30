// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/mediatype/mediatype.dart';
import 'package:mno_shared/src/publication/epub/publication.dart';

class PaginationInfosService {
  // we consider that a page is usually made of 3500 bytes
  static const int _pageSize = 3500;

  static Future<(int, Map<Link, LinkPagination>)>
      computePaginationInfos(Publication publication) async {
    Map<Link, LinkPagination> paginationInfos = {};
    int currentPage = 1;
    for (Link link in publication.pageLinks) {
      int nbPages = await computeResourcePages(publication, link);
      paginationInfos[link] = LinkPagination(currentPage, nbPages);
      currentPage += nbPages;
    }
    int nbPages = max(1, currentPage - 1);
    return (nbPages, paginationInfos);
  }

  static Future<int> computeResourcePages(
      Publication publication, Link link) async {
    MediaType mediaType = link.mediaType;
    if (mediaType.isBitmap || mediaType == MediaType.pdf) {
      return 1;
    }
    int length = (await publication.fetcher.get(link).length())
        .getOrElse((failure) => 0);
    int res = (length / _pageSize).ceil();
    return res;
  }
}

extension PageLinksPublication on Publication {
  List<Link> get pageLinks {
    if (readingOrder.length == 1 &&
        readingOrder.firstOrNull?.mediaType == MediaType.pdf) {
      return pageList;
    }
    return readingOrder;
  }
}
