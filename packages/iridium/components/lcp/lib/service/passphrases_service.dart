// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:crypto/crypto.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_lcp/lcp.dart';

class PassphrasesService {
  static final RegExp sha256Regex =
      RegExp("^([a-f0-9]{64})\$", caseSensitive: false);
  final PassphrasesRepository repository;
  final LcpClient lcpClient;

  PassphrasesService(this.repository, this.lcpClient);

  Future<String?> request(
      LicenseDocument license,
      LcpAuthenticating? authentication,
      bool allowUserInteraction,
      dynamic sender) async {
    List<String> candidates = await _possiblePassphrasesFromRepository(license);
    if (candidates.isNotEmpty) {
      String? passphrase;
      try {
        passphrase =
            lcpClient.findOneValidPassphrase(license.rawJson, candidates);
      } on Exception catch (ex, stacktrace) {
        Fimber.d("findOneValidPassphrase ERROR",
            ex: ex, stacktrace: stacktrace);
      }
      if (passphrase != null) {
        return passphrase;
      }
    }
    if (authentication != null) {
      return _authenticate(license, AuthenticationReason.passphraseNotFound,
          authentication, allowUserInteraction, sender);
    }
    return null;
  }

  Future<String?> _authenticate(
      LicenseDocument license,
      AuthenticationReason reason,
      LcpAuthenticating authentication,
      bool allowUserInteraction,
      dynamic sender) async {
    AuthenticatedLicense authenticatedLicense = AuthenticatedLicense(license);
    String? clearPassphrase = await authentication.retrievePassphrase(
        authenticatedLicense, reason, allowUserInteraction,
        sender: sender);
    if (clearPassphrase == null) {
      return null;
    }
    String hashedPassphrase =
        sha256.convert(clearPassphrase.codeUnits).toString();
    List<String> passphrases = [hashedPassphrase];
    // Note: The C++ LCP lib crashes if we provide a passphrase that is not a valid
    // SHA-256 hash. So we check this beforehand.
    if (sha256Regex.hasMatch(clearPassphrase)) {
      passphrases.add(clearPassphrase);
    }

    try {
      String passphrase =
          lcpClient.findOneValidPassphrase(license.rawJson, passphrases);
      addPassphrase(passphrase, true, license.id, license.provider.toString(),
          license.user.id);
      return passphrase;
    } on Exception catch (ex, stacktrace) {
      Fimber.d("findOneValidPassphrase ERROR", ex: ex, stacktrace: stacktrace);
      return _authenticate(license, AuthenticationReason.invalidPassphrase,
          authentication, allowUserInteraction, sender);
    }
  }

  void addPassphrase(String passphrase, bool hashed, String? licenseId,
      String? provider, String? userId) {
    String hashedPassphrase =
        (hashed) ? passphrase : sha256.convert(passphrase.codeUnits).toString();
    repository.addPassphrase(hashedPassphrase, licenseId, provider, userId);
  }

  Future<List<String>> _possiblePassphrasesFromRepository(
      LicenseDocument license) async {
    Set<String> passphrases = {};
    String? licensePassphrase = await repository.passphrase(license.id);
    if (licensePassphrase != null) {
      passphrases.add(licensePassphrase);
    }
    String? userId = license.user.id;
    if (userId != null) {
      List<String> userPassphrases = await repository.passphrases(userId);
      passphrases.addAll(userPassphrases);
    }
    passphrases.addAll(await repository.allPassphrases());
    return passphrases.toList();
  }
}
