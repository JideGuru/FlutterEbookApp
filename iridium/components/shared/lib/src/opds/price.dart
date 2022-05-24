// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';

/// The price of a publication in an OPDS link.
///
/// https://drafts.opds.io/schema/properties.schema.json
///
/// @param currency Currency for the price, eg. EUR.
/// @param value Price value, should only be used for display purposes, because of precision issues
///     inherent with Double and the JSON parsing.
class Price with EquatableMixin implements JSONable {
  final String currency;
  final double value;

  Price({required this.currency, required this.value});

  @override
  List<Object> get props => [
        currency,
        value,
      ];

  /// Serializes an [Price] to its JSON representation.
  @override
  Map<String, dynamic> toJson() => {
        "currency": currency,
        "value": value,
      };

  /// Creates an [Price] from its JSON representation.
  /// If the price can't be parsed, a warning will be logged with [warnings].
  static Price? fromJSON(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    String? currency = json.optNullableString("currency");
    double? value = json.optPositiveDouble("value");
    if (currency == null || value == null) {
      return null;
    }

    return Price(currency: currency, value: value);
  }
}
