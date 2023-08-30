// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';

/// Library-specific feature that contains information about the copies that a library has acquired.
///
/// https://drafts.opds.io/schema/properties.schema.json
class Copies with EquatableMixin implements JSONable {
  final int? total;
  final int? available;

  Copies({this.total, this.available});

  @override
  List<Object?> get props => [
        total,
        available,
      ];

  /// Serializes an [Copies] to its JSON representation.
  @override
  Map<String, dynamic> toJson() => {
        if (total != null) "total": total,
        if (available != null) "available": available,
      };

  /// Creates an [Copies] from its JSON representation.
  static Copies? fromJSON(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return Copies(
        total: json.optPositiveInt("total"),
        available: json.optPositiveInt("available"));
  }
}
