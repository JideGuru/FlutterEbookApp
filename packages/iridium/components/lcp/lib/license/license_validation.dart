// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:flutter/services.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_fsm/mno_fsm.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_lcp/license/license_validation_events.dart';
import 'package:mno_lcp/license/license_validation_state_machine.dart';
import 'package:mno_lcp/license/license_validation_states.dart';
import 'package:mno_shared/mediatype.dart';

typedef Observer = void Function(ValidatedDocuments?, Exception?);

enum ObserverPolicy { once, always }

sealed class DrmContextOrLicenseStatus {
}

class DrmContextValue extends DrmContextOrLicenseStatus {
  final DrmContext drmContext;

  DrmContextValue(this.drmContext);
}

class LicenseStatusValue extends DrmContextOrLicenseStatus {
  final LicenseStatus licenseStatus;

  LicenseStatusValue(this.licenseStatus);
}

class ValidatedDocuments {
  final LicenseDocument license;
  final DrmContextOrLicenseStatus contextOrLicenseStatus;
  final StatusDocument? status;

  ValidatedDocuments(this.license, this.contextOrLicenseStatus, {this.status});

  DrmContext getContext() {
    switch (contextOrLicenseStatus) {
      case DrmContextValue v:
        return v.drmContext;
      case LicenseStatusValue v:
        throw v.licenseStatus;
    }
  }
}

abstract class LicenseValidationDocument {
  final ByteData data;

  LicenseValidationDocument._(this.data);

  static LicenseValidationLicenseDocument license(ByteData data) =>
      LicenseValidationLicenseDocument._(data);

  static LicenseValidationStatusDocument status(ByteData data) =>
      LicenseValidationStatusDocument._(data);
}

class LicenseValidationLicenseDocument extends LicenseValidationDocument {
  LicenseValidationLicenseDocument._(super.data) : super._();
}

class LicenseValidationStatusDocument extends LicenseValidationDocument {
  LicenseValidationStatusDocument._(super.data) : super._();
}

class LicenseValidation {
  static const bool _debug = false;
  List<(Observer, ObserverPolicy)> observers = [];
  static const List<String> supportedProfiles = [
    "http://readium.org/lcp/basic-profile",
    "http://readium.org/lcp/profile-1.0"
  ];
  final LcpAuthenticating? authentication;
  final bool allowUserInteraction;
  final dynamic sender;
  final CrlService crl;
  final DeviceService device;
  final NetworkService network;
  final PassphrasesService passphrases;
  final LcpClient lcpClient;
  final void Function(LicenseDocument) onLicenseValidated;
  late StateMachine<LVState, LVEvent, dynamic> stateMachine;
  late bool isProduction;

  LVState _state;

  LicenseValidation(
      this.authentication,
      this.allowUserInteraction,
      this.sender,
      this.crl,
      this.device,
      this.network,
      this.passphrases,
      this.lcpClient,
      this.onLicenseValidated)
      : _state = const StartState();

  static void _log(String message, {dynamic ex, StackTrace? stacktrace}) {
    if (_debug) {
      Fimber.d(message, ex: ex, stacktrace: stacktrace);
    }
  }

  Future<void> init() async {
    stateMachine = LicenseValidationStateMachine.create(this);
    isProduction = await _computeIsProduction();
  }

  LVState get state => _state;

  set state(LVState value) {
    _state = value;
    _handle(value);
  }

  void _raise(LVEvent event) {
    stateMachine.transition(event);
  }

  void validate(LicenseValidationDocument document, Observer completion) {
    LVEvent event;
    switch (document.runtimeType) {
      case LicenseValidationLicenseDocument:
        event = RetrievedLicenseDataEvent(document.data);
        break;
      case LicenseValidationStatusDocument:
        event = RetrievedStatusDataEvent(document.data);
        break;
      default:
        throw LcpException.unknown;
    }
    _log("validate $event");
    _observe(event, completion);
  }

  Future<bool> _computeIsProduction() async {
    ByteData prodLicenseInput =
        await rootBundle.load("assets/prod-license.lcpl");
    LicenseDocument prodLicense = LicenseDocument.parse(prodLicenseInput);
    String passphrase =
        "7B7602FEF5DEDA10F768818FFACBC60B173DB223B7E66D8B2221EBE2C635EFAD";
    try {
      String foundPassphrase =
          lcpClient.findOneValidPassphrase(prodLicense.rawJson, [passphrase]);
      return foundPassphrase == passphrase;
    } on Exception catch (e) {
      _log("isProduction ERROR", ex: e);
      return false;
    }
  }

  Future<void> _handle(LVState state) async {
    _log("state: ${state.runtimeType}");
    try {
      switch (state.runtimeType) {
        case StartState:
          _notifyObservers(null, null);
          break;
        case ValidateLicenseState:
          _validateLicense((state as ValidateLicenseState).data);
          break;
        case FetchStatusState:
          await _fetchStatus((state as FetchStatusState).license);
          break;
        case ValidateStatusState:
          _validateStatus((state as ValidateStatusState).data);
          break;
        case FetchLicenseState:
          await _fetchLicense((state as FetchLicenseState).status);
          break;
        case CheckLicenseStatusState:
          CheckLicenseStatusState checkLicenseStatusState =
              state as CheckLicenseStatusState;
          _checkLicenseStatus(
              checkLicenseStatusState.license, checkLicenseStatusState.status);
          break;
        case RetrievePassphraseState:
          await _requestPassphrase((state as RetrievePassphraseState).license);
          break;
        case ValidateIntegrityState:
          ValidateIntegrityState validateIntegrityState =
              state as ValidateIntegrityState;
          await _validateIntegrity(validateIntegrityState.license,
              validateIntegrityState.passphrase);
          break;
        case RegisterDeviceState:
          RegisterDeviceState registerDeviceState =
              state as RegisterDeviceState;
          await _registerDevice(
              registerDeviceState.documents.license, registerDeviceState.link);
          break;
        case ValidState:
          _notifyObservers((state as ValidState).documents, null);
          break;
        case FailureState:
          _notifyObservers(null, (state as FailureState).error);
          break;
        case CancelledState:
          _notifyObservers(null, null);
          break;
      }
    } on Exception catch (error, stacktrace) {
      _log("LicenseValidation._handle ERROR: $state",
          ex: error, stacktrace: stacktrace);
      _raise(FailedEvent(error));
    }
  }

