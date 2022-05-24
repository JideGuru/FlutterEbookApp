// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract class PassphrasesRepository {
  Future<String?> passphrase(String licenseId);

  Future<List<String>> passphrases(String userId);

  Future<List<String>> allPassphrases();

  void addPassphrase(String passphraseHash, String? licenseId, String? provider,
      String? userId);
}
