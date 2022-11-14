// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class AnnotationTypeAndDocumentPredicate extends Predicate<ReaderAnnotation> {
  final String idref;
  final AnnotationType annotationType;

  AnnotationTypeAndDocumentPredicate(this.idref, this.annotationType);

  @override
  bool test(ReaderAnnotation element) =>
      element.annotationType == annotationType && element.idref == idref;
}

extension _ReaderAnnotationExt on ReaderAnnotation {
  String get idref => ReadiumLocation.createLocation(location).idref;
}
