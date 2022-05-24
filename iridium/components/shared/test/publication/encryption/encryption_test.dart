// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse minimal JSON", () {
    expect(Encryption(algorithm: "http://algo"),
        Encryption.fromJSON('{"algorithm": "http://algo"}'.toJsonOrNull()));
  });

  test("parse full JSON", () {
    expect(
        Encryption(
            algorithm: "http://algo",
            compression: "gzip",
            originalLength: 42099,
            profile: "http://profile",
            scheme: "http://scheme"),
        Encryption.fromJSON("""{
                "algorithm": "http://algo",
                "compression": "gzip",
                "originalLength": 42099,
                "profile": "http://profile",
                "scheme": "http://scheme"
            }"""
            .toJsonOrNull()));
  });

  test("parse null JSON", () {
    expect(Encryption.fromJSON(null), isNull);
  });

  test("parse JSON requires {algorithm}", () {
    expect(
        Encryption.fromJSON('{"compression"": "gzip"}'.toJsonOrNull()), isNull);
  });

  test("get minimal JSON", () {
    expect('{"algorithm": "http://algo"}'.toJsonOrNull(),
        Encryption(algorithm: "http://algo").toJson());
  });

  test("get full JSON", () {
    // We build directly the map because [JSONObject] uses [Int] instead of [Long], which
    // doesn't match [originalLength].
    expect(
        {
          "algorithm": "http://algo",
          "compression": "gzip",
          "originalLength": 42099,
          "profile": "http://profile",
          "scheme": "http://scheme"
        },
        Encryption(
                algorithm: "http://algo",
                compression: "gzip",
                originalLength: 42099,
                profile: "http://profile",
                scheme: "http://scheme")
            .toJson());
  });
}
