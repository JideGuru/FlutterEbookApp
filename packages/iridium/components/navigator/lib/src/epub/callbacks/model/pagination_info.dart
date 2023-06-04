// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:mno_shared/publication.dart';

class PaginationInfo {
  final Map<String, dynamic> json;
  final int spineItemIndex;
  final Locator locator;
  final Page openPage;
  final LinkPagination linkPagination;
  final Map<String, int> elementIdsWithPageIndex;

  PaginationInfo(this.json, this.spineItemIndex, this.locator, this.openPage,
      this.linkPagination, this.elementIdsWithPageIndex);

  static PaginationInfo fromJson(String jsonString, int spineItemIndex,
      Locator locator, LinkPagination linkPagination) {
    // debugPrint('\npaginating: \n$jsonString');
    Map<String, dynamic> json = const JsonCodec().decode(jsonString);
    Location location = _locationFromJson(json);
    Page openPage = _openPageFromJson(json);
    Map<String, int> elementIdsWithPageIndex =
        _elementIdsWithPageIndexFromJson(json);
    PaginationInfo paginationInfo = PaginationInfo(
        json,
        spineItemIndex,
        locator.copyWithLocations(progression: location.progression),
        openPage,
        linkPagination,
        elementIdsWithPageIndex);
    return paginationInfo;
  }

  int get percent {
    if (openPage.spineItemPageCount <= 1) {
      return 0;
    }
    return (100 * openPage.spineItemPageIndex) ~/
        (openPage.spineItemPageCount - 1);
  }

  int get page =>
      linkPagination.firstPageNumber +
      percent * (linkPagination.pagesCount - 1) ~/ 100;

  static Location _locationFromJson(Map<String, dynamic> json) {
    Map<String, dynamic> locationJson = json["location"];
    return Location(
        const JsonCodec().encode(locationJson),
        locationJson["cfi"],
        locationJson["elementCfi"],
        (locationJson["progression"] as num?)?.toDouble());
  }

  static Page _openPageFromJson(Map<String, dynamic> json) {
    Map<String, dynamic> openPage = json["openPage"];
    return Page(openPage["spineItemPageIndex"], openPage["spineItemPageCount"],
        openPage["spineItemPageThumbnailsCount"] ?? 1);
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

  @override
  String toString() => 'PaginationInfo{json: $json, '
      'page: $page, '
      'openPage: $openPage, '
      'linkPagination: $linkPagination}';
}

class Page {
  final int spineItemPageIndex;
  final int spineItemPageCount;
  final int spineItemPageThumbnailsCount;

  Page(this.spineItemPageIndex, this.spineItemPageCount,
      this.spineItemPageThumbnailsCount);

  @override
  String toString() => 'Page{spineItemPageIndex: $spineItemPageIndex, '
      'spineItemPageCount: $spineItemPageCount, '
      'spineItemPageThumbnailsCount: $spineItemPageThumbnailsCount}';
}

class Location {
  final String json;
  final String? cfi;
  final String? elementCfi;
  final double? progression;

  Location(this.json, this.cfi, this.elementCfi, this.progression);

  @override
  String toString() => 'Location{cfi: $cfi, '
      'elementCfi: $elementCfi, '
      'progression: $progression}';
}
