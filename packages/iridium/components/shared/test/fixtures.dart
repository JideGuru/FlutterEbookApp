// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:universal_io/io.dart' hide Link;

class Fixtures {
  final String? path;

  const Fixtures({this.path});

  String pathAt(String resourcePath) =>
      this.path?.let((it) => "$it/$resourcePath") ?? resourcePath;

  File fileAt(String resourcePath) => File(pathAt(resourcePath));
}
