// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class Drm {
  static const Drm lcp = Drm._("lcp", "http://readium.org/2014/01/lcp");
  final String brand;
  final String scheme;

  const Drm._(this.brand, this.scheme);

  @override
  String toString() => 'Drm{brand: $brand, scheme: $scheme}';
}
