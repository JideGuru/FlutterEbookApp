// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';

extension OpdsPropertiesExtension on Properties {
  /// Provides a hint about the expected number of items returned.
  int? get numberOfItems =>
      (this["numberOfItems"] as int?)?.takeIf((it) => it >= 0);

  /// The price of a publication is tied to its acquisition link.
  Price? get price =>
      (this["price"] as Map<String, dynamic>?)?.let((it) => Price.fromJSON(it));

  /// Indirect acquisition provides a hint for the expected media type that will be acquired after
  /// additional steps.
  List<Acquisition> get indirectAcquisitions =>
      (this["indirectAcquisition"] as List?)
          ?.mapNotNull((it) =>
              it is Map<String, dynamic> ? Acquisition.fromJSON(it) : null)
          .toList() ??
      [];

  /// Library-specific features when a specific book is unavailable but provides a hold list.
  Holds? get holds =>
      (this["holds"] as Map<String, dynamic>?)?.let((it) => Holds.fromJSON(it));

  /// Library-specific feature that contains information about the copies that a library has acquired.
  Copies? get copies => (this["copies"] as Map<String, dynamic>?)
      ?.let((it) => Copies.fromJSON(it));

  /// Indicated the availability of a given resource.
  Availability? get availability =>
      (this["availability"] as Map<String, dynamic>?)
          ?.let((it) => Availability.fromJSON(it));
}
