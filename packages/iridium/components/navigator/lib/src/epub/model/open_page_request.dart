// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/publication.dart';

class OpenPageRequest implements JSONable {
  final String? idref;
  final double? spineItemPercentage;
  final String? elementCfi;
  final String? elementId;
  final LocatorText? text;
  final bool lastPage;

  OpenPageRequest._(this.idref, this.spineItemPercentage, this.elementCfi,
      this.elementId, this.text, this.lastPage);

  OpenPageRequest.fromIdref(String idref)
      : this._(idref, null, null, null, null, false);

  OpenPageRequest.fromIdrefAndPercentage(
      String idref, double spineItemPercentage)
      : this._(idref, spineItemPercentage, null, null, null, false);

  OpenPageRequest.fromIdrefAndCfi(String idref, String elementCfi)
      : this._(idref, null, elementCfi, null, null, false);

  OpenPageRequest.fromElementId(String idref, String? elementId)
      : this._(idref, null, null, elementId, null, false);

  OpenPageRequest.fromIdrefAndLastPageWithTts(String idref,
      {bool lastPage = false})
      : this._(idref, null, null, null, null, lastPage);

  OpenPageRequest.fromText(String idref, LocatorText? text)
      : this._(idref, null, null, null, text, false);

  static OpenPageRequest fromJSON(String data) {
    Map<String, dynamic> json = const JsonCodec().decode(data);
    double spineItemPercentage = json.containsKey("spineItemPercentage")
        ? json["spineItemPercentage"]
        : null;
    String idref = json["idref"];
    // get elementCfi and then contentCFI (from bookmarkData) if it was empty
    String elementCfi = json["elementCfi"] ?? json["contentCFI"];
    String elementId = json["elementId"];
    bool lastPage = json["lastPage"] == true.toString();
    return OpenPageRequest._(
        idref, spineItemPercentage, elementCfi, elementId, null, lastPage);
  }

  @override
  int get hashCode {
    const int prime = 31;
    int result = 1;
    result = prime * result + ((elementCfi == null) ? 0 : elementCfi.hashCode);
    result = prime * result + ((idref == null) ? 0 : idref.hashCode);
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
      if (spineItemPercentage != other.spineItemPercentage) {
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  String toString() => 'OpenPageRequest{'
      'idref: $idref, '
      'spineItemPercentage: $spineItemPercentage, '
      'elementCfi: $elementCfi, '
      'elementId: $elementId, '
      'lastPage: $lastPage, '
      '}';

  @override
  Map<String, dynamic> toJson() => {
        'idref': idref,
        if (spineItemPercentage != null)
          'spineItemPercentage': spineItemPercentage,
        if (elementCfi != null) 'elementCfi': elementCfi,
        if (elementId != null) 'elementId': elementId,
        if (text != null) 'text': text,
        'lastPage': lastPage,
      };
}
