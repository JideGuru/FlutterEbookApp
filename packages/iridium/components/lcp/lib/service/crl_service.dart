// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:mno_commons/utils/try.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrlService {
  static const int expiration = 7;
  static const String crlKey = "org.readium.r2-lcp-swift.CRL";
  static const String dateKey = "org.readium.r2-lcp-swift.CRLDate";
  static const String edrlabCaUrl =
      "http://crl.edrlab.telesec.de/rl/EDRLab_CA.crl";
  final NetworkService network;
  final SharedPreferences preferences;

  CrlService(this.network, this.preferences);

  Future<String> retrieve() async {
    _CrlStatus status = _readLocal();
    if (status.crl != null && !status.expired) {
      return status.crl!;
    }
    return _fetch().then((crl) => _saveLocal(crl)).onError((error, stackTrace) {
      if (status.crl != null) {
        return status.crl!;
      }
      throw error!;
    });
  }

  Future<String> _fetch() async {
    Try<ByteData, NetworkException> data =
        await network.fetch(edrlabCaUrl, method: Method.get);
    if (data.isFailure) {
      throw LcpException.crlFetching;
    }
    return "-----BEGIN X509 CRL-----${const Base64Encoder().convert(data.success!.buffer.asUint8List())}-----END X509 CRL-----";
  }

  // Returns (CRL, expired)
  _CrlStatus _readLocal() {
    String? crl = preferences.getString(crlKey);
    String? dateStr = preferences.getString(dateKey);
    DateTime? date;
    if (dateStr != null) {
      date = DateTime.parse(dateStr);
    }
    bool expired = (date != null) ? _daysSince(date) >= expiration : true;
    return _CrlStatus(crl, expired);
  }

  String _saveLocal(String crl) {
    preferences.setString(crlKey, crl);
    preferences.setString(dateKey, DateTime.now().toIso8601String());
    return crl;
  }

  int _daysSince(DateTime date) => DateTime.now().difference(date).inDays;
}

class _CrlStatus {
  final String? crl;
  final bool expired;

  _CrlStatus(this.crl, this.expired);
}
