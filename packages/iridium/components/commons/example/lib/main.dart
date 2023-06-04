// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';

void main() {
  Map<String, dynamic> json = """{
            "a": 1,
            "b": { "b.1": "hello" },
            "c": [true, 42, "world"]
        }"""
      .toJsonOrNull()!;
  assert(json["a"] == 1);
  _Person person1 = _Person("Stewart", "Marion");
  json.putJSONableIfNotEmpty("person1", person1);
  print("person1: ${json["person1"]}");
  _Person person2 = _Person(null, null);
  json.putJSONableIfNotEmpty("person2", person2);
  assert(json["person2"] == null);
}

class _Person with JSONable {
  final String? name;
  final String? firstname;

  _Person(this.name, this.firstname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{}
    ..putOpt("name", name)
    ..putOpt("firstname", firstname);
}
