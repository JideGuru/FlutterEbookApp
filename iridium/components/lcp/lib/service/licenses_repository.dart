// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';

abstract class LicensesRepository {
  void addLicense(LicenseDocument license);

  int? copiesLeft(String licenseId);

  void setCopiesLeft(int quantity, String licenseId);

  int? printsLeft(String licenseId);

  void setPrintsLeft(int quantity, String licenseId);
}
