// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/license/container/zip_license_container.dart';

class EpubLicenseContainer extends ZipLicenseContainer {
  EpubLicenseContainer(String epub)
      : super(zip: epub, pathInZIP: "META-INF/license.lcpl");
}
