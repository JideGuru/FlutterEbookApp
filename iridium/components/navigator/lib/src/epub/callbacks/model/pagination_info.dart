// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:mno_shared/publication.dart';

class PaginationInfo {
  final Map<String, dynamic> json;
  final String pageProgressionDirection;
  final bool isFixedLayout;
  final bool refreshAnnotations;
  final int spineItemCount;
  final int pageOffset;
  final int columnWidth;
  final SpineItem spineItem;
  final Location location;
  final List<String> pageBookmarks = [];
  final List<Page> openPages = [];
  final Map<String, int> elementIdsWithPageIndex;
  final LinkPagination linkPagination;

  PaginationInfo(
      this.json,
      this.pageProgressionDirection,
      this.isFixedLayout,
      this.refreshAnnotations,
      this.spineItemCount,
      this.pageOffset,
      this.columnWidth,
      this.spineItem,
      this.location,
      this.elementIdsWithPageIndex,
      this.linkPagination);

  static PaginationInfo fromJson(
      String jsonString, LinkPagination linkPagination) {
    Map<String, dynamic> json = const JsonCodec().decode(jsonString);
    SpineItem spineItem = _spineItemFromJson(json);
    Location location = _locationFromJson(json);
    Map<String, int> elementIdsWithPageIndex =
        _elementIdsWithPageIndexFromJson(json);
    PaginationInfo paginationInfo = PaginationInfo(
        json,
        json["pageProgressionDirection"] ?? "ltr",
        json["isFixedLayout"] == true.toString(),
        json["refreshAnnotations"] == true.toString(),
        json["spineItemCount"],
        json["pageOffset"],
        json["columnWidth"],
        spineItem,
        location,
        elementIdsWithPageIndex,
        linkPagination);
    List<dynamic> pageBookmarks = json["pageBookmarks"] ?? [];
    paginationInfo.pageBookmarks.addAll(pageBookmarks.map((s) => s.toString()));
    List<dynamic> openPages = json["openPages"] ?? [];
    for (Map<String, dynamic> p in openPages) {
      Page page = Page(
          p["spineItemPageIndex"],
          p["spineItemPageCount"],
          p["spineItemPageThumbnailsCount"] ?? 1,
          p["idref"],
          p["spineItemIndex"],
          p["pageNumber"]);
      paginationInfo.addPage(page);
    }
    return paginationInfo;
  }

  int get percent {
    if (openPages.isEmpty || openPages.first.spineItemPageCount <= 1) {
      return 0;
    }
    return (100 * openPages.first.spineItemPageIndex) ~/
        (openPages.first.spineItemPageCount - 1);
  }

  int get page =>
      linkPagination.firstPageNumber +
      percent * (linkPagination.pagesCount - 1) ~/ 100;

  static SpineItem _spineItemFromJson(Map<String, dynamic> json) {
    Map<String, dynamic> spineItemJson = json["spineItem"];
    return SpineItem(spineItemJson["idref"], spineItemJson["href"]);
  }

  static Location _locationFromJson(Map<String, dynamic> json) {
    Map<String, dynamic> locationJson = json["location"];
    return Location(
        const JsonCodec().encode(locationJson),
        locationJson["version"] as int,
        locationJson["cfi"],
        locationJson["elementCfi"]);
  }

  static Map<String, int> _elementIdsWithPageIndexFromJson(
      Map<String, dynamic> json) {
    Map<String, dynamic>? elementIdsWithPageIndexJson =
        json["elementIdsWithPageIndex"];
    if (elementIdsWithPageIndexJson != null) {
      return elementIdsWithPageIndexJson
          .map((key, value) => MapEntry(key, int.parse(value.toString())));
    }
    return {};
  }

  String? getString(String name) =>
      json.containsKey(name) ? json[name].toString() : null;

  void addPage(Page page) {
    openPages.add(page);
  }

  @override
  String toString() =>
      'PaginationInfo{json: $json, pageProgressionDirection: $pageProgressionDirection, '
      'isFixedLayout: $isFixedLayout, refreshAnnotations: $refreshAnnotations, '
      'spineItemCount: $spineItemCount, pageOffset: $pageOffset, '
      'columnWidth: $columnWidth, pageBookmarks: $pageBookmarks,'
      'page: $page, openPages: $openPages, '
      'elementIdsWithPageIndex: $elementIdsWithPageIndex, '
      'linkPagination: $linkPagination}';
}

class SpineItem {
  final String idref;
  final String href;

  SpineItem(this.idref, this.href);

  @override
  String toString() => 'SpineItem{idref: $idref, href: $href}';
}

class Page {
  final int spineItemPageIndex;
  final int spineItemPageCount;
  final int spineItemPageThumbnailsCount;
  final String idref;
  final int spineItemIndex;
  final int? pageNumber;

  Page(
      this.spineItemPageIndex,
      this.spineItemPageCount,
      this.spineItemPageThumbnailsCount,
      this.idref,
      this.spineItemIndex,
      this.pageNumber);

  @override
  String toString() =>
      'Page{spineItemPageIndex: $spineItemPageIndex, spineItemPageCount: $spineItemPageCount, '
      'spineItemPageThumbnailsCount: $spineItemPageThumbnailsCount, idref: $idref, '
      'spineItemIndex: $spineItemIndex, pageNumber: $pageNumber}';
}

class Location {
  final int version;
  final String json;
  final String cfi;
  final String elementCfi;

  Location(this.json, this.version, this.cfi, this.elementCfi);

  @override
  String toString() =>
      'Location{version: $version, cfi: $cfi, elementCfi: $elementCfi}';
}
