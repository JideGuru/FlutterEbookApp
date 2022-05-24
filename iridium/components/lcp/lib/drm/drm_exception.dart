// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';

class DRMException implements Exception {
  final DRMError drmError;

  DRMException(this.drmError);

  @override
  String toString() => 'DRMException{drmError: $drmError}';
}
