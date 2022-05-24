// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("get Properties {encryption} when available", () {
    expect(
        Encryption(algorithm: "http://algo", compression: "gzip"),
        Properties(otherProperties: {
          "encrypted": {"algorithm": "http://algo", "compression": "gzip"}
        }).encryption);
  });

  test("get Properties {encryption} when missing", () {
    expect(Properties().encryption, isNull);
  });

  test("get Properties {encryption} when not valid", () {
    expect(Properties(otherProperties: {"encrypted": "invalid"}).encryption,
        isNull);
  });
}
