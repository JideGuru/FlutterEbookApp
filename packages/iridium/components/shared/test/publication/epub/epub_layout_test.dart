// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse layout", () {
    expect(EpubLayout.fixed, EpubLayout.from("fixed"));
    expect(EpubLayout.reflowable, EpubLayout.from("reflowable"));
    expect(EpubLayout.from("foobar"), isNull);
    expect(EpubLayout.from(null), isNull);
  });

  test("get layout value", () {
    expect("fixed", EpubLayout.fixed.value);
    expect("reflowable", EpubLayout.reflowable.value);
  });
}
