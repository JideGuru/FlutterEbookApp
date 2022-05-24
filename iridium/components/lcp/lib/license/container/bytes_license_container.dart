// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_lcp/license/container/license_container.dart';
import 'package:mno_lcp/license/model/license_document.dart';

class BytesLicenseContainer implements LicenseContainer {
  ByteData _bytes;

  BytesLicenseContainer(this._bytes);

  @override
  Future<ByteData> read() async => _bytes;

  @override
  Future<void> write(LicenseDocument license) async => _bytes = license.data;
}
