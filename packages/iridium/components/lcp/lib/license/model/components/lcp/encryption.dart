// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';

class Encryption {
  final Uri profile;
  final ContentKey contentKey;
  final UserKey userKey;

  Encryption._(this.profile, this.contentKey, this.userKey);

  factory Encryption.parse(Map json) => Encryption._(Uri.parse(json["profile"]),
      ContentKey.parse(json["content_key"]), UserKey.parse(json["user_key"]));

  @override
  String toString() =>
      'Encryption{profile: $profile, contentKey: $contentKey, userKey: $userKey}';
}
