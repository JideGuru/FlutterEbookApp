// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';

/// An [LcpAuthenticating] implementation which can directly use a provided clear or hashed
/// passphrase.
///
/// If the provided [passphrase] is incorrect, the given [fallback] authentication is used.
class LcpPassphraseAuthentication extends LcpAuthenticating {
  final String passphrase;
  final LcpAuthenticating? fallback;

  LcpPassphraseAuthentication(this.passphrase, {this.fallback});

  @override
  Future<String?> retrievePassphrase(AuthenticatedLicense license,
      AuthenticationReason reason, bool allowUserInteraction,
      {Object? sender}) async {
    if (reason != AuthenticationReason.passphraseNotFound) {
      return fallback?.retrievePassphrase(
          license, reason, allowUserInteraction = allowUserInteraction,
          sender: sender);
    }
    return passphrase;
  }
}
