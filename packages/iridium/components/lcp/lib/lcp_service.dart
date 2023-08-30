// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_commons/utils/try.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/publication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' hide Link;

class LcpServiceFactory {
  static Future<LcpService?> create(LcpClient lcpClient) async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    return LcpService.create(sharedPreference, lcpClient);
  }
}

abstract class LcpService {
  /// LCP service factory.
  static LcpService? create(
      SharedPreferences preferences, LcpClient lcpClient) {
    if (!lcpClient.isAvailable) {
      return null;
    }

    LcpDatabase db = LcpDatabase.instance;
    NetworkService network = NetworkService();
    DeviceService device = DeviceService(db.licenses, network, preferences);
    CrlService crl = CrlService(network, preferences);
    PassphrasesService passphrases =
        PassphrasesService(db.transactions, lcpClient);
    return LicensesService(
        db.licenses, crl, device, network, passphrases, preferences, lcpClient);
  }

  /// Returns if the publication is protected by LCP.
  Future<bool> isLcpProtected(FileSystemEntity file);

  /// Acquires a protected publication from a standalone LCPL's bytes.
  Future<Try<AcquiredPublication, LcpException>> acquirePublication(
      ByteData lcpl);

  ///  Acquires a protected publication from a standalone LCPL file.
  Future<Try<AcquiredPublication, LcpException>> acquirePublicationFromFile(
      File lcpl) async {
    try {
      return lcpl
          .readAsBytes()
          .then((data) => ByteData.sublistView(data))
          .then((data) => acquirePublication(data));
    } on Exception catch (e) {
      return Try.failure(LcpException.wrap(e));
    }
  }

  /// Opens the LCP license of a protected publication, to access its DRM metadata and decipher
  /// its content.
  ///
  /// @param authentication Used to retrieve the user passphrase if it is not already known.
  ///        The request will be cancelled if no passphrase is found in the LCP passphrase storage
  ///        and the provided [authentication].
  /// @param allowUserInteraction Indicates whether the user can be prompted for their passphrase.
  /// @param sender Free object that can be used by reading apps to give some UX context when
  ///        presenting dialogs with [LcpAuthenticating].
  Future<Try<LcpLicense, LcpException>?> retrieveLicense(
      FileSystemEntity file,
      LcpAuthenticating? authentication,
      bool allowUserInteraction,
      dynamic sender);

  /// Creates a [ContentProtection] instance which can be used with a Streamer to unlock
  /// LCP protected publications.
  ///
  /// The provided [authentication] will be used to retrieve the user passphrase when opening an
  /// LCP license. The default implementation [LcpDialogAuthentication] presents a dialog to the
  /// user to enter their passphrase. This implementation is not provided in mno_lcp_dart since
  /// it makes no assumption about the context where it will be used
  ContentProtection contentProtection({LcpAuthenticating? authentication}) =>
      LcpContentProtection(this, authentication);
}

class AcquiredPublication {
  final File localFile;
  final String suggestedFilename;

  AcquiredPublication(this.localFile, this.suggestedFilename);

  @override
  String toString() =>
      'AcquiredPublication{localFile: $localFile, suggestedFilename: $suggestedFilename}';
}
