// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

// ignore: non_constant_identifier_names
typedef MessageIfAbsent = Function(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'fr';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_lcp_dialog_continue":
            MessageLookupByLibrary.simpleMessage("Continue"),
        "r2_lcp_dialog_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "r2_lcp_dialog_reason_passphraseNotFound":
            MessageLookupByLibrary.simpleMessage("Passphrase Required"),
        "r2_lcp_dialog_reason_invalidPassphrase":
            MessageLookupByLibrary.simpleMessage("Incorrect Passphrase"),
        "r2_lcp_dialog_prompt": (String provider) =>
            "This publication is protected by Readium LCP.\n\n"
            "In order to open it, we need to know the passphrase required by: \n\n$provider.\n\n"
            "To help you remember it, the following hint is available:",
        "r2_lcp_dialog_forgotPassphrase":
            MessageLookupByLibrary.simpleMessage("Forgot your passphrase?"),
        "r2_lcp_dialog_help":
            MessageLookupByLibrary.simpleMessage("Need more help?"),
        "r2_lcp_dialog_support":
            MessageLookupByLibrary.simpleMessage("Support"),
        "r2_lcp_dialog_support_web":
            MessageLookupByLibrary.simpleMessage("Website"),
        "r2_lcp_dialog_support_phone":
            MessageLookupByLibrary.simpleMessage("Phone"),
        "r2_lcp_dialog_support_mail":
            MessageLookupByLibrary.simpleMessage("Mail"),
        "r2_lcp_exception_license_interaction_not_available":
            MessageLookupByLibrary.simpleMessage(
                "This interaction is not available"),
        "r2_lcp_exception_license_profile_not_supported":
            MessageLookupByLibrary.simpleMessage(
                "This License has a profile identifier that this app cannot handle, the publication cannot be processed"),
        "r2_lcp_exception_crl_fetching": MessageLookupByLibrary.simpleMessage(
            "Can't retrieve the Certificate Revocation List"),
        "r2_lcp_exception_network":
            MessageLookupByLibrary.simpleMessage("Network error"),
        "r2_lcp_exception_runtime":
            MessageLookupByLibrary.simpleMessage("Unexpected LCP error"),
        "r2_lcp_exception_unknown":
            MessageLookupByLibrary.simpleMessage("Unknown LCP error"),
        "r2_lcp_exception_license_status_cancelled": (date) =>
            "This license was cancelled on $date",
        "r2_lcp_exception_license_status_returned": (date) =>
            "This license has been returned on $date",
        "r2_lcp_exception_license_status_not_started": (start) =>
            "This license starts on $start",
        "r2_lcp_exception_license_status_expired": (end) =>
            "This license expired on $end",
        "r2_lcp_exception_license_status_revoked": (date, devicesCount) =>
            (devicesCount == 1)
                ? "This license was revoked by its provider on $date. It was registered by $devicesCount device."
                : "This license was revoked by its provider on $date. It was registered by $devicesCount devices.",
        "r2_lcp_exception_renew_renew_failed":
            MessageLookupByLibrary.simpleMessage(
                "Your publication could not be renewed properly"),
        "r2_lcp_exception_renew_invalid_renewal_period":
            MessageLookupByLibrary.simpleMessage(
                "Incorrect renewal period, your publication could not be renewed"),
        "r2_lcp_exception_renew_unexpected_server_error":
            MessageLookupByLibrary.simpleMessage(
                "An unexpected error has occurred on the server"),
        "r2_lcp_exception_return_return_failed":
            MessageLookupByLibrary.simpleMessage(
                "Your publication could not be returned properly"),
        "r2_lcp_exception_return_already_returned_or_expired":
            MessageLookupByLibrary.simpleMessage(
                "Your publication has already been returned before or is expired"),
        "r2_lcp_exception_return_unexpected_server_error":
            MessageLookupByLibrary.simpleMessage(
                "An unexpected error has occurred on the server"),
        "r2_lcp_exception_parsing": MessageLookupByLibrary.simpleMessage(
            "The JSON is not representing a valid document"),
        "r2_lcp_exception_parsing_malformed_json":
            MessageLookupByLibrary.simpleMessage(
                "The JSON is malformed and can't be parsed"),
        "r2_lcp_exception_parsing_icense_document":
            MessageLookupByLibrary.simpleMessage(
                "The JSON is not representing a valid License Document"),
        "r2_lcp_exception_parsing_status_document":
            MessageLookupByLibrary.simpleMessage(
                "The JSON is not representing a valid Status Document"),
        "r2_lcp_exception_container_open_failed":
            MessageLookupByLibrary.simpleMessage(
                "Can't open the license container"),
        "r2_lcp_exception_container_file_not_found":
            MessageLookupByLibrary.simpleMessage(
                "License not found in container"),
        "r2_lcp_exception_container_read_failed":
            MessageLookupByLibrary.simpleMessage(
                "Can't read license from container"),
        "r2_lcp_exception_container_write_failed":
            MessageLookupByLibrary.simpleMessage(
                "Can't write license in container"),
        "r2_lcp_exception_license_integrity_certificate_revoked":
            MessageLookupByLibrary.simpleMessage(
                "Certificate has been revoked in the CRL"),
        "r2_lcp_exception_license_integrity_invalid_certificate_signature":
            MessageLookupByLibrary.simpleMessage(
                "Certificate has not been signed by CA"),
        "r2_lcp_exception_license_integrity_invalid_license_signature_date":
            MessageLookupByLibrary.simpleMessage(
                "License has been issued by an expired certificate"),
        "r2_lcp_exception_license_integrity_invalid_license_signature":
            MessageLookupByLibrary.simpleMessage(
                "License signature does not match"),
        "r2_lcp_exception_license_integrity_invalid_user_key_check":
            MessageLookupByLibrary.simpleMessage("User key check invalid"),
        "r2_lcp_exception_decryption_content_key_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Unable to decrypt encrypted content key from user key"),
        "r2_lcp_exception_decryption_content_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Unable to decrypt encrypted content from content key"),
      };
}
