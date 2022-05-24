// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/jsonable.dart';

class EpubReaderState implements JSONable {
  final String themeName;
  final int fontSize;

  EpubReaderState(this.themeName, this.fontSize);

  factory EpubReaderState.fromJson(Map<String, dynamic> json) =>
      EpubReaderState(json["themeName"], json["fontSize"] as int? ?? 100);

  @override
  Map<String, dynamic> toJson() => {
        'themeName': themeName,
        'fontSize': fontSize,
      };

  @override
  String toString() =>
      'EpubReaderState{themeName: $themeName, fontSize: $fontSize}';
}
