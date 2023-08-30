// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

enum LcpErrorCase {
  unknown,
  invalidPath,
  invalidLcpl,
  statusLinkNotFound,
  licenseNotFound,
  licenseLinkNotFound,
  publicationLinkNotFound,
  hintLinkNotFound,
  registerLinkNotFound,
  linkNotFound,
  renewLinkNotFound,
  noStatusDocument,
  licenseDocumentData,
  publicationData,
  registrationFailure,
  failure,
  alreadyed,
  alreadyExpired,
  renewFailure,
  renewPeriod,
  deviceId,
  unexpectedServerError,
  invalidHintData,
  archive,
  fileNotInArchive,
  noPassphraseFound,
  emptyPassphrase,
  invalidJson,
  invalidContext,
  crlFetching,
  missingLicenseStatus,
  licenseStatusCancelled,
  licenseStatusReturned,
  licenseStatusRevoked,
  licenseStatusExpired,
  invalidRights,
  invalidPassphrase
}

class LcpError {
  static String errorDescription(LcpErrorCase lcpErrorCase) {
    switch (lcpErrorCase) {
      case LcpErrorCase.invalidPath:
        return "The provided license file path is incorrect.";
      case LcpErrorCase.invalidLcpl:
        return "The provided license isn't a correctly formatted LCPL file. ";
      case LcpErrorCase.licenseNotFound:
        return "No license found in base for the given identifier.";
      case LcpErrorCase.statusLinkNotFound:
        return "The status link is missing from the license document.";
      case LcpErrorCase.licenseLinkNotFound:
        return "The license link is missing from the status document.";
      case LcpErrorCase.publicationLinkNotFound:
        return "The publication link is missing from the license document.";
      case LcpErrorCase.hintLinkNotFound:
        return "The hint link is missing from the license document.";
      case LcpErrorCase.registerLinkNotFound:
        return "The register link is missing from the status document.";
      case LcpErrorCase.linkNotFound:
        return "The  link is missing from the status document.";
      case LcpErrorCase.renewLinkNotFound:
        return "The renew link is missing from the status document.";
      case LcpErrorCase.noStatusDocument:
        return "Updating the license failed, there is no status document.";
      case LcpErrorCase.licenseDocumentData:
        return "Updating license failed, the fetche data is invalid.";
      case LcpErrorCase.publicationData:
        return "The publication data is invalid.";
      case LcpErrorCase.missingLicenseStatus:
        return "The license status couldn't be defined.";
      case LcpErrorCase.licenseStatusReturned:
        return "This license has been returned.";
      case LcpErrorCase.licenseStatusRevoked:
        return "This license has been revoked by its PROVIDER.";
      case LcpErrorCase.licenseStatusCancelled:
        return "You have cancelled this license.";
      case LcpErrorCase.licenseStatusExpired:
        return "The license status is expired, if your PROVIDER allow it, you may be able to renew it.";
      case LcpErrorCase.invalidRights:
        return "The rights of this license aren't valid.";
      case LcpErrorCase.registrationFailure:
        return "The device could not be registered properly.";
      case LcpErrorCase.failure:
        return "Your publication could not be ed properly.";
      case LcpErrorCase.alreadyed:
        return "Your publication has already been ed before.";
      case LcpErrorCase.alreadyExpired:
        return "Your publication has already expired.";
      case LcpErrorCase.renewFailure:
        return "Your publication could not be renewed properly.";
      case LcpErrorCase.deviceId:
        return "Couldn't retrieve/generate a proper deviceId.";
      case LcpErrorCase.unexpectedServerError:
        return "An unexpected error has occurred.";
      case LcpErrorCase.invalidHintData:
        return "The data ed by the server for the hint is not valid.";
      case LcpErrorCase.archive:
        return "Coudn't instantiate the archive object.";
      case LcpErrorCase.fileNotInArchive:
        return "The file you requested couldn't be found in the archive.";
      case LcpErrorCase.noPassphraseFound:
        return "Couldn't find a valide passphrase in the database, please provide a passphrase.";
      case LcpErrorCase.emptyPassphrase:
        return "The passphrase provided is empty.";
      case LcpErrorCase.invalidJson:
        return "The JSON license is not valid.";
      case LcpErrorCase.invalidContext:
        return "The context provided is invalid.";
      case LcpErrorCase.crlFetching:
        return "Error while fetching the certificate revocation list.";
      case LcpErrorCase.invalidPassphrase:
        return "The passphrase entered is not valid.";
      case LcpErrorCase.renewPeriod:
        return "Incorrect renewal period, your publication could not be renewed.";
      case LcpErrorCase.unknown:
      default:
        return "Unknown error";
    }
  }
}