  void _observe(LVEvent event, Observer observer) {
    _raise(event);
    observe(this, observer, policy: ObserverPolicy.once);
  }

  void _notifyObservers(ValidatedDocuments? documents, Exception? error) {
    for (int i = 0; i < observers.length; i++) {
      observers[i].$1(documents, error);
    }
    observers =
        observers.where((it) => it.$2 != ObserverPolicy.once).toList();
  }

  void _validateLicense(ByteData data) {
    LicenseDocument license = LicenseDocument.parse(data);
    if (!isProduction &&
        license.encryption.profile.toString() !=
            "http://readium.org/lcp/basic-profile") {
      throw LcpException.licenseProfileNotSupported;
    }
    onLicenseValidated(license);
    _raise(ValidatedLicenseEvent(license));
  }

  Future<void> _fetchStatus(LicenseDocument license) async {
    String url = license
        .url(LicenseRel.status, preferredType: MediaType.lcpStatusDocument)
        .toString();
    // Short timeout to avoid blocking the License, since the LSD is optional.
    Try<ByteData, NetworkException> result =
        await network.fetch(url, timeout: const Duration(seconds: 5));
    if (result.isFailure) {
      throw LcpException.network(result.failure!);
    }

    _raise(RetrievedStatusDataEvent(result.success!));
  }

  /*
      private fun validateStatus(data: ByteArray) {
        val status = StatusDocument(data = data)
        raise(Event.validatedStatus(status))
    }
   */
  void _validateStatus(ByteData data) {
    StatusDocument status = StatusDocument.parseData(data);
    _raise(ValidatedStatusEvent(status));
  }

  Future<void> _fetchLicense(StatusDocument status) async {
    String url = status
        .url(StatusRel.license, preferredType: MediaType.lcpLicenseDocument)
        .toString();
    // Short timeout to avoid blocking the License, since it can be updated next time.
    Try<ByteData, NetworkException> result =
        await network.fetch(url, timeout: const Duration(seconds: 5));
    if (result.isFailure) {
      throw LcpException.network(result.failure!);
    }
    _raise(RetrievedLicenseDataEvent(result.success!));
  }

  void _checkLicenseStatus(LicenseDocument license, StatusDocument? status) {
    LicenseStatus? error;
    DateTime now = DateTime.now();
    DateTime start = license.rights.start ?? now;
    DateTime end = license.rights.end ?? now;
    if (start.isAfter(now) || now.isAfter(end)) {
      if (status != null) {
        DateTime? date = status.statusUpdated;
        switch (status.status) {
          case Status.ready:
          case Status.active:
          case Status.expired:
            if (start.isAfter(now)) {
              error = LcpException.licenseStatus.notStarted(start);
            } else {
              error = LcpException.licenseStatus.expired(end);
            }
            break;
          case Status.returned:
            error = LcpException.licenseStatus.returned(date);
            break;
          case Status.revoked:
            int devicesCount = status.events(EventType.register)?.length ?? 0;
            error = LcpException.licenseStatus.revoked(date, devicesCount);
            break;
          case Status.cancelled:
            error = LcpException.licenseStatus.cancelled(date);
            break;
        }
      } else {
        if (start.isAfter(now)) {
          error = LcpException.licenseStatus.notStarted(start);
        } else {
          error = LcpException.licenseStatus.expired(end);
        }
      }
    }
    _raise(CheckedLicenseStatusEvent(error));
  }

  Future<void> _requestPassphrase(LicenseDocument license) async {
    _log("requestPassphrase");
    String? passphrase = await passphrases.request(
        license, authentication, allowUserInteraction, sender);
    if (passphrase == null) {
      _raise(const CancelledEvent());
    } else {
      _raise(RetrievedPassphraseEvent(passphrase));
    }
  }

  Future<void> _validateIntegrity(
      LicenseDocument license, String passphrase) async {
    _log("validateIntegrity");
    Uri profile = license.encryption.profile;
    if (!supportedProfiles.contains(profile.toString())) {
      throw LcpException.licenseProfileNotSupported;
    }
    DrmContext context = lcpClient.createContext(
        license.rawJson, passphrase, await crl.retrieve());
    _raise(ValidatedIntegrityEvent(context));
  }

  Future<void> _registerDevice(LicenseDocument license, Link link) async {
    _log("registerDevice");
    ByteData? data = await device.registerLicense(license, link);
    _raise(RegisteredDeviceEvent(data));
  }

  void observe(LicenseValidation licenseValidation, Observer observer,
      {ObserverPolicy policy = ObserverPolicy.always}) {
    bool notified = true;
    switch (licenseValidation.stateMachine.state.runtimeType) {
      case ValidState:
        observer((licenseValidation.stateMachine.state as ValidState).documents,
            null);
        break;
      case FailureState:
        observer(
            null, (licenseValidation.stateMachine.state as FailureState).error);
        break;
      case CancelledState:
        observer(null, null);
        break;
      default:
        notified = false;
    }
    if (notified && policy != ObserverPolicy.always) {
      return;
    }
    observers.add((observer, policy));
  }
}
