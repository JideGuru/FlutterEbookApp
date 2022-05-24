// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/publication.dart';

class LcpContentProtectionService extends ContentProtectionService {
  final LcpLicense? license;
  final LcpException? _error;

  LcpContentProtectionService.createFactory(this.license, this._error);

  @override
  UserException? get error => _error;

  @override
  bool get isRestricted => license == null;

  @override
  String? get credentials => null;

  @override
  UserRights get rights => license ?? AllRestricted();

  @override
  LocalizedString get name => LocalizedString.fromString("Readium LCP");
}
