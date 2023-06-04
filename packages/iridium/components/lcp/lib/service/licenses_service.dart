// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_lcp/io/file_util.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' hide Link;

class LicensesService extends LcpService {
  final LicensesRepository licenses;
  final CrlService crl;
  final DeviceService device;
  final NetworkService network;
  final PassphrasesService passphrases;
  final SharedPreferences preferences;
  final LcpClient lcpClient;

  LicensesService(this.licenses, this.crl, this.device, this.network,
      this.passphrases, this.preferences, this.lcpClient);

  @override
  Future<bool> isLcpProtected(FileSystemEntity file) async {
    try {
      return (await LicenseContainer.createLicenseContainer(file.path))
          .read()
          .then((data) => true)
          .onError((error, stackTrace) => false);
    } on Exception catch (e, stacktrace) {
      Fimber.d("createLicenseContainer ERROR", ex: e, stacktrace: stacktrace);
      return false;
    }
  }

  @override
  Future<Try<AcquiredPublication, LcpException>> acquirePublication(
      ByteData lcpl) async {
    try {
      LicenseDocument licenseDocument = LicenseDocument.parse(lcpl);
      return _fetchPublication(licenseDocument)
          .then((license) => Try.success(license));
    } on Exception catch (e, stacktrace) {
      Fimber.d("fetchPublication ERROR", ex: e, stacktrace: stacktrace);
      return Try.failure(LcpException.wrap(e));
    }
  }

  @override
  Future<Try<LcpLicense, LcpException>?> retrieveLicense(
      FileSystemEntity file,
      LcpAuthenticating? authentication,
      bool allowUserInteraction,
      dynamic sender) async {
    try {
      LicenseContainer container =
          await LicenseContainer.createLicenseContainer(file.path);
      // WARNING: Using the Default dispatcher in the state machine code is critical. If we were using the Main Dispatcher,
      // calling runBlocking in LicenseValidation.handle would block the main thread and cause a severe issue
      // with LcpAuthenticating.retrievePassphrase. Specifically, the interaction of runBlocking and suspendCoroutine
      // blocks the current thread before the passphrase popup has been showed until some button not yet showed is clicked.
      LcpException? lcpException;
      LcpLicense? license = await _retrieveLicense(
              container, authentication, allowUserInteraction, sender)
          .onError((error, stackTrace) {
        lcpException = LcpException.wrap(error);
        return null;
      });

      if (license != null) {
        return Try.success(license);
      }
      if (lcpException != null) {
        return Try.failure(lcpException);
      }
      return null;
    } on Exception catch (e, stacktrace) {
      Fimber.d("retrieveLicense ERROR", ex: e, stacktrace: stacktrace);
      return Try.failure(LcpException.wrap(e));
    }
  }

  Future<LcpLicense?> _retrieveLicense(
      LicenseContainer container,
      LcpAuthenticating? authentication,
      bool allowUserInteraction,
      dynamic sender) async {
    ByteData initialData = await container.read();

    LicenseValidation validation = LicenseValidation(
        authentication,
        allowUserInteraction,
        sender,
        this.crl,
        this.device,
        this.network,
        this.passphrases,
        this.lcpClient, (licenseDocument) async {
      try {
        this.licenses.addLicense(licenseDocument);
      } on Exception catch (e, stacktrace) {
        Fimber.d("Failed to add the LCP License to the local database",
            ex: e, stacktrace: stacktrace);
      }
      if (!const ListEquality().equals(
          licenseDocument.data.buffer.asUint8List(),
          initialData.buffer.asUint8List())) {
        try {
          await container.write(licenseDocument);

          initialData = await container.read();
          Fimber.d("Wrote updated License Document in container");
        } on Exception catch (e, stacktrace) {
          Fimber.d("Failed to write updated License Document in container",
              ex: e, stacktrace: stacktrace);
        }
      }
    });
    await validation.init();

    Completer<Try<LcpLicense?, LcpException>> lcpLicenseCompleter = Completer();
    validation.validate(LicenseValidationDocument.license(initialData),
        (documents, error) {
      Fimber.d("documents: $documents, error: $error");
      if (documents != null) {
        try {
          documents.getContext();
          LcpLicense license = License(
              documents, validation, licenses, device, network, lcpClient);
          lcpLicenseCompleter.complete(Try.success(license));
        } on Exception catch (e) {
          Fimber.d("completion ERROR", ex: e);
          lcpLicenseCompleter.complete(Try.failure(LcpException.wrap(e)));
          rethrow;
        }
      }
      if (error != null) {
        lcpLicenseCompleter.complete(Try.failure(LcpException.unknown));
        throw error;
      }
      if (documents == null && error == null) {
        lcpLicenseCompleter.complete(Try.success(null));
      }
    });
    Try<LcpLicense?, void> result = await lcpLicenseCompleter.future;
    return result.getOrThrow();
  }

  Future<AcquiredPublication> _fetchPublication(LicenseDocument license) async {
    Link? link = license.link(LicenseRel.publication);
    Uri? url = link?.url;
    if (url == null) {
      throw LcpException.parsing.url(LicenseRel.publication.val);
    }

    File destination = await FileUtil.getTempFile(
        "lcp-${DateTime.now().millisecondsSinceEpoch}.tmp");
    Fimber.i("LCP destination $destination");

    MediaType? mediaType =
        await network.download(url, destination, mediaType: link?.type);
    if (mediaType == null) {
      if (link == null || link.type == null) {
        mediaType = MediaType.epub;
      } else {
        mediaType = (MediaType.parse((link.type)!) ?? MediaType.epub);
      }
    }

    // Saves the License Document into the downloaded publication
    LicenseContainer container = await LicenseContainer.createLicenseContainer(
        destination.path,
        mediaTypes: [mediaType.toString()]);
    await container.write(license);

    String? fileExtension = mediaType.fileExtension;
    return AcquiredPublication(destination, "${license.id}.$fileExtension");
  }
}
