// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';

/// This construct enables a serializable representation of a DOM Range.
///
/// In a DOM Range object, the startContainer + startOffset tuple represents the [start] boundary
/// point. Similarly, the the endContainer + endOffset tuple represents the [end] boundary point.
/// In both cases, the start/endContainer property is a pointer to either a DOM text node, or a DOM
/// element (this typically depends on the mechanism from which the DOM Range instance originates,
/// for example when obtaining the currently-selected document fragment using the `window.selection`
/// API). In the case of a DOM text node, the start/endOffset corresponds to a position within the
/// character data. In the case of a DOM element node, the start/endOffset corresponds to a position
/// that designates a child text node.
///
/// Note that [end] field is optional. When only the start field is specified, the domRange object
/// represents a "collapsed" range that has identical [start] and [end] boundary points.
///
/// https://github.com/readium/architecture/blob/master/models/locators/extensions/html.md#the-domrange-object
///
/// @param start A serializable representation of the "start" boundary point of the DOM Range.
/// @param end A serializable representation of the "end" boundary point of the DOM Range.
class DomRange with EquatableMixin implements JSONable {
  final Point start;
  final Point? end;

  DomRange({required this.start, this.end});

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{}.also((json) {
        json.putJSONableIfNotEmpty("start", start);
        json.putJSONableIfNotEmpty("end", end);
      });

  @override
  List<Object?> get props => [start, end];

  static DomRange? fromJson(Map<String, dynamic>? json) {
    Point? start = Point.fromJson(json?.optJSONObject("start"));
    if (start == null) {
      return null;
    }

    return DomRange(
        start: start, end: Point.fromJson(json?.optJSONObject("end")));
  }
}

/// A serializable representation of a boundary point in a DOM Range.
///
/// The [cssSelector] field always references a DOM element. If the original DOM Range
/// start/endContainer property references a DOM text node, the [textNodeIndex] field is used to
/// complement the CSS Selector; thereby providing a pointer to a child DOM text node; and
/// [charOffset] is used to tell a position within the character data of that DOM text node
/// (just as the DOM Range start/endOffset does). If the original DOM Range start/endContainer
/// property references a DOM Element, then the [textNodeIndex] field is used to designate the
/// child Text node (just as the DOM Range start/endOffset does), and the optional [charOffset]
/// field is not used (as there is no explicit position within the character data of the text
/// node).
///
/// https://github.com/readium/architecture/blob/master/models/locators/extensions/html.md#the-start-and-end-object
class Point with EquatableMixin implements JSONable {
  final String cssSelector;
  final int textNodeIndex;
  final int? charOffset;

  Point(
      {required this.cssSelector,
      required this.textNodeIndex,
      this.charOffset});

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{}.also((json) {
        json.putOpt("cssSelector", cssSelector);
        json.putOpt("textNodeIndex", textNodeIndex);
        json.putOpt("charOffset", charOffset);
      });

  @override
  List<Object?> get props => [cssSelector, textNodeIndex, charOffset];

  static Point? fromJson(Map<String, dynamic>? json) {
    String? cssSelector = json?.optNullableString("cssSelector");
    int? textNodeIndex = json?.optPositiveInt("textNodeIndex");
    if (cssSelector == null || textNodeIndex == null) {
      return null;
    }

    return Point(
        cssSelector: cssSelector,
        textNodeIndex: textNodeIndex,
        charOffset: json.optPositiveInt("charOffset")
            // The model was using `offset` before, so we still parse it to ensure
            // backward-compatibility for reading apps having persisted legacy Locator
            // models.
            ??
            json.optPositiveInt("offset"));
  }
}
