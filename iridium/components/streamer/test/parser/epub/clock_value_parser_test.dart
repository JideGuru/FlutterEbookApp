// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_streamer/src/epub/clock_value_parser.dart';
import 'package:test/test.dart';

void main() {
  test("Full and partial clock values are rightly parsed", () {
    expect(ClockValueParser.parse("02:30:03"), 9003.0);
    expect(ClockValueParser.parse("50:00:10.25"), 180010.25);
    expect(ClockValueParser.parse(" 02:33"), 153.0);
    expect(ClockValueParser.parse("00:10.5"), 10.5);
  });

  test("Timecounts are rightly parsed", () {
    expect(ClockValueParser.parse("3.2h"), 11520.0);
    expect(ClockValueParser.parse("45min"), 2700.0);
    expect(ClockValueParser.parse(" 30s"), 30.0);
    expect(ClockValueParser.parse("5ms"), 0.005);
    expect(ClockValueParser.parse("12.467"), 12.467);
  });
}
