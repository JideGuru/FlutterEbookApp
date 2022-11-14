// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mno_lcp/lcp.dart';

abstract class LcpClient {
  bool get isAvailable;

  String findOneValidPassphrase(
      String jsonLicense, List<String> hashedPassphrases);

  DrmContext createContext(
      String jsonLicense, String hashedPassphrases, String pemCrl);

  ByteData decrypt(DrmContext drmContext, ByteData encryptedData);
}
