// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:fimber/fimber.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:universal_io/io.dart' hide Link;

class LcplLicenseContainer implements LicenseContainer {
  final String lcpl;

  LcplLicenseContainer(this.lcpl);

  @override
  Future<ByteData> read() async {
    try {
      return File(lcpl)
          .readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes))
          .onError(
              (error, stackTrace) => throw LcpException.container.openFailed);
    } on Exception catch (e, stacktrace) {
      Fimber.e("LcplLicenseContainer.read ERROR",
          ex: e, stacktrace: stacktrace);
      throw LcpException.container.openFailed;
    }
  }

  @override
  Future<void> write(LicenseDocument license) async {
    try {
      await File(lcpl).writeAsBytes(license.data.buffer.asUint8List());
    } on Exception catch (e, stacktrace) {
      Fimber.e("LcplLicenseContainer.write ERROR",
          ex: e, stacktrace: stacktrace);
      throw LcpException.container.writeFailed(lcpl);
    }
  }
}
