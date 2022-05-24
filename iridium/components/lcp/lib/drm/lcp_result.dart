// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';

class LcpResult<T> {
  final int drmErrorCode;
  final T result;

  LcpResult(this.drmErrorCode, this.result);

  DRMError get drmError => fromCode(drmErrorCode);

  @override
  String toString() =>
      'LcpResult{drmErrorCode: $drmErrorCode, result: $result}';
}
