// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/jsonable.dart';

class ScreenshotConfig implements JSONable {
  final int nbThumbnails;

  ScreenshotConfig(this.nbThumbnails);

  @override
  Map<String, dynamic> toJson() => {
        "nbThumbnails": nbThumbnails,
      };

  @override
  String toString() => 'ScreenshotConfig{nbThumbnails: $nbThumbnails}';
}
