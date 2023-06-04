// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_navigator/src/epub/settings/value_settings.dart';

class LetterSpacing with EquatableMixin implements ValueSettings {
  static const LetterSpacing factor_0 = LetterSpacing._(0, 0.0);
  static const LetterSpacing factor_0_0625 = LetterSpacing._(1, 0.0625);
  static const LetterSpacing factor_0_125 = LetterSpacing._(2, 0.125);
  static const LetterSpacing factor_0_1875 = LetterSpacing._(3, 0.1875);
  static const LetterSpacing factor_0_25 = LetterSpacing._(4, 0.25);
  static const LetterSpacing factor_0_3125 = LetterSpacing._(5, 0.3125);
  static const LetterSpacing factor_0_375 = LetterSpacing._(6, 0.375);
  static const LetterSpacing factor_0_4375 = LetterSpacing._(7, 0.4375);
  static const LetterSpacing factor_0_5 = LetterSpacing._(8, 0.5);
  static const List<LetterSpacing> values = [
    factor_0,
    factor_0_0625,
    factor_0_125,
    factor_0_1875,
    factor_0_25,
    factor_0_3125,
    factor_0_375,
    factor_0_4375,
    factor_0_5,
  ];

  @override
  final int id;
  @override
  final double value;

  const LetterSpacing._(this.id, this.value);

  @override
  List<Object> get props => [value];

  static LetterSpacing from(int id) =>
      values.firstWhere((type) => type.id == id, orElse: () => factor_0);

  @override
  String toString() => 'LetterSpacing{id: $id, value: $value}';
}
