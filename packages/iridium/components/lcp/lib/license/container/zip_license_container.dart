// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_lcp/utils/zip_utils.dart';
import 'package:mno_shared/container.dart';
import 'package:mno_shared/streams.dart';
import 'package:mno_shared/zip.dart';
import 'package:universal_io/io.dart' hide Link;

class ZipLicenseContainer implements LicenseContainer {
  late final String zip;
  final String pathInZIP;

  ZipLicenseContainer({required this.zip, required this.pathInZIP});

  @override
  Future<ByteData> read() async {
    ZipPackage? archive;
    try {
      archive = await ZipContainer(zip).archive;
    } on Exception catch (e, stacktrace) {
      Fimber.e("ZipLicenseContainer.read ERROR", ex: e, stacktrace: stacktrace);
      throw LcpException.container.openFailed;
    }
    ZipLocalFile? entry = archive?.entries[pathInZIP];
    if (entry != null) {
      return ZipStream(archive!, entry)
          .readData(start: 0, length: entry.uncompressedSize)
          .then((data) => data.toByteData())
          .onError((error, stackTrace) =>
              throw LcpException.container.readFailed(pathInZIP));
    } else {
      throw LcpException.container.fileNotFound(pathInZIP);
    }
  }

  @override
  Future<void> write(LicenseDocument license) async {
    try {
      ZipPackage? zipPackage = await ZipPackage.fromArchive(File(zip));
      if (zipPackage?.entries["META-INF/license.lcpl"] == null) {
        await ZipUtils.injectEntry(
            File(zip), ByteEntry(pathInZIP, license.data));
      }
    } on Exception {
      throw LcpException.container.writeFailed(pathInZIP);
    }
  }
}
