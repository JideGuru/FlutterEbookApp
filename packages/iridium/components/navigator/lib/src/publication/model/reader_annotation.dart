// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class ReaderAnnotation {
  String id;

  String location;
  final AnnotationType annotationType;

  ReaderAnnotation(this.id, this.location, this.annotationType);

  ReaderAnnotation.locator(this.id, Locator locator, this.annotationType)
      : location = locator.json;

  Locator? get locator => Locator.fromJsonString(location);

  set locator(Locator? locator) => location = locator?.json ?? "{}";

  bool get isHighlight => annotationType == AnnotationType.highlight;

  bool get isBookmark => annotationType == AnnotationType.bookmark;

  @override
  String toString() =>
      'Bookmark{id: $id, location: $location, annotationType: $annotationType}';
}
