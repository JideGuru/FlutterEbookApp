// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/condition_predicate.dart';
import 'package:mno_commons/utils/condition_type.dart';

abstract class Predicate<T> {
  final bool dbOnly = true;

  List<ConditionPredicate> conditionsPredicate = [];

  static const Predicate acceptAll = AcceptAllPredicate();

  void addEqualsCondition(String field, Object value) {
    conditionsPredicate
        .add(ConditionPredicate(ConditionType.isEqualTo, field, value));
  }

  void addContainsCondition(String field, Object value) {
    conditionsPredicate
        .add(ConditionPredicate(ConditionType.contains, field, value));
  }

  void addGreaterThanCondition(String field, Object value) {
    conditionsPredicate
        .add(ConditionPredicate(ConditionType.isGreaterThan, field, value));
  }

  void addArrayContainsCondition(String field, String value) {
    conditionsPredicate
        .add(ConditionPredicate(ConditionType.arrayContains, field, value));
  }

  void addValueInCondition(String field, List<Object> values) {
    //Cette requête renvoie document dans lequel le field est = a l'une des valeurs.
    _addInArrayCondition(field, values, ConditionType.whereIn);
  }

  void addArrayContainsAnyCondition(String field, List<Object> values) {
    //renvoie tous les documents dont field est un tableau qui contient EXACTEMENT
    // l'un des éléments présent dans value (adapté pour rehcerhce un doc par l'un des metadata de la liste value)
    _addInArrayCondition(field, values, ConditionType.arrayContainsAny);
  }

  void _addInArrayCondition(
      String field, List<Object> value, ConditionType conditionType) {
    conditionsPredicate.add(ConditionPredicate(conditionType, field, value));
  }

  bool test(T element);

  @override
  String toString() =>
      'Predicate{dbOnly: $dbOnly, conditionsPredicate: $conditionsPredicate}';
}

class AcceptAllPredicate<T> implements Predicate<T> {
  const AcceptAllPredicate();

  @override
  bool test(T element) => true;

  @override
  void addEqualsCondition(String field, Object value) {}

  @override
  void addContainsCondition(String field, Object value) {}

  @override
  void _addInArrayCondition(
      String field, List<Object> value, ConditionType conditionType) {}

  @override
  void addValueInCondition(String field, List<Object> value) {}

  @override
  List<ConditionPredicate> get conditionsPredicate => [];

  @override
  set conditionsPredicate(List<ConditionPredicate> conditionsPredicate) {}

  @override
  bool get dbOnly => true;

  @override
  void addGreaterThanCondition(String field, Object value) {}

  @override
  void addArrayContainsAnyCondition(String field, List<Object> value) {}

  @override
  void addArrayContainsCondition(String field, String value) {}

  void addArrayContainsAllCondition(String field, List<Object> values) {}

  @override
  void addValueNotInCondition(String field, List<Object> values) {}
}
