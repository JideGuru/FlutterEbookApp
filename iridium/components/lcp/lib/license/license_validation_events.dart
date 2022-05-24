// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_lcp/lcp.dart';

class LVEvent {
  const LVEvent();
}

class CancelledEvent extends LVEvent {
  const CancelledEvent();
}

class RetrievedLicenseDataEvent extends LVEvent {
  final ByteData data;

  const RetrievedLicenseDataEvent(this.data);
}

class ValidatedLicenseEvent extends LVEvent {
  final LicenseDocument license;

  const ValidatedLicenseEvent(this.license);
}

class RetrievedStatusDataEvent extends LVEvent {
  final ByteData data;

  const RetrievedStatusDataEvent(this.data);
}

class ValidatedStatusEvent extends LVEvent {
  final StatusDocument status;

  const ValidatedStatusEvent(this.status);
}

class CheckedLicenseStatusEvent extends LVEvent {
  final LicenseStatus? error;

  const CheckedLicenseStatusEvent(this.error);
}

class RetrievedPassphraseEvent extends LVEvent {
  final String passphrase;

  const RetrievedPassphraseEvent(this.passphrase);
}

class ValidatedIntegrityEvent extends LVEvent {
  final DrmContext context;

  const ValidatedIntegrityEvent(this.context);
}

class RegisteredDeviceEvent extends LVEvent {
  final ByteData? statusData;

  const RegisteredDeviceEvent(this.statusData);
}

class FailedEvent extends LVEvent {
  final Exception error;

  const FailedEvent(this.error);
}
