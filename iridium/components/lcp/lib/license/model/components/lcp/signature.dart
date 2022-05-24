// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class Signature {
  final Uri algorithm;
  final String certificate;
  final String value;

  Signature._(this.algorithm, this.certificate, this.value);

  factory Signature.parse(Map json) => Signature._(
      Uri.parse(json["algorithm"]), json["certificate"], json["value"]);

  @override
  String toString() =>
      'Signature{algorithm: $algorithm, certificate: $certificate, value: $value}';
}
