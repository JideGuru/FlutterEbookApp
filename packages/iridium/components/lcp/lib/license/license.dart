// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:universal_io/io.dart' hide Link;

class License implements LcpLicense {
  ValidatedDocuments _documents;
  final LicenseValidation _validation;
  final LicensesRepository _licenses;
  final DeviceService _device;
  final NetworkService _network;
  final LcpClient _lcpClient;

  License(this._documents, this._validation, this._licenses, this._device,
      this._network, this._lcpClient) {
    _validation.observe(_validation, (documents, _) {
      if (documents != null) {
        _documents = documents;
      }
    });
  }

  @override
  LicenseDocument get license => _documents.license;

  @override
  StatusDocument? get status => _documents.status;

  @override
  Future<Try<ByteData, LcpException>> decrypt(ByteData data) async {
    try {
      // LCP lib crashes if we call decrypt on an empty ByteArray
      if (data.lengthInBytes == 0) {
        return Try.success(ByteData(0));
      } else {
        DrmContext context = _documents.getContext();
        ByteData decryptedData = _lcpClient.decrypt(context, data);
        return Try.success(decryptedData);
      }
    } on Exception catch (e) {
      return Try.failure(LcpException.wrap(e));
    }
  }

  @override
  int? get charactersToCopyLeft {
    try {
      int? charactersLeft = _licenses.copiesLeft(license.id);
      if (charactersLeft != null) {
        return charactersLeft;
      }
    } on Error catch (error) {
      Fimber.e("ERROR in charactersToCopyLeft", ex: error);
    }
    return null;
  }

  @override
  bool get canCopy => (charactersToCopyLeft ?? 1) > 0;

  @override
  bool canCopyText(String text) {
    int? nbChars = charactersToCopyLeft;
    return (nbChars != null) ? nbChars < text.length : true;
  }

  @override
  bool copy(String text) {
    int? charactersLeft = charactersToCopyLeft;
    if (charactersLeft == null) {
      return true;
    }
    if (text.length > charactersLeft) {
      return false;
    }

    try {
      charactersLeft = max(0, charactersLeft - text.length);
      _licenses.setCopiesLeft(charactersLeft, license.id);
    } on Error catch (error) {
      Fimber.e("ERROR in copy", ex: error);
    }
    return true;
  }

  @override
  int? get pagesToPrintLeft {
    try {
      int? pagesLeft = _licenses.printsLeft(license.id);
      if (pagesLeft != null) {
        return pagesLeft;
      }
    } on Error catch (error) {
      Fimber.e("ERROR in pagesToPrintLeft", ex: error);
    }
    return null;
  }

  @override
  bool get canPrint => (pagesToPrintLeft ?? 1) > 0;

  @override
  bool canPrintPageCount(int pageCount) {
    int? pagesLeft = pagesToPrintLeft;
    return (pagesLeft != null) ? pagesLeft < pageCount : true;
  }

  @override
  bool print(int pageCount) {
    int? pagesLeft = pagesToPrintLeft;
    if (pagesLeft == null) {
      return true;
    }
    if (pagesLeft < pageCount) {
      return false;
    }
    try {
      pagesLeft = max(0, pagesLeft - pageCount);
      _licenses.setPrintsLeft(pagesLeft, license.id);
    } on Error catch (error) {
      Fimber.e("ERROR in print", ex: error);
    }
    return true;
  }

  @override
  bool get canRenewLoan => status?.link(StatusRel.renew) != null;

  @override
  DateTime? get maxRenewDate => status?.potentialRights?.end;

