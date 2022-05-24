// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dfunc/dfunc.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/publication.dart';

class JsApi {
  final int index;
  final Function _jsLoader;

  JsApi(this.index, this._jsLoader);

  void loadJS(String jScript) {
    // Fimber.d("loadJS[$index]: $jScript");
    _jsLoader("javascript:(function(){if (xpub) { $jScript }})()");
  }

  void initSpineItem(
      Publication publication,
      Link link,
      ViewerSettings viewerSettings,
      OpenPageRequest? openPageRequestData,
      List<String> elementIds,
      {ScreenshotConfig? screenshotConfig}) {
    Link? previousSpineItem = getPreviousSpineItem(publication, link);
    Link? nextSpineItem = getNextSpineItem(publication, link);

    Map<String, dynamic> openBookData = {
      'package': publicationToJson(publication, link),
      'spineItem': spineItemToJson(publication, link),
      if (previousSpineItem != null)
        'previousSpineItem': spineItemToJson(publication, previousSpineItem),
      if (nextSpineItem != null)
        'nextSpineItem': spineItemToJson(publication, nextSpineItem),
      'settings': viewerSettings.toJson(),
      if (openPageRequestData != null)
        'openPageRequest': openPageRequestData.toJson(),
      if (screenshotConfig != null)
        'screenshotConfig': screenshotConfig.toJson(),
      if (elementIds.isNotEmpty) 'elementIds': elementIds,
    };
    loadJS("xpub.initSpineItem(${const JsonCodec().encode(openBookData)});");
  }

  void openPage(OpenPageRequest openPageRequestData) => loadJS(
      "xpub.navigation.openPage(${const JsonCodec().encode(openPageRequestData.toJson())});");

  void setStyles(ReaderThemeConfig readerTheme, ViewerSettings viewerSettings) {
    if (!hasNoStyle()) {
      ReadiumThemeValues values =
          ReadiumThemeValues(readerTheme, viewerSettings);
      values.cssVarsAndValues.forEach((key, value) {
        loadJS("xpub.theme.updateProperty('$key', '$value');");
      });
      loadJS("xpub.theme.setVerticalMargin(${values.verticalMarginInt});");
      initPagination();
    }
  }

  void updateFontSize(ViewerSettings viewerSettings) {
    loadJS(
        "xpub.theme.updateProperty('--USER__fontSize', '${viewerSettings.fontSize}%');");
    initPagination();
  }

  void initPagination() {
    loadJS("xpub.initPagination();");
  }

  void navigateToStart() {
    loadJS("xpub.navigateToStart();");
  }

  void navigateToEnd() {
    loadJS("xpub.navigateToEnd();");
  }

  bool hasNoStyle() => false;

  Link? getPreviousSpineItem(Publication publication, Link link) {
    List<Link> spine = publication.readingOrder;
    int spineItemIdx = spine.indexOf(link);
    return spineItemIdx > 0 ? spine[spineItemIdx - 1] : null;
  }

  Link? getNextSpineItem(Publication publication, Link link) {
    List<Link> spine = publication.readingOrder;
    int spineItemIdx = spine.indexOf(link);
    return spineItemIdx < spine.length - 1 ? spine[spineItemIdx + 1] : null;
  }

  void gotoPrevPage() => loadJS("xpub.openPagePrev();");

  void gotoNextPage() => loadJS("xpub.openPageNext();");

  void computeAnnotationsInfo(List<ReaderAnnotation> bookmarkList) {
    for (ReaderAnnotation bookmark in bookmarkList) {
      computeAnnotationInfo(bookmark);
    }
    _triggerOnPaginationChanged();
  }

  void computeAnnotationInfo(ReaderAnnotation bookmark) {
    ReadiumLocation location =
        ReadiumLocation.createLocation(bookmark.location);
    if (bookmark.isHighlight) {
      loadJS(
          "xpub.highlight.computeBoxesForCfi('${location.idref}', '${bookmark.id}', '${location.contentCFI}');");
    } else if (bookmark.isBookmark) {
      addBookmark(bookmark);
    }
  }

  void toggleBookmark() {
    loadJS("xpub.navigation.toggleBookmark();");
  }

  void addBookmark(ReaderAnnotation annotation) {
    loadJS(
        "xpub.bookmarks.addBookmark('${annotation.id}', ${annotation.location});");
  }

  void removeBookmark(PaginationInfo paginationInfo) =>
      removeBookmarks(paginationInfo.pageBookmarks);

  void removeBookmarks(Iterable<String> bookmarkIds) {
    if (bookmarkIds.isNotEmpty) {
      loadJS(
          "xpub.bookmarks.removeBookmarks(${const JsonCodec().encode(bookmarkIds)});");
    }
  }

  void _triggerOnPaginationChanged() =>
      loadJS("xpub.triggerOnPaginationChanged();");

  Map<String, dynamic> publicationToJson(Publication publication, Link link) =>
      {
        'rootUrl': '',
        'rootUrlMO': '',
        'rendition_layout':
            epubLayoutToJson(publication.metadata.presentation.layoutOf(link)),
        'rendition_flow':
            renditionOverflowToJson(publication.metadata.presentation),
        'rendition_orientation': renditionOrientationToJson(
            publication.metadata.presentation.orientation),
        'rendition_spread':
            renditionSpreadToJson(publication.metadata.presentation.spread),
        // FIXME: pagesCount
//        'pagesCount':
        'direction':
            readingProgressionToJson(publication.metadata.readingProgression),
        'spineItemCount': publication.readingOrder.length,
      };

  Map<String, dynamic> spineItemToJson(Publication publication, Link link) => {
        'index': publication.readingOrder.indexOf(link),
        'href': link.href,
        'media_type': link.type,
        if (publication.metadata.presentation.spread != PresentationSpread.none)
          'page_spread': pageToJson(link.properties.page),
        'idref': link.id,
        'rendition_layout':
            epubLayoutToJson(publication.metadata.presentation.layoutOf(link)),
        'rendition_flow':
            renditionOverflowToJson(publication.metadata.presentation),
        'rendition_orientation': renditionOrientationToJson(
            publication.metadata.presentation.orientation),
        'rendition_spread':
            renditionSpreadToJson(publication.metadata.presentation.spread),
        'linear': 'yes',
        // FIXME: pagesCount and firstPageNumber
//        'pagesCount': link.pagesCount,
//        'firstPageNumber': link.firstPageNumber,
        'media_overlay_id': '',
      };

  String? epubLayoutToJson(EpubLayout layout) {
    if (layout == EpubLayout.fixed) {
      return 'pre-paginated';
    } else if (layout == EpubLayout.reflowable) {
      return 'reflowable';
    }
    return null;
  }

  String? renditionOverflowToJson(Presentation presentation) {
    if (presentation.overflow == PresentationOverflow.auto) {
      return 'auto';
    } else if (presentation.overflow == PresentationOverflow.paginated) {
      return 'paginated';
    } else if (presentation.overflow == PresentationOverflow.scrolled) {
      return presentation.continuous == true ? 'continuous' : 'document';
    }
    return null;
  }

  String? renditionOrientationToJson(PresentationOrientation? orientation) =>
      orientation?.value;

  String? renditionSpreadToJson(PresentationSpread? spread) => spread?.value;

  String? pageToJson(PresentationPage? page) =>
      page?.value.let((it) => 'page-spread-$it');

  String readingProgressionToJson(ReadingProgression progression) =>
      progression.value;
}
