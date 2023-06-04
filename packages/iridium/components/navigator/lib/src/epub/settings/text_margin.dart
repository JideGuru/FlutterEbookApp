// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_navigator/src/epub/settings/value_settings.dart';

class TextMargin with EquatableMixin implements ValueSettings {
  static const TextMargin margin_0_5 = TextMargin._(0, 0.5);
  static const TextMargin margin_1_0 = TextMargin._(1, 1.0);
  static const TextMargin margin_1_5 = TextMargin._(2, 1.5);
  static const TextMargin margin_2_0 = TextMargin._(3, 2.0);
  static const TextMargin margin_2_5 = TextMargin._(4, 2.5);
  static const TextMargin margin_3_0 = TextMargin._(5, 3.0);
  static const List<TextMargin> values = [
    margin_0_5,
    margin_1_0,
    margin_1_5,
    margin_2_0,
    margin_2_5,
    margin_3_0,
  ];

  @override
  final int id;
  @override
  final double value;

  const TextMargin._(this.id, this.value);

  @override
  List<Object> get props => [value];

  static TextMargin from(int id) =>
      values.firstWhere((type) => type.id == id, orElse: () => margin_1_0);

  @override
  String toString() => 'TextMargin{id: $id, value: $value}';
}
