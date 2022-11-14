// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_navigator/src/epub/settings/value_settings.dart';

class LineHeight with EquatableMixin implements ValueSettings {
  static const LineHeight factor_1_0 = LineHeight._(0, 1.0);
  static const LineHeight factor_1_25 = LineHeight._(1, 1.25);
  static const LineHeight factor_1_5 = LineHeight._(2, 1.5);
  static const LineHeight factor_1_75 = LineHeight._(3, 1.75);
  static const LineHeight factor_2_0 = LineHeight._(4, 2.0);
  static const LineHeight factor_2_25 = LineHeight._(5, 2.25);
  static const List<LineHeight> values = [
    factor_1_0,
    factor_1_25,
    factor_1_5,
    factor_1_75,
    factor_2_0,
    factor_2_25,
  ];

  @override
  final int id;
  @override
  final double value;

  const LineHeight._(this.id, this.value);

  @override
  List<Object> get props => [value];

  static LineHeight from(int id) =>
      values.firstWhere((type) => type.id == id, orElse: () => factor_1_0);

  @override
  String toString() => 'LineHeight{id: $id, value: $value}';
}
