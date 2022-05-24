// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/publication.dart';

Future<void> main() async {
  String passphrase = "passphrase";
  await Lcp.initLcp();
  LcpService? lcpService = await LcpServiceFactory.create(_LcpClientNative());
  if (lcpService != null) {
    ContentProtection contentProtection = lcpService.contentProtection(
        authentication: LcpPassphraseAuthentication(passphrase));
    print("contentProtection: $contentProtection");
  }
}

class _LcpClientNative extends LcpClient {
  @override
  bool get isAvailable => true;

  @override
  DrmContext createContext(
      String jsonLicense, String hashedPassphrases, String pemCrl) {
    throw DRMException(DRMError.contextInvalid);
  }

  @override
  ByteData decrypt(DrmContext drmContext, ByteData encryptedData) =>
      ByteData(0);

  @override
  String findOneValidPassphrase(
      String jsonLicense, List<String> hashedPassphrases) {
    if (hashedPassphrases.isNotEmpty) {
      return hashedPassphrases.first;
    }
    throw DRMException(DRMError.licenseNoPasshphraseMatched);
  }
}
