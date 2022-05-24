// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_navigator/src/epub/settings/value_settings.dart';

class WordSpacing with EquatableMixin implements ValueSettings {
  static const WordSpacing factor_0 = WordSpacing._(0, 0.0);
  static const WordSpacing factor_0_25 = WordSpacing._(1, 0.25);
  static const WordSpacing factor_0_5 = WordSpacing._(2, 0.5);
  static const List<WordSpacing> values = [
    factor_0,
    factor_0_25,
    factor_0_5,
  ];

  @override
  final int id;
  @override
  final double value;

  const WordSpacing._(this.id, this.value);

  @override
  List<Object> get props => [value];

  static WordSpacing from(int id) =>
      values.firstWhere((type) => type.id == id, orElse: () => factor_0);

  @override
  String toString() => 'WordSpacing{id: $id, value: $value}';
}
