// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class User {
  final String? id;
  final String? email;
  final String? name;
  final List<String> encrypted;
  final Map extensions;

  User._(this.id, this.email, this.name, this.encrypted, this.extensions);

  factory User.parse(Map? json) {
    List<String> encrypted = [];
    if (json != null && json.containsKey("encrypted")) {
      Iterable<dynamic> encryptedArray = json["encrypted"];
      encrypted.addAll(encryptedArray.map((v) => v.toString()));
    }
    return User._(json?["id"], json?["email"], json?["name"], encrypted,
        json ?? <dynamic, dynamic>{});
  }

  @override
  String toString() =>
      'User{id: $id, email: $email, name: $name, encrypted: $encrypted, extensions: $extensions}';
}
