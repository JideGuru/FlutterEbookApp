// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  test("get Properties {numberOfItems} when available", () {
    expect(
        42, Properties(otherProperties: {"numberOfItems": 42}).numberOfItems);
  });

  test("get Properties {numberOfItems} when missing", () {
    expect(Properties().numberOfItems, isNull);
  });

  test("Properties {numberOfItems} must be positive", () {
    expect(Properties(otherProperties: {"numberOfItems": -20}).numberOfItems,
        isNull);
  });

  test("get Properties {price} when available", () {
    expect(
        Price(currency: "EUR", value: 4.36),
        Properties(otherProperties: {
          "price": {"currency": "EUR", "value": 4.36}
        }).price);
  });

  test("get Properties {price} when missing", () {
    expect(Properties().price, isNull);
  });

  test("get Properties {indirectAcquisitions} when available", () {
    expect(
        [Acquisition(type: "acq1"), Acquisition(type: "acq2")],
        Properties(otherProperties: {
          "indirectAcquisition": [
            {"type": "acq1"},
            {"type": "acq2"}
          ]
        }).indirectAcquisitions);
  });

  test("get Properties {indirectAcquisitions} when missing", () {
    expect(0, Properties().indirectAcquisitions.length);
  });

  test("get Properties {holds} when available", () {
    expect(
        Holds(total: 5),
        Properties(otherProperties: {
          "holds": {"total": 5}
        }).holds);
  });

  test("get Properties {holds} when missing", () {
    expect(Properties().holds, isNull);
  });

  test("get Properties {copies} when available", () {
    expect(
        Copies(total: 5),
        Properties(otherProperties: {
          "copies": {"total": 5}
        }).copies);
  });

  test("get Properties {copies} when missing", () {
    expect(Properties().copies, isNull);
  });

  test("get Properties {availability} when available", () {
    expect(
        Availability(state: AvailabilityState.available),
        Properties(otherProperties: {
          "availability": {"state": "available"}
        }).availability);
  });

  test("get Properties {availability} when missing", () {
    expect(Properties().availability, isNull);
  });
}
