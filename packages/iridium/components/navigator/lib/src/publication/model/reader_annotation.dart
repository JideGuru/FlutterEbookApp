// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class ReaderAnnotation with JSONable {
  final String id;
  final String bookId;
  String location;
  String? annotation;
  HighlightStyle? style;
  int? tint;
  final AnnotationType annotationType;

  ReaderAnnotation(this.id, this.bookId, this.location, this.annotationType,
      {this.annotation, this.style, this.tint});

  ReaderAnnotation.locator(
      this.id, this.bookId, Locator locator, this.annotationType,
      {this.annotation, this.style, this.tint})
      : location = locator.json;

  Locator? get locator => Locator.fromJsonString(location);

  set locator(Locator? locator) => location = locator?.json ?? "{}";

  bool get isHighlight => annotationType == AnnotationType.highlight;

  bool get isBookmark => annotationType == AnnotationType.bookmark;

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "bookId": bookId,
        "location": location,
        if (annotation != null) "annotation": annotation!,
        "annotationType": annotationType.id,
        if (style != null) "style": style!.id,
        if (tint != null) "tint": tint!,
      };

  static ReaderAnnotation fromJson(Map<String, dynamic> json) =>
      ReaderAnnotation(
        json["id"],
        json["bookId"],
        json["location"],
        AnnotationType.from(json["annotationType"] as int),
        annotation: json["annotation"],
        style: HighlightStyle.from(json["style"] as int? ?? -1),
        tint: json["tint"] as int?,
      );

  @override
  String toString() => '$runtimeType{id: $id, '
      'bookId: $bookId, '
      'location: $location, '
      'annotation: $annotation, '
      'style: $style, '
      'tint: $tint, '
      'annotationType: $annotationType}';
}
