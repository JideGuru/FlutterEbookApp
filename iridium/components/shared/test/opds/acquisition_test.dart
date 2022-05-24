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
import 'package:mno_shared/src/opds/acquisition.dart';
import 'package:test/test.dart';

void main() {
  test("parse minimal JSON acquisition", () {
    expect(Acquisition(type: "acquisition-type"),
        Acquisition.fromJSON('{"type": "acquisition-type"}'.toJsonOrNull()));
  });

  test("parse full JSON acquisition", () {
    expect(
        Acquisition(type: "acquisition-type", children: [
          Acquisition(type: "sub-acquisition", children: [
            Acquisition(type: "sub-sub1"),
            Acquisition(type: "sub-sub2")
          ])
        ]),
        Acquisition.fromJSON("""{
                "type": "acquisition-type",
                "child": [
                    {
                        "type": "sub-acquisition",
                        "child": [
                            { "type": "sub-sub1" },
                            { "type": "sub-sub2" }
                        ]
                    }
                ]
            }"""
            .toJsonOrNull()));
  });

  test("parse invalid JSON acquisition", () {
    expect(Acquisition.fromJSON("{}".toJsonOrNull()), isNull);
  });

  test("parse null JSON acquisition", () {
    expect(Acquisition.fromJSON(null), isNull);
  });

  test("parse JSON acquisition requires {type}", () {
    expect(Acquisition.fromJSON('{"child": []}'.toJsonOrNull()), isNull);
  });

  test("parse JSON acquisition array", () {
    expect(
        [Acquisition(type: "acq1"), Acquisition(type: "acq2")],
        Acquisition.fromJSONArray("""[
                { "type": "acq1" },
                { "type": "acq2" }
            ]"""
            .toJsonArrayOrNull()));
  });

  test("parse JSON acquisition array ignores invalid acquisitions", () {
    expect(
        [Acquisition(type: "acq1")],
        Acquisition.fromJSONArray("""[
                { "type": "acq1" },
                { "invalid": "acq2" }
            ]"""
            .toJsonArrayOrNull()));
  });

  /*

    @Test fun `parse null JSON acquisition array`() {
        assertEquals(
            emptyList<Acquisition>(),
            Acquisition.fromJSONArray(null)
        )
    }

    @Test fun `get minimal JSON acquisition`() {
        assertJSONEquals(
            JSONObject("{'type': 'acquisition-type'}"),
            Acquisition(type = "acquisition-type").toJSON()
        )
    }

    @Test fun `get full JSON acquisition`() {
        assertJSONEquals(
            JSONObject("""{
                "type": "acquisition-type",
                "child": [
                    {
                        "type": "sub-acquisition",
                        "child": [
                            { "type": "sub-sub1" },
                            { "type": "sub-sub2" }
                        ]
                    }
                ]
            }"""),
            Acquisition(
                type = "acquisition-type",
                children = listOf(
                    Acquisition(
                        type = "sub-acquisition",
                        children = listOf(
                            Acquisition(type = "sub-sub1"),
                            Acquisition(type = "sub-sub2")
                        )
                    )
                )
            ).toJSON()
        )
    }

    @Test fun `get JSON acquisition array`() {
        assertJSONEquals(
            JSONArray("""[
                { "type": "acq1" },
                { "type": "acq2" }
            ]"""),
            listOf(
                Acquisition(type = "acq1"),
                Acquisition(type = "acq2")
            ).toJSON()
        )
    }
   */
}
