// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class ContentKey {
  final String encryptedValue;
  final Uri algorithm;

  ContentKey._(this.encryptedValue, this.algorithm);

  factory ContentKey.parse(Map json) =>
      ContentKey._(json["encrypted_value"], Uri.parse(json["algorithm"]));

  @override
  String toString() =>
      'ContentKey{encryptedValue: $encryptedValue, algorithm: $algorithm}';
}
