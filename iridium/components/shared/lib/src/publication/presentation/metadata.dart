// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

extension PresentionMetadataExtension on Metadata {
  Presentation get presentation =>
      Presentation.fromJson((this["presentation"] as Map<String, dynamic>?));
}
