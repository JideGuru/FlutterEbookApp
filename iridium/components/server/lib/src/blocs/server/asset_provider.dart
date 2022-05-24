// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// This class abstract how a resource is retrieved.
///
/// The implementations should be platform specific (JS and Native)
abstract class AssetProvider {
  /// This method retrieve data associated with a specific [path]
  Future<ByteData> load(String path);
}
