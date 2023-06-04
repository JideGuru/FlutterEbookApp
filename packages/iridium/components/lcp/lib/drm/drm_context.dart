// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class DrmContext {
  // Hashed passphrase in hex used to generate the user key
  final String hashedPassphrase;

  // Hex key, encoded with user key, used to decrypt content
  final String encryptedContentKey;

  // Token that certifies the validity of this DRM context
  final String token;
  final String profile;

  DrmContext(this.hashedPassphrase, this.encryptedContentKey, this.token,
      this.profile);

  @override
  String toString() => 'DrmContext{hashedPassphrase: $hashedPassphrase, '
      'encryptedContentKey: $encryptedContentKey, token: $token, '
      'profile: $profile}';
}
