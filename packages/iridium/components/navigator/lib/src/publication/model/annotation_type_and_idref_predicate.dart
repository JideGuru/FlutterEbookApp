// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class AnnotationTypeAndDocumentPredicate extends Predicate<ReaderAnnotation> {
  final String href;
  final AnnotationType annotationType;

  AnnotationTypeAndDocumentPredicate(this.href, this.annotationType) {
    addEqualsCondition("annotationType", annotationType.id);
  }

  @override
  bool test(ReaderAnnotation element) =>
      element.annotationType == annotationType && element.href == href;
}

extension _ReaderAnnotationExt on ReaderAnnotation {
  String? get href => Locator.fromJsonString(location)?.href;
}
