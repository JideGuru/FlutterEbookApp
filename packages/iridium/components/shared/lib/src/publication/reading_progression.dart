// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_shared/publication.dart';

/// Direction of the [Publication] reading progression.
class ReadingProgression with EquatableMixin {
  /// Left-to-right reading progression.
  static const ltr = ReadingProgression._("ltr");

  /// Right-to-left reading progression.
  static const rtl = ReadingProgression._("rtl");

  /// Top to bottom reading progression.
  static const ttb = ReadingProgression._("ttb");

  /// Bottom to top reading progression.
  static const btt = ReadingProgression._("btt");

  static const auto = ReadingProgression._("auto");
  static const List<ReadingProgression> _values = [ltr, rtl, ttb, btt, auto];

  /// Underlying enum value for [ReadingProgression]. To be used with `switch` to make sure the cases match all values.
  final String value;
  const ReadingProgression._(this.value);

  /// Creates from a BCP 47 language.
  factory ReadingProgression.fromLanguage(String language) {
    if (['ar', 'fa', 'he'].contains(language.toLowerCase())) {
      return ReadingProgression.rtl;
    } else {
      return ReadingProgression.ltr;
    }
  }
  factory ReadingProgression.fromValue(String? value) => _values
      .firstWhere((it) => it.value == value?.toLowerCase(), orElse: () => auto);

  /// Returns the leading [Page] for the [ReadingProgression].
  PresentationPage get leadingPage {
    switch (value) {
      case "ltr":
        return PresentationPage.left;
      case "rtl":
      default:
        return PresentationPage.right;
    }
  }

  @override
  List<Object> get props => [value];
}
