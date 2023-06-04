// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("parse reading progression", () {
    expect(ReadingProgression.ltr, ReadingProgression.fromValue("LTR"));
    expect(ReadingProgression.ltr, ReadingProgression.fromValue("ltr"));
    expect(ReadingProgression.rtl, ReadingProgression.fromValue("rtl"));
    expect(ReadingProgression.ttb, ReadingProgression.fromValue("ttb"));
    expect(ReadingProgression.btt, ReadingProgression.fromValue("btt"));
    expect(ReadingProgression.auto, ReadingProgression.fromValue("auto"));
    expect(ReadingProgression.auto, ReadingProgression.fromValue("foobar"));
    expect(ReadingProgression.auto, ReadingProgression.fromValue(null));
  });

  test("get reading progression value", () {
    expect("ltr", ReadingProgression.ltr.value);
    expect("rtl", ReadingProgression.rtl.value);
    expect("ttb", ReadingProgression.ttb.value);
    expect("btt", ReadingProgression.btt.value);
    expect("auto", ReadingProgression.auto.value);
  });
}
