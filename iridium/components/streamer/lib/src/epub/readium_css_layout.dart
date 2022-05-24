// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

/// Readium CSS layout.
class ReadiumCssLayout {
  /// Right to left
  static const ReadiumCssLayout rtl = ReadiumCssLayout._("rtl");

  /// Left to right
  static const ReadiumCssLayout ltr = ReadiumCssLayout._("ltr");

  /// Asian language, vertically laid out
  static const ReadiumCssLayout cjkVertical =
      ReadiumCssLayout._("cjk-vertical");

  /// Asian language, horizontally laid out
  static const ReadiumCssLayout cjkHorizontal =
      ReadiumCssLayout._("cjk-horizontal");

  /// [cssId] that correspond to a particular [ReadiumCssLayout].
  final String cssId;
  const ReadiumCssLayout._(this.cssId);

  /// Returns the readium CSS path.
  String get readiumCSSPath {
    switch (this) {
      case ltr:
        return "";
      case rtl:
        return "rtl/";
      case cjkVertical:
        return "cjk-vertical/";
      case cjkHorizontal:
        return "cjk-horizontal/";
    }
    return "";
  }

  /// Determines the [ReadiumCssLayout] for the given [metadata].
  static ReadiumCssLayout findWithMetadata(Metadata metadata) => find(
      languages: metadata.languages,
      readingProgression: metadata.effectiveReadingProgression);

  /// Determines the [ReadiumCssLayout] for the given BCP 47 language codes and
  /// [readingProgression].
  /// Defaults to [ltr].
  static ReadiumCssLayout find(
      {required List<String> languages,
      required ReadingProgression readingProgression}) {
    bool isCjk;
    if (languages.length == 1) {
      String language = languages[0].split("-")[0]; // Remove region
      isCjk = ["zh", "ja", "ko"].contains(language);
    } else {
      isCjk = false;
    }

    if (readingProgression == ReadingProgression.rtl ||
        readingProgression == ReadingProgression.btt) {
      return (isCjk) ? cjkVertical : rtl;
    }
    return (isCjk) ? cjkHorizontal : ltr;
  }
}
