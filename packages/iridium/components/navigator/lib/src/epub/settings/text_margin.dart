// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_navigator/src/epub/settings/value_settings.dart';

class TextMargin with EquatableMixin implements ValueSettings {
  static const TextMargin margin_0 = TextMargin._(0, 0.0);
  static const TextMargin margin_10 = TextMargin._(1, 10.0);
  static const TextMargin margin_20 = TextMargin._(2, 20.0);
  static const TextMargin margin_30 = TextMargin._(3, 30.0);
  static const TextMargin margin_40 = TextMargin._(4, 40.0);
  static const TextMargin margin_50 = TextMargin._(5, 50.0);
  static const List<TextMargin> values = [
    margin_0,
    margin_10,
    margin_20,
    margin_30,
    margin_40,
    margin_50,
  ];

  @override
  final int id;
  @override
  final double value;

  const TextMargin._(this.id, this.value);

  @override
  List<Object> get props => [value];

  static TextMargin from(int id) =>
      values.firstWhere((type) => type.id == id, orElse: () => margin_20);

  @override
  String toString() => 'TextMargin{id: $id, value: $value}';
}
