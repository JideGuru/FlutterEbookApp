// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class ConditionType {
  static const ConditionType isGreaterThan =
          ConditionType._(0, "isGreaterThan", 1, true),
      isLessThan = ConditionType._(1, "isLessThan", 1, true),
      isEqualTo = ConditionType._(2, "isEqualTo", 1, false),
      contains = ConditionType._(3, "isEqualTo", 1, true),
      arrayContainsAny = ConditionType._(4, "arrayContainsAny", 10, false),
      arrayContains = ConditionType._(5, "arrayContains", 10, false),
      whereIn = ConditionType._(6, "whereIn", 10, false),
      whereNotIn = ConditionType._(7, "whereNotIn", 10, true),
      arrayContainsAll = ConditionType._(8, "arrayContainsAll", 1, false);

  static const List<ConditionType> _values = [
    isGreaterThan,
    isLessThan,
    isEqualTo,
  ];

  final int id;
  final String name;

  // FOLLOWING Firestore Documentation https://firebase.google.com/docs/firestore/query-data/queries
  final int maxListItems;
  final bool inequalityOperator;

  const ConditionType._(
      this.id, this.name, this.maxListItems, this.inequalityOperator);

  static ConditionType from(int id) =>
      _values.firstWhere((type) => type.id == id);

  @override
  String toString() => 'ConditionType.$name';
}
