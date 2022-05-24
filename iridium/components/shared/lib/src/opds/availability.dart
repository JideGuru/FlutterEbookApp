// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';

/// Indicated the availability of a given resource.
///
/// https://drafts.opds.io/schema/properties.schema.json
///
/// @param since Timestamp for the previous state change.
/// @param until Timestamp for the next state change.
class Availability with EquatableMixin implements JSONable {
  final AvailabilityState state;
  final DateTime? since;
  final DateTime? until;

  Availability({required this.state, this.since, this.until});

  @override
  List<Object?> get props => [
        state,
        since,
        until,
      ];

  /// Serializes an [Availability] to its JSON representation.
  @override
  Map<String, dynamic> toJson() => {
        "state": state.value,
        if (since != null) "since": since?.toIso8601String(),
        if (until != null) "until": until?.toIso8601String(),
      };

  /// Creates an [Availability] from its JSON representation.
  /// If the availability can't be parsed, a warning will be logged with [warnings].
  static Availability? fromJSON(Map<String, dynamic>? json) {
    AvailabilityState? state =
        AvailabilityState.from(json?.optNullableString("state"));
    if (state == null) {
      return null;
    }
    return Availability(
        state: state,
        since: json?.optNullableString("since")?.iso8601ToDate(),
        until: json?.optNullableString("until")?.iso8601ToDate());
  }
}

class AvailabilityState {
  static const AvailabilityState available = AvailabilityState._("available");
  static const AvailabilityState unavailable =
      AvailabilityState._("unavailable");
  static const AvailabilityState reserved = AvailabilityState._("reserved");
  static const AvailabilityState ready = AvailabilityState._("ready");
  static const List<AvailabilityState> _values = [
    available,
    unavailable,
    reserved,
    ready
  ];
  final String value;

  const AvailabilityState._(this.value);

  static AvailabilityState? from(String? value) =>
      _values.firstOrNullWhere((state) => state.value == value);
}
