// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/publication.dart';

class AnnotationTypePredicate extends Predicate<ReaderAnnotation> {
  final AnnotationType annotationType;

  AnnotationTypePredicate(this.annotationType) {
    addEqualsCondition("annotationType", annotationType.id);
  }

  @override
  bool test(ReaderAnnotation element) =>
      element.annotationType == annotationType;
}
