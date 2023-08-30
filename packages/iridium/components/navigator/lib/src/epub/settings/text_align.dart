// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';

class TextAlign with EquatableMixin {
  static const TextAlign left = TextAlign._(0, "left");
  static const TextAlign center = TextAlign._(1, "center");
  static const TextAlign right = TextAlign._(2, "right");
  static const TextAlign justify = TextAlign._(3, "justify");
  static const List<TextAlign> values = [
    left,
    center,
    right,
    justify,
  ];

  final int id;
  final String name;

  const TextAlign._(this.id, this.name);

  @override
  List<Object> get props => [id];

  static TextAlign from(int id) =>
      values.firstWhere((type) => type.id == id, orElse: () => left);

  @override
  String toString() => 'TextAlign{id: $id, name: $name}';
}
