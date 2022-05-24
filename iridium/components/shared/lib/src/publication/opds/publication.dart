// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

extension OpdsPublicationExtension on Publication {
  List<Link> get images => linksWithRole("images");
}
