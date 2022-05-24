// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

enum DRMError {
  /// No error
  none,

  /// WARNING ERRORS > 10

  /// License is out of date (check start and end date)
  licenseOutOfDate,

  /// No passhrase matches the license
  licenseNoPasshphraseMatched,

  /// CRITICAL ERRORS > 100

  /// Certificate has been revoked in the CRL
  certificateRevoked,

  /// Certificate has not been signed by CA
  certificateSignatureInvalid,

  /// License has been issued by an expired certificate
  licenseSignatureDateInvalid,

  /// License signature does not match
  licenseSignatureInvalid,

  /// The drm context is invalid
  contextInvalid,

  /// Unable to decrypt encrypted content key from user key
  contentKeyDecryptError,

  /// User key check invalid
  userKeyCheckInvalid,

  /// Unable to decrypt encrypted content from content key
  contentDecryptError,

  /// Unknown
  unknown
}

DRMError fromCode(int code) {
  switch (code) {
    case 0:
      return DRMError.none;
    case 11:
      return DRMError.licenseOutOfDate;
    case 12:
      return DRMError.licenseNoPasshphraseMatched;
    case 101:
      return DRMError.certificateRevoked;
    case 102:
      return DRMError.certificateSignatureInvalid;
    case 111:
      return DRMError.licenseSignatureDateInvalid;
    case 112:
      return DRMError.licenseSignatureInvalid;
    case 121:
      return DRMError.contextInvalid;
    case 131:
      return DRMError.contentKeyDecryptError;
    case 141:
      return DRMError.userKeyCheckInvalid;
    case 151:
      return DRMError.contentDecryptError;
    case 500:
    default:
      return DRMError.unknown;
  }
}
