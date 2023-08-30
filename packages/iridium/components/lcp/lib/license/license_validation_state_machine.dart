// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:mno_fsm/mno_fsm.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_lcp/license/license_validation_events.dart';
import 'package:mno_lcp/license/license_validation_states.dart';

class LicenseValidationStateMachine {
  static const bool _debug = false;

  static void _log(String message, {dynamic ex, StackTrace? stacktrace}) {
    if (_debug) {
      Fimber.d(message, ex: ex, stacktrace: stacktrace);
    }
  }

  static StateMachine<LVState, LVEvent, dynamic> create(
          LicenseValidation licenseValidation) =>
      StateMachine.create((GraphBuilder<LVState, LVEvent, dynamic> g) {
        g
          ..initialState(const StartState())
          ..state<StartState>((b) {
            b.on<RetrievedLicenseDataEvent>((s, e) {
              _log("ValidateLicenseState(e.data, null)");
              return b.transitionTo(ValidateLicenseState(e.data, null));
            });
          })
          ..state<ValidateLicenseState>((b) {
            b.on<ValidatedLicenseEvent>((s, e) {
              if (s.status != null) {
                _log("CheckLicenseStatusState(e.license, s.status)");
                return b
                    .transitionTo(CheckLicenseStatusState(e.license, s.status));
              } else {
                _log("FetchStatusState(e.license)");
                return b.transitionTo(FetchStatusState(e.license));
              }
            });
            b.on<FailedEvent>((s, e) {
              _log("FailureState(e.error)");
              return b.transitionTo(FailureState(e.error));
            });
          })
          ..state<FetchStatusState>((b) {
            b.on<RetrievedStatusDataEvent>((s, e) {
              _log("ValidateStatusState(s.license, e.data)");
              return b.transitionTo(ValidateStatusState(s.license, e.data));
            });
            b.on<FailedEvent>((s, e) {
              _log("CheckLicenseStatusState(s.license, null)");
              return b.transitionTo(CheckLicenseStatusState(s.license, null));
            });
          })
          ..state<ValidateStatusState>((b) {
            b.on<ValidatedStatusEvent>((s, e) {
              if (s.license.updated.isBefore(e.status.licenseUpdated)) {
                _log("FetchLicenseState(s.license, e.status)");
                return b.transitionTo(FetchLicenseState(s.license, e.status));
              } else {
                _log("CheckLicenseStatusState(s.license, e.status)");
                return b
                    .transitionTo(CheckLicenseStatusState(s.license, e.status));
              }
            });
            b.on<FailedEvent>((s, e) {
              _log("CheckLicenseStatusState(s.license, null)");
              return b.transitionTo(CheckLicenseStatusState(s.license, null));
            });
          })
          ..state<FetchLicenseState>((b) {
            b.on<RetrievedLicenseDataEvent>((s, e) {
              _log("ValidateLicenseState(e.data, s.status)");
              return b.transitionTo(ValidateLicenseState(e.data, s.status));
            });
            b.on<FailedEvent>((s, e) {
              _log("CheckLicenseStatusState(s.license, s.status)");
              return b
                  .transitionTo(CheckLicenseStatusState(s.license, s.status));
            });
          })
          ..state<CheckLicenseStatusState>((b) {
            b.on<CheckedLicenseStatusEvent>((s, e) {
              if (e.error != null) {
                _log(
                    "ValidState(ValidatedDocuments(s.license, Either.right(e.error), status: s.status))");
                return b.transitionTo(ValidState(ValidatedDocuments(
                    s.license, LicenseStatusValue(e.error!),
                    status: s.status)));
              } else {
                _log("RetrievePassphraseState(s.license, s.status)");
                return b
                    .transitionTo(RetrievePassphraseState(s.license, s.status));
              }
            });
          })
          ..state<RetrievePassphraseState>((b) {
            b.on<RetrievedPassphraseEvent>((s, e) {
              _log("ValidateIntegrityState(s.license, s.status, e.passphrase)");
              return b.transitionTo(
                  ValidateIntegrityState(s.license, s.status, e.passphrase));
            });
            b.on<FailedEvent>((s, e) {
              _log("FailureState(e.error)");
              return b.transitionTo(FailureState(e.error));
            });
            b.on<CancelledEvent>((s, e) {
              _log("CancelledState()");
              return b.transitionTo(const CancelledState());
            });
          })
          ..state<ValidateIntegrityState>((b) {
            b.on<ValidatedIntegrityEvent>((s, e) {
              ValidatedDocuments documents = ValidatedDocuments(
                  s.license, DrmContextValue(e.context),
                  status: s.status);
              Link? link = s.status?.link(StatusRel.register);
              if (link != null) {
                _log("RegisterDeviceState(documents, link)");
                return b.transitionTo(RegisterDeviceState(documents, link));
              } else {
                _log("ValidState(documents)");
                return b.transitionTo(ValidState(documents));
              }
            });
            b.on<FailedEvent>((s, e) {
              _log("FailureState(e.error)");
              return b.transitionTo(FailureState(e.error));
            });
          })
          ..state<RegisterDeviceState>((b) {
            b.on<RegisteredDeviceEvent>((s, e) {
              if (e.statusData != null) {
                _log("ValidateStatusState(s.documents.license, e.statusData)");
                return b.transitionTo(
                    ValidateStatusState(s.documents.license, e.statusData!));
              } else {
                _log("State.valid(s.documents)");
                return b.transitionTo(ValidState(s.documents));
              }
            });
            b.on<FailedEvent>((s, e) {
              _log("State.valid(documents)");
              return b.transitionTo(ValidState(s.documents));
            });
          })
          ..state<ValidState>((b) {
            b.on<RetrievedStatusDataEvent>((s, e) {
              _log("ValidateStatusState(s.documents.license, e.data)");
              return b.transitionTo(
                  ValidateStatusState(s.documents.license, e.data));
            });
          })
          ..state<FailureState>((b) {
            b.onEnter((failure) {
              _log("throw failure.error");
              // throw failure.error;
            });
          })
          ..state<CancelledState>((b) {})
          ..onTransition((t) {
            switch(t.value) {
              case Valid:
                _log("validTransition: ${t.value}");
                licenseValidation.state = t.value.toState;
              case Invalid:
                _log("invalidTransition: ${t.value}");
            }
          });
      });
}
