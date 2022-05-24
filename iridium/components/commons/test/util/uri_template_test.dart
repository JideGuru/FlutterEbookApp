// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/uri_template.dart';
import 'package:test/test.dart';

void main() {
  test("parameters works fine", () {
    expect(["x", "hello", "y", "z", "w"],
        UriTemplate("/url{?x,hello,y}name{z,y,w}").parameters);
  });

  test("expand works fine with simple string templates", () {
    var template = UriTemplate("/url{x,hello,y}name{z,y,w}");
    var parameters = {
      "x": "aaa",
      "hello": "Hello, world",
      "y": "b",
      "z": "45",
      "w": "w"
    };
    expect("/urlaaa,Hello,%20world,bname45,b,w", template.expand(parameters));
  });

  test("expand works fine with form-style ampersand-separated templates", () {
    var template = UriTemplate("/url{?x,hello,y}name");
    var parameters = {"x": "aaa", "hello": "Hello, world", "y": "b"};
    expect(
        "/url?x=aaa&hello=Hello,%20world&y=bname", template.expand(parameters));

    expect(
        "https://lsd-test.edrlab.org/licenses/39ef1ff2-cda2-4219-a26a-d504fbb24c17/renew?end=2020-11-12T16:02:00.000%2B01:00&id=38dfd7ba-a80b-4253-a047-e6aa9c21d6f0&name=Pixel%203a",
        UriTemplate(
                "https://lsd-test.edrlab.org/licenses/39ef1ff2-cda2-4219-a26a-d504fbb24c17/renew{?end,id,name}")
            .expand({
          "id": "38dfd7ba-a80b-4253-a047-e6aa9c21d6f0",
          "name": "Pixel 3a",
          "end": "2020-11-12T16:02:00.000+01:00"
        }));
  });
}
