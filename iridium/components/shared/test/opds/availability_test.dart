// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/src/opds/availability.dart';
import 'package:test/test.dart';

void main() {
  test("parse JSON availability state", () {
    expect(AvailabilityState.available, AvailabilityState.from("available"));
    expect(AvailabilityState.ready, AvailabilityState.from("ready"));
    expect(AvailabilityState.reserved, AvailabilityState.from("reserved"));
    expect(
        AvailabilityState.unavailable, AvailabilityState.from("unavailable"));
    expect(AvailabilityState.from("foobar"), isNull);
    expect(AvailabilityState.from(null), isNull);
  });

  test("get JSON availability state", () {
    expect("available", AvailabilityState.available.value);
    expect("ready", AvailabilityState.ready.value);
    expect("reserved", AvailabilityState.reserved.value);
    expect("unavailable", AvailabilityState.unavailable.value);
  });

  test("parse minimal JSON availability", () {
    expect(Availability(state: AvailabilityState.available),
        Availability.fromJSON('{"state": "available"}'.toJsonOrNull()));
  });

  test("parse full JSON availability", () {
    expect(
        Availability(
            state: AvailabilityState.available,
            since: "2001-01-01T12:36:27.000Z".iso8601ToDate(),
            until: "2001-02-01T12:36:27.000Z".iso8601ToDate()),
        Availability.fromJSON("""{
                "state": "available",
                "since": "2001-01-01T12:36:27.000Z",
                "until": "2001-02-01T12:36:27.000Z"
            }"""
            .toJsonOrNull()));
  });

  test("parse null JSON availability", () {
    expect(Availability.fromJSON(null), isNull);
  });

  test("parse JSON availability requires {state}", () {
    expect(
        Availability.fromJSON(
            "{ 'since': '2001-01-01T12:36:27+0000' }".toJsonOrNull()),
        null);
  });

  test("get minimal JSON availability", () {
    expect(Availability.fromJSON('{"state": "available"}'.toJsonOrNull()),
        Availability(state: AvailabilityState.available));
  });

  test("get full JSON availability", () {
    expect(
        """{
                "state": "available",
                "since": "2001-02-01T13:36:27.000Z",
                "until": "2001-02-01T13:36:27.000Z"
            }"""
            .toJsonOrNull(),
        Availability(
                state: AvailabilityState.available,
                since: "2001-02-01T13:36:27.000Z".iso8601ToDate(),
                until: "2001-02-01T13:36:27.000Z".iso8601ToDate())
            .toJson());
  });
}
