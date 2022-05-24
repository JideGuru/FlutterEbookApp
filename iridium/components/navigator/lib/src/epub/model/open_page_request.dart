// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:mno_commons/utils/jsonable.dart';

class OpenPageRequest implements JSONable {
  final String? idref;
  final int? spineItemPageIndex;
  final double? spineItemPercentage;
  final String? elementCfi;
  final String? contentRefUrl;
  final String? sourceFileHref;
  final String? elementId;
  final bool lastPage;
  final bool startTts;

  OpenPageRequest._(
      this.idref,
      this.spineItemPageIndex,
      this.spineItemPercentage,
      this.elementCfi,
      this.contentRefUrl,
      this.sourceFileHref,
      this.elementId,
      this.lastPage,
      this.startTts);

  OpenPageRequest.fromIdref(String idref)
      : this._(idref, 0, null, null, null, null, null, false, false);

  OpenPageRequest.fromIdrefAndIndex(String idref, int spineItemPageIndex)
      : this._(idref, spineItemPageIndex, null, null, null, null, null, false,
            false);

  OpenPageRequest.fromIdrefAndPercentage(
      String idref, double spineItemPercentage)
      : this._(idref, null, spineItemPercentage, null, null, null, null, false,
            false);

  OpenPageRequest.fromIdrefAndCfi(String idref, String elementCfi)
      : this._(idref, null, null, elementCfi, null, null, null, false, false);

  OpenPageRequest.fromContentUrl(String contentRefUrl, String sourceFileHref)
      : this._(null, null, null, null, contentRefUrl, sourceFileHref, null,
            false, false);

  OpenPageRequest.fromElementId(String idref, String? elementId)
      : this._(idref, null, null, null, null, null, elementId, false, false);

  OpenPageRequest.fromIdrefLastPage(String idref)
      : this._(idref, null, null, null, null, null, null, true, false);

  OpenPageRequest.fromIdrefAndLastPageWithTts(String idref,
      {bool lastPage = false})
      : this._(idref, null, null, null, null, null, null, lastPage, true);

  static OpenPageRequest fromJSON(String data) {
    Map<String, dynamic> json = const JsonCodec().decode(data);
    int spineItemPageIndex = json.containsKey("spineItemPageIndex")
        ? json["spineItemPageIndex"]
        : null;
    double spineItemPercentage = json.containsKey("spineItemPercentage")
        ? json["spineItemPercentage"]
        : null;
    String idref = json["idref"];
    // get elementCfi and then contentCFI (from bookmarkData) if it was empty
    String elementCfi = json["elementCfi"] ?? json["contentCFI"];
    String contentRefUrl = json["contentRefUrl"];
    String sourceFileHref = json["sourceFileHref"];
    String elementId = json["elementId"];
    bool lastPage = json["lastPage"] == true.toString();
    bool startTts = json["startTts"] == true.toString();
    return OpenPageRequest._(
        idref,
        spineItemPageIndex,
        spineItemPercentage,
        elementCfi,
        contentRefUrl,
        sourceFileHref,
        elementId,
        lastPage,
        startTts);
  }

  @override
  int get hashCode {
    const int prime = 31;
    int result = 1;
    result =
        prime * result + ((contentRefUrl == null) ? 0 : contentRefUrl.hashCode);
    result = prime * result + ((elementCfi == null) ? 0 : elementCfi.hashCode);
    result = prime * result + ((idref == null) ? 0 : idref.hashCode);
    result = prime * result +
        ((sourceFileHref == null) ? 0 : sourceFileHref.hashCode);
    result = prime * result +
        ((spineItemPageIndex == null) ? 0 : spineItemPageIndex.hashCode);
    result = prime * result +
        ((spineItemPercentage == null) ? 0 : spineItemPercentage.hashCode);
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (this == other) {
      return true;
    }
    if (other is OpenPageRequest) {
      if (contentRefUrl == null) {
        if (other.contentRefUrl != null) {
          return false;
        }
      } else if (contentRefUrl != other.contentRefUrl) {
        return false;
      }
      if (elementCfi == null) {
        if (other.elementCfi != null) {
          return false;
        }
      } else if (elementCfi != other.elementCfi) {
        return false;
      }
      if (idref == null) {
        if (other.idref != null) {
          return false;
        }
      } else if (idref != other.idref) {
        return false;
      }
      if (sourceFileHref == null) {
        if (other.sourceFileHref != null) {
          return false;
        }
      } else if (sourceFileHref != other.sourceFileHref) {
        return false;
      }
      if (spineItemPageIndex == null) {
        if (other.spineItemPageIndex != null) {
          return false;
        }
      } else if (spineItemPageIndex != other.spineItemPageIndex) {
        return false;
      } else if (spineItemPercentage != other.spineItemPercentage) {
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  String toString() => 'OpenPageRequest{'
      'idref: $idref, '
      'spineItemPageIndex: $spineItemPageIndex, '
      'spineItemPercentage: $spineItemPercentage, '
      'elementCfi: $elementCfi, '
      'contentRefUrl: $contentRefUrl, '
      'sourceFileHref: $sourceFileHref, '
      'elementId: $elementId, '
      'lastPage: $lastPage, '
      'startTts: $startTts'
      '}';

  @override
  Map<String, dynamic> toJson() => {
        'idref': idref,
        if (spineItemPageIndex != null)
          'spineItemPageIndex': spineItemPageIndex,
        if (spineItemPercentage != null)
          'spineItemPercentage': spineItemPercentage,
        if (elementCfi != null) 'elementCfi': elementCfi,
        if (contentRefUrl != null) 'contentRefUrl': contentRefUrl,
        if (sourceFileHref != null) 'sourceFileHref': sourceFileHref,
        if (elementId != null) 'elementId': elementId,
        'lastPage': lastPage,
        'startTts': startTts,
      };
}
