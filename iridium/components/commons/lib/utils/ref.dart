// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Smart pointer holding a mutable reference to an object.
///
/// Get the reference by calling `ref()`
/// Conveniently, the reference can be reset by setting the `ref` property.
class Ref<T> {
  T? ref;
  T? call() => ref;
}
