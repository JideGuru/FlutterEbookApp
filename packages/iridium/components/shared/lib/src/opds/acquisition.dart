// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/mediatype.dart';

/// OPDS Acquisition Object.
///
/// https://drafts.opds.io/schema/acquisition-object.schema.json
class Acquisition with EquatableMixin implements JSONable {
  final String type;
  final List<Acquisition> children;

  Acquisition({required this.type, this.children = const []});

  /// Media type of the resource to acquire. */
  MediaType get mediaType => MediaType.parse(type) ?? MediaType.binary;

  @override
  List<Object> get props => [
        type,
        children,
      ];

  @override
  String toString() => 'Acquisition{type: $type, children: $children}';

  /// Serializes an [Acquisition] to its JSON representation.
  @override
  Map<String, dynamic> toJson() => {
        "type": type,
        if (children.isNotEmpty) "child": children,
      };

  /// Creates an [Acquisition] from its JSON representation.
  /// If the acquisition can't be parsed, a warning will be logged with [warnings].
  static Acquisition? fromJSON(Map<String, dynamic>? json) {
    String? type = json?.optNullableString("type");
    if (type == null) {
      return null;
    }

    return Acquisition(
      type: type,
      children: fromJSONArray(json.optJSONArray("child")),
    );
  }

  /// Creates a list of [Acquisition] from its JSON representation.
  /// If an acquisition can't be parsed, a warning will be logged with [warnings].
  static List<Acquisition> fromJSONArray(List<dynamic>? json) =>
      json?.parseObjects(
          (it) => Acquisition.fromJSON(it as Map<String, dynamic>?)) ??
      [];
}
