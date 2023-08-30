/*
 * Module: r2-streamer-kotlin
 * Developers: Aferdita Muriqi, Clément Baumann
 *
 * Copyright (c) 2018. Readium Foundation. All rights reserved.
 * Use of this source code is governed by a BSD-style license which is detailed in the
 * LICENSE file present in the project repository where this source code is maintained.
 */

import 'package:mno_commons/utils/injectable.dart';

class Resources {
  final Map<String, dynamic> resources = {};

  void add(String key, String body, {Injectable? injectable}) {
    if (injectable != null) {
      resources[key] = (body, injectable.rawValue);
    } else {
      resources[key] = body;
    }
  }

  String? get(String key) {
    var resource = resources[key];
    if (resource is (String, String)) {
      return resource.$1;
    }
    return resource as String?;
  }
}
