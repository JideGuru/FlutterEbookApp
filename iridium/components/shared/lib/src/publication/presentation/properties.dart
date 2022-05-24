// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

extension PresentionPropertiesExtension on Properties {
  /// Specifies whether or not the parts of a linked resource that flow out of the viewport are
  /// clipped.
  bool? get clipped => this["clipped"] as bool?;

  /// Suggested method for constraining a resource inside the viewport.
  PresentationFit? get fit => PresentationFit.from(this["fit"] as String?);

  /// Suggested orientation for the device when displaying the linked resource.
  PresentationOrientation? get orientation =>
      PresentationOrientation.from(this["orientation"] as String?);

  /// Suggested method for handling overflow while displaying the linked resource.
  PresentationOverflow? get overflow =>
      PresentationOverflow.from(this["overflow"] as String?);

  /// Indicates how the linked resource should be displayed in a reading environment that displays
  /// synthetic spreads.
  PresentationPage? get page => PresentationPage.from(this["page"] as String?);

  /// Indicates the condition to be met for the linked resource to be rendered within a synthetic
  /// spread.
  PresentationSpread? get spread =>
      PresentationSpread.from(this["spread"] as String?);
}
