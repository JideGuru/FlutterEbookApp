// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

class LcpContentProtection implements ContentProtection {
  final LcpService _lcpService;
  final LcpAuthenticating? _authentication;

  LcpContentProtection(this._lcpService, this._authentication);

  @override
  Future<Try<ProtectedAsset, UserException>?> open(
      PublicationAsset asset,
      Fetcher fetcher,
      String? credentials,
      bool allowUserInteraction,
      dynamic sender) async {
    if (asset is! FileAsset) {
      Fimber.e(
          "Only `FileAsset` is supported with the `LcpContentProtection`. Make sure you are trying to open a package from the file system.");
      return Try.failure(OpeningException.unsupportedFormat);
    }

    FileAsset fileAsset = asset;
    if (!await _lcpService.isLcpProtected(fileAsset.file)) {
      return null;
    }

    LcpAuthenticating? authentication = (credentials != null)
        ? LcpPassphraseAuthentication(credentials,
            fallback: this._authentication)
        : this._authentication;

    Try<LcpLicense, LcpException>? license = await _lcpService.retrieveLicense(
        fileAsset.file, authentication, allowUserInteraction, sender);
    if (license == null || license.isFailure) {
      return Try.failure(license?.failure!);
    }

    ProtectedAsset protectedFile = ProtectedAsset(
        asset: asset,
        fetcher: TransformingFetcher.single(
            fetcher, LcpDecryptor(license.getOrNull()).transform),
        onCreatePublication: (servicesBuilder) => servicesBuilder
            .contentProtectionServiceFactory = serviceFactory(license));

    return Try.success(protectedFile);
  }

  ServiceFactory serviceFactory(Try<LcpLicense, LcpException>? license) =>
      (context) => LcpContentProtectionService.createFactory(
          license?.getOrNull(), license?.exceptionOrNull());
}
