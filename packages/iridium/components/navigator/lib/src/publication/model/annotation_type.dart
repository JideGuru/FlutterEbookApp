// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class AnnotationType {
  /// This annotation is a bookmark.
  static const bookmark = AnnotationType._(0, 'BOOKMARK');

  /// This annotation corresponds to a highlight.
  static const highlight = AnnotationType._(1, 'HIGHLIGHT');

  /// This annotation corresponds to a highlight.
  static const position = AnnotationType._(2, 'POSITION');
  static const List<AnnotationType> _values = [bookmark, highlight, position];
  final int id;
  final String name;

  const AnnotationType._(this.id, this.name);

  static AnnotationType from(int id) =>
      _values.firstWhere((type) => type.id == id, orElse: () => bookmark);

  @override
  String toString() => 'AnnotationType.$name';
}
