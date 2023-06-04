// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class Rights {
  int? print;
  int? copy;
  DateTime? start;
  DateTime? end;
  Map extensions;

  Rights._(this.print, this.copy, this.start, this.end, this.extensions);

  factory Rights.parse(Map json) {
    int? print = json.remove("print");
    int? copy = json.remove("copy");
    DateTime? start;
    if (json.containsKey("start")) {
      start = DateTime.tryParse(json.remove("start"));
    }
    DateTime? end;
    if (json.containsKey("end")) {
      end = DateTime.tryParse(json.remove("end"));
    }
    return Rights._(print, copy, start, end, json);
  }

  @override
  String toString() =>
      'Rights{print: $print, copy: $copy, start: $start, end: $end, extensions: $extensions}';
}
