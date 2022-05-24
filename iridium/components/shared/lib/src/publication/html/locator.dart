// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/publication/html/dom_range.dart';

extension LocationsExtension on Locations {
  /// A CSS Selector.
  String? get cssSelector => this["cssSelector"] as String?;

  /// [partialCfi] is an expression conforming to the "right-hand" side of the EPUB CFI syntax, that is
  /// to say: without the EPUB-specific OPF spine item reference that precedes the first ! exclamation
  /// mark (which denotes the "step indirection" into a publication document). Note that the wrapping
  /// epubcfi(***) syntax is not used for the [partialCfi] string, i.e. the "fragment" part of the CFI
  /// grammar is ignored.
  String? get partialCfi => this["partialCfi"] as String?;

  /// An HTML DOM range.
  DomRange? get domRange => (this["domRange"] as Map<String, dynamic>?)
      ?.let((it) => DomRange.fromJson(it));
}
