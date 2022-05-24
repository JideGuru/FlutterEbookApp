// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class UserKey {
  final String textHint;
  final Uri algorithm;
  final String keyCheck;

  UserKey._(this.textHint, this.algorithm, this.keyCheck);

  factory UserKey.parse(Map json) => UserKey._(
      json["text_hint"], Uri.parse(json["algorithm"]), json["key_check"]);

  @override
  String toString() =>
      'UserKey{textHint: $textHint, algorithm: $algorithm, keyCheck: $keyCheck}';
}
