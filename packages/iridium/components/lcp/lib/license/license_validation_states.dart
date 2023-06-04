// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_lcp/lcp.dart';

class LVState {
  const LVState();
}

class StartState extends LVState {
  const StartState();
}

class CancelledState extends LVState {
  const CancelledState();
}

class ValidateLicenseState extends LVState {
  final ByteData data;
  final StatusDocument? status;

  const ValidateLicenseState(this.data, this.status);
}

class FetchStatusState extends LVState {
  final LicenseDocument license;

  const FetchStatusState(this.license);
}

class ValidateStatusState extends LVState {
  final LicenseDocument license;
  final ByteData data;

  const ValidateStatusState(this.license, this.data);
}

class FetchLicenseState extends LVState {
  final LicenseDocument license;
  final StatusDocument status;

  const FetchLicenseState(this.license, this.status);
}

class CheckLicenseStatusState extends LVState {
  final LicenseDocument license;
  final StatusDocument? status;

  const CheckLicenseStatusState(this.license, this.status);
}

class RetrievePassphraseState extends LVState {
  final LicenseDocument license;
  final StatusDocument? status;

  const RetrievePassphraseState(this.license, this.status);
}

class ValidateIntegrityState extends LVState {
  final LicenseDocument license;
  final StatusDocument? status;
  final String passphrase;

  const ValidateIntegrityState(this.license, this.status, this.passphrase);
}

class RegisterDeviceState extends LVState {
  final ValidatedDocuments documents;
  final Link link;

  const RegisterDeviceState(this.documents, this.link);
}

class ValidState extends LVState {
  final ValidatedDocuments documents;

  const ValidState(this.documents);
}

class FailureState extends LVState {
  final Exception error;

  const FailureState(this.error);
}
