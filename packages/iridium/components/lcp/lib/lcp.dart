// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/persistence/lcp_database.dart';

export 'auth/lcp_passphrase_authentication.dart';
export 'drm/drm_context.dart';
export 'drm/drm_error.dart';
export 'drm/drm_exception.dart';
export 'drm/lcp_result.dart';
export 'i18n/lcp_localizations.dart';
export 'io/uint8list_converter.dart';
export 'lcp_authenticating.dart';
export 'lcp_client.dart';
export 'lcp_content_protection.dart';
export 'lcp_content_protection_service.dart';
export 'lcp_decryptor.dart';
export 'lcp_error.dart';
export 'lcp_exception.dart';
export 'lcp_license.dart';
export 'lcp_parsing_error.dart';
export 'lcp_service.dart';
export 'license/container/bytes_license_container.dart';
export 'license/container/epub_license_container.dart';
export 'license/container/lcpl_license_container.dart';
export 'license/container/license_container.dart';
export 'license/container/web_pub_license_container.dart';
export 'license/container/zip_license_container.dart';
export 'license/license.dart';
export 'license/license_validation.dart';
export 'license/model/components/lcp/content_key.dart';
export 'license/model/components/lcp/encryption.dart';
export 'license/model/components/lcp/rights.dart';
export 'license/model/components/lcp/signature.dart';
export 'license/model/components/lcp/user.dart';
export 'license/model/components/lcp/user_key.dart';
export 'license/model/components/link.dart';
export 'license/model/components/links.dart';
export 'license/model/components/lsd/event.dart';
export 'license/model/components/lsd/potential_rights.dart';
export 'license/model/license_document.dart';
export 'license/model/status_document.dart';
export 'persistence/lcp_database.dart';
export 'service/crl_service.dart';
export 'service/device_repository.dart';
export 'service/device_service.dart';
export 'service/licenses_repository.dart';
export 'service/licenses_service.dart';
export 'service/network_service.dart';
export 'service/passphrases_repository.dart';
export 'service/passphrases_service.dart';

mixin Lcp {
  static Future<void> initLcp() async {
    await LcpDatabase.create();
  }
}
