// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';

abstract class LcpAuthenticating {
  /// Retrieves the passphrase used to decrypt the given license.
  ///
  /// If [allowUserInteraction] is true, the reading app can prompt the user to enter the
  /// passphrase. Otherwise, use a background retrieval method (e.g. web service) or return null.
  ///
  /// The returned passphrase can be clear or already hashed.
  ///
  /// You can implement an asynchronous pop-up with callbacks using `suspendCoroutine`:
  /// ```
  /// suspendCoroutine<String?> { cont ->
  ///     cancelButton.setOnClickListener {
  ///         cont.resume(null)
  ///     }
  ///
  ///     okButton.setOnClickListener {
  ///         cont.resume(passwordEditText.text.toString())
  ///     }
  ///
  ///     // show pop-up...
  /// }
  /// ```
  ///
  /// @param license Information to show to the user about the license being opened.
  /// @param reason Reason why the passphrase is requested. It should be used to prompt the user.
  /// @param allowUserInteraction Indicates whether the user can be prompted for their passphrase.
  /// @param sender Free object that can be used by reading apps to give some UX context when
  ///        presenting dialogs.
  Future<String?> retrievePassphrase(AuthenticatedLicense license,
      AuthenticationReason reason, bool allowUserInteraction,
      {Object? sender});
}

enum AuthenticationReason {
  /// No matching passphrase was found.
  passphraseNotFound,

  /// The provided passphrase was invalid.
  invalidPassphrase
}

/// @param document License Document being opened.
class AuthenticatedLicense {
  final LicenseDocument document;

  AuthenticatedLicense(this.document);

  /// A hint to be displayed to the User to help them remember the User Passphrase.
  String get hint => document.encryption.userKey.textHint;

  /// Location where a Reading System can redirect a User looking for additional information
  /// about the User Passphrase.
  Link? get hintLink => document.link(LicenseRel.hint);

  /// Support resources for the user (either a website, an email or a telephone number).
  List<Link> get supportLinks => document.links(LicenseRel.support);

  /// URI of the license provider.
  String get provider => document.provider.toString();

  /// Informations about the user owning the license.
  User? get user => document.user;
}
