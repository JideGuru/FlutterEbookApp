// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class PotentialRights {
  DateTime? end;

  PotentialRights._(this.end);

  factory PotentialRights.parse(Map json) =>
      PotentialRights._(DateTime.tryParse(json["end"]));

  @override
  String toString() => 'PotentialRights{end: $end}';
}
