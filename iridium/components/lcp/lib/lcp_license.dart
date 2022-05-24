// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:mno_commons/utils/try.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/publication.dart' as pub;

mixin LcpLicense implements pub.UserRights {
  /// License Document information.
  /// https://readium.org/lcp-specs/releases/lcp/latest.html
  LicenseDocument get license;

  /// License Status Document information.
  /// https://readium.org/lcp-specs/releases/lsd/latest.html
  StatusDocument? get status;

  /// Number of remaining characters allowed to be copied by the user. If null, there's no limit.
  int? get charactersToCopyLeft;

  /// Number of pages allowed to be printed by the user. If null, there's no limit.
  int? get pagesToPrintLeft;

  /// Can the user renew the loaned publication?
  bool get canRenewLoan;

  /// The maximum potential date to renew to.
  /// If null, then the renew date might not be customizable.
  DateTime? get maxRenewDate;

  /// Renews the loan by starting a renew LSD interaction.
  ///
  /// @param prefersWebPage Indicates whether the loan should be renewed through a web page if
  ///        available, instead of programmatically.
  Future<Try<DateTime, LcpException>> renewLoan(RenewListener listener,
      {bool prefersWebPage = false});

  /// Can the user return the loaned publication?
  bool get canReturnPublication;

  /// Returns the publication to its provider.
  Future<Try<bool, LcpException>> returnPublication();

  /// Decrypts the given [data] encrypted with the license's content key.
  Future<Try<ByteData, LcpException>> decrypt(ByteData data);
}

/// UX delegate for the loan renew LSD interaction.
///
/// If your application fits Material Design guidelines, take a look at [MaterialRenewListener]
/// for a default implementation.
mixin RenewListener {
  /// Called when the renew interaction allows to customize the end date programmatically.
  /// You can prompt the user for the number of days to renew, for example.
  ///
  /// The returned date can't exceed [maximumDate].
  Future<DateTime> preferredEndDate(DateTime? maximumDate);

  /// Called when the renew interaction uses an HTML web page.
  ///
  /// You should present the URL in a Chrome Custom Tab and terminate the function when the
  /// web page is dismissed by the user.
  Future<void> openWebPage(Uri url);
}