  @override
  Future<Try<DateTime, LcpException>> renewLoan(RenewListener listener,
      {bool prefersWebPage = false}) async {
    // Finds the renew link according to `prefersWebPage`.
    Link? findRenewLink() {
      StatusDocument? status = _documents.status;
      if (status == null) {
        return null;
      }

      List<MediaType> types = [MediaType.html, MediaType.xhtml];
      if (prefersWebPage) {
        types.add(MediaType.lcpStatusDocument);
      } else {
        types.insert(0, MediaType.lcpStatusDocument);
      }

      for (MediaType type in types) {
        Link? link = status.link(StatusRel.renew, type: type);
        if (link != null) {
          return link;
        }
      }

      // Fallback on the first renew link with no media type set and assume it's a PUT action.
      return status.linkWithNoType(StatusRel.renew);
    }

    // Programmatically renew the loan with a PUT request.
    Future<ByteData> renewProgrammatically(Link link) async {
      DateTime? endDate;
      if (link.templateParameters.contains("end")) {
        endDate = await listener.preferredEndDate(maxRenewDate);
      }

      Map<String, String> parameters = await _device.asQueryParameters;
      if (endDate != null) {
        parameters["end"] = endDate.toIso8601String();
      }

      Uri url = link.urlWithParams(parameters: parameters);

      Try<ByteData, NetworkException> result =
          await _network.fetch(url.toString(), method: Method.put);
      return result.getOrElse((error) {
        switch (error.status) {
          case HttpStatus.badRequest:
            throw LcpException.renew.renewFailed;
          case HttpStatus.forbidden:
            throw LcpException.renew.invalidRenewalPeriod(this.maxRenewDate);
          default:
            throw LcpException.renew.unexpectedServerError;
        }
      });
    }

    // Renew the loan by presenting a web page to the user.
    Future<ByteData> renewWithWebPage(Link link) {
      // The reading app will open the URL in a web view and return when it is dismissed.
      listener.openWebPage(link.url);

      Uri statusUrl;
      try {
        statusUrl = license.url(LicenseRel.status,
            preferredType: MediaType.lcpStatusDocument);
      } on LcpException {
        throw LcpException.licenseInteractionNotAvailable;
      }

      return _network
          .fetch(statusUrl.toString())
          .then((value) => value.getOrThrow());
    }

    try {
      Link? link = findRenewLink();
      if (link == null) {
        throw LcpException.licenseInteractionNotAvailable;
      }

      Future<ByteData> data;
      if (link.mediaType.isHtml) {
        data = renewWithWebPage(link);
      } else {
        data = renewProgrammatically(link);
      }

      _validateStatusDocument(await data);

      return Try.success(_documents.license.rights.end);
//     } on CancellationException {
// // Passthrough for cancelled coroutines
//       rethrow;
    } on Exception catch (e) {
      return Try.failure(LcpException.wrap(e));
    }
  }

  @override
  bool get canReturnPublication => status?.link(StatusRel.ret) != null;

  @override
  Future<Try<bool, LcpException>> returnPublication() async {
    try {
      StatusDocument? status = _documents.status;
      Uri? url;
      try {
        url = status?.url(StatusRel.ret,
            preferredType: null, parameters: await _device.asQueryParameters);
      } on Error {
        url = null;
      }
      if (status == null || url == null) {
        throw LcpException.licenseInteractionNotAvailable;
      }

      await _network.fetch(url.toString(), method: Method.put).then((value) =>
          value
              .onSuccess((data) => _validateStatusDocument(data))
              .onFailure((error) {
            switch (error.status) {
              case HttpStatus.badRequest:
                throw LcpException.return_.returnFailed;
              case HttpStatus.forbidden:
                throw LcpException.return_.alreadyReturnedOrExpired;
              default:
                throw LcpException.return_.unexpectedServerError;
            }
          }));

      return Try.success(true);
    } on Exception catch (e) {
      return Try.failure(LcpException.wrap(e));
    }
  }

  void _validateStatusDocument(ByteData data) =>
      _validation.validate(LicenseValidationDocument.status(data), (_, __) {});

  @override
  String toString() => 'License{license: $license, '
      'status: $status, '
      'charactersToCopyLeft: $charactersToCopyLeft, '
      'pagesToPrintLeft: $pagesToPrintLeft, '
      'canRenewLoan: $canRenewLoan, '
      'maxRenewDate: $maxRenewDate, '
      'canReturnPublication: $canReturnPublication}';
}
