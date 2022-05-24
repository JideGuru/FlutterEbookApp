// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

class Coord {
  final int x;
  final int y;

  const Coord._(this.x, this.y);

  factory Coord.fromJson(String coord) {
    Map<String, dynamic> json = const JsonCodec().decode(coord);
    return Coord._(json["x"], json["y"]);
  }

  @override
  String toString() => 'Coord{x: $x, y: $y}';
}
