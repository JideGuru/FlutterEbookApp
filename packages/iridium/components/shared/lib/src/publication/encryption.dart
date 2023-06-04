// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';

/// Indicates that a resource is encrypted/obfuscated and provides relevant information for decryption.
class Encryption with EquatableMixin, JSONable {
  Encryption(
      {required this.algorithm,
      this.compression,
      this.originalLength,
      this.profile,
      this.scheme});

  /// Identifies the algorithm used to encrypt the resource.
  final String algorithm; // URI

  /// (Nullable) Compression method used on the resource.
  final String? compression;

  /// (Nullable) Original length of the resource in bytes before compression and/or encryption.
  final int? originalLength;

  /// (Nullable) Identifies the encryption profile used to encrypt the resource.
  final String? profile; // URI

  /// (Nullable) Identifies the encryption scheme used to encrypt the resource.
  final String? scheme;

  @override
  List<Object?> get props =>
      [algorithm, compression, originalLength, profile, scheme];

  /// Serializes an [Encryption] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() => {
        "algorithm": algorithm,
        if (compression != null) "compression": compression,
        if (originalLength != null) "originalLength": originalLength,
        if (profile != null) "profile": profile,
        if (scheme != null) "scheme": scheme,
      };

  /// Creates an [Encryption] from its RWPM JSON representation.
  /// If the encryption can't be parsed, a warning will be logged with [warnings].
  static Encryption? fromJSON(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return null;
    }
    String? algorithm = json["algorithm"];
    if (algorithm == null || algorithm.isEmpty) {
      return null;
    }

    return Encryption(
        algorithm: algorithm,
        compression: json["compression"],
// Fallback on [original-length] for legacy reasons
// See https://github.com/readium/webpub-manifest/pull/43
        originalLength:
            (json["originalLength"] ?? json["original-length"]) as int?,
        profile: json["profile"],
        scheme: json["scheme"]);
  }
}
