// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:universal_io/io.dart' hide Link;

class LcpException extends UserException {
  final String? message;

  static final LicenseStatus licenseStatus = LicenseStatus._("");
  static final Renew renew = Renew._("");
  static final Return return_ = Return._("");
  static final Parsing parsing = Parsing._();
  static final ContainerException container = ContainerException._("");
  static final LicenseIntegrity licenseIntegrity = LicenseIntegrity._("");
  static final Decryption decryption = Decryption._("");

  const LcpException(super.userMessageId,
      {super.args = const [],
      super.quantity,
      this.message,
      Exception? super.cause});

  static LcpException wrap(dynamic e) {
    if (e is LcpException) {
      return e;
    }
    if (e is SocketException) {
      return network(e);
    }
    return unknown;
  }

  /// The interaction is not available with this License.
  static LcpException get licenseInteractionNotAvailable =>
      LcpException("r2_lcp_exception_license_interaction_not_available");

  /// This License's profile is not supported by liblcp.
  static LcpException get licenseProfileNotSupported =>
      LcpException("r2_lcp_exception_license_profile_not_supported");

  /// Failed to retrieve the Certificate Revocation List.
  static LcpException get crlFetching =>
      LcpException("r2_lcp_exception_crl_fetching");

  /// A network request failed with the given exception.
  static LcpException network(Exception cause) =>
      LcpException("r2_lcp_exception_network", cause: cause);

  /// An unexpected LCP exception occurred. Please post an issue on r2-lcp-kotlin with the error
  /// message and how to reproduce it.
  static LcpException runtime(String message) =>
      LcpException("r2_lcp_exception_runtime", message: message);

  /// An unknown low-level exception was reported.
  static LcpException get unknown => LcpException("r2_lcp_exception_unknown");
}

/// Errors while checking the status of the License, using the Status Document.
///
/// The app should notify the user and stop there. The message to the user must be clear about
/// the status of the license: don't display "expired" if the status is "revoked". The date and
/// time corresponding to the new status should be displayed (e.g. "The license expired on 01
/// January 2018").
class LicenseStatus extends LcpException {
  LicenseStatus._(super.userMessageId, {super.args, super.quantity = 0});

  LicenseStatus cancelled(DateTime date) =>
      LicenseStatus._("r2_lcp_exception_license_status_cancelled",
          args: [date]);

  LicenseStatus returned(DateTime date) =>
      LicenseStatus._("r2_lcp_exception_license_status_returned", args: [date]);

  LicenseStatus notStarted(DateTime start) =>
      LicenseStatus._("r2_lcp_exception_license_status_not_started",
          args: [start]);

  LicenseStatus expired(DateTime end) =>
      LicenseStatus._("r2_lcp_exception_license_status_expired", args: [end]);

  /// If the license has been revoked, the user message should display the number of devices which
  /// registered to the server. This count can be calculated from the number of "register" events
  /// in the status document. If no event is logged in the status document, no such message should
  /// appear (certainly not "The license was registered by 0 devices").
  LicenseStatus revoked(DateTime date, int devicesCount) =>
      LicenseStatus._("r2_lcp_exception_license_status_revoked",
          quantity: devicesCount, args: [date, devicesCount]);
}

/// Errors while renewing a loan.
class Renew extends LcpException {
  const Renew._(super.userMessageId);

  /// Your publication could not be renewed properly.
  Renew get renewFailed => Renew._("r2_lcp_exception_renew_renew_failed");

  InvalidRenewalPeriod invalidRenewalPeriod(DateTime? maxRenewDate) =>
      InvalidRenewalPeriod._(maxRenewDate);

  /// An unexpected error has occurred on the licensing server.
  Renew get unexpectedServerError =>
      Renew._("r2_lcp_exception_renew_unexpected_server_error");
}

/// Incorrect renewal period, your publication could not be renewed.
class InvalidRenewalPeriod extends Renew {
  final DateTime? maxRenewDate;

  InvalidRenewalPeriod._(this.maxRenewDate)
      : super._("r2_lcp_exception_renew_invalid_renewal_period");
}

/// Errors while returning a loan.
class Return extends LcpException {
  Return._(super.userMessageId);

  /// Your publication could not be returned properly.
  Return get returnFailed => Return._("r2_lcp_exception_return_return_failed");

  /// Your publication has already been returned before or is expired.
  Return get alreadyReturnedOrExpired =>
      Return._("r2_lcp_exception_return_already_returned_or_expired");

  /// An unexpected error has occurred on the licensing server.
  Return get unexpectedServerError =>
      Return._("r2_lcp_exception_return_unexpected_server_error");
}

/// Errors while parsing the License or Status JSON Documents.
class Parsing extends LcpException {
  Parsing._([String? userMessageId])
      : super(userMessageId ?? "r2_lcp_exception_parsing");

  /// The JSON is malformed and can't be parsed.
  Parsing get malformedJSON =>
      Parsing._("r2_lcp_exception_parsing_malformed_json");

  /// The JSON is not representing a valid License Document.
  Parsing get licenseDocument =>
      Parsing._("r2_lcp_exception_parsing_license_document");

  /// The JSON is not representing a valid Status Document.
  Parsing get statusDocument =>
      Parsing._("r2_lcp_exception_parsing_status_document");

  /// Invalid Link.
  Parsing get link => Parsing._();

  /// Invalid Encryption.
  Parsing get encryption => Parsing._();

  /// Invalid License Document Signature.
  Parsing get signature => Parsing._();

// /// Invalid URL for link with [rel].
  Url url(String rel) => Url._(rel);
}

class Url extends Parsing {
  final String rel;

  Url._(this.rel) : super._();
}

/// Errors while reading or writing a LCP container (LCPL, EPUB, LCPDF, etc.)
class ContainerException extends LcpException {
  final String? path;
  const ContainerException._(super.userMessageId, {this.path});

  /// Can't access the container, it's format is wrong.
  ContainerException get openFailed =>
      ContainerException._("r2_lcp_exception_container_open_failed");

  /// The file at given relative path is not found in the Container.
  ContainerException fileNotFound(String path) =>
      ContainerException._("r2_lcp_exception_container_file_not_found",
          path: path);

  /// Can't read the file at given relative path in the Container.
  ContainerException readFailed(String path) =>
      ContainerException._("r2_lcp_exception_container_read_failed",
          path: path);

  /// Can't write the file at given relative path in the Container.
  ContainerException writeFailed(String path) =>
      ContainerException._("r2_lcp_exception_container_write_failed",
          path: path);
}

/// An error occurred while checking the integrity of the License, it can't be retrieved.
class LicenseIntegrity extends LcpException {
  LicenseIntegrity._(super.userMessageId);

  LicenseIntegrity get certificateRevoked => LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_certificate_revoked");

  LicenseIntegrity get invalidCertificateSignature => LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_certificate_signature");

  LicenseIntegrity get invalidLicenseSignatureDate => LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_license_signature_date");

  LicenseIntegrity get invalidLicenseSignature => LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_license_signature");

  LicenseIntegrity get invalidUserKeyCheck => LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_user_key_check");
}

class Decryption extends LcpException {
  Decryption._(super.userMessageId);

  Decryption get contentKeyDecryptError =>
      Decryption._("r2_lcp_exception_decryption_content_key_decrypt_error");

  Decryption get contentDecryptError =>
      Decryption._("r2_lcp_exception_decryption_content_decrypt_error");
}
