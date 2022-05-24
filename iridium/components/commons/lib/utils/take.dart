// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

extension Take<T> on T {
  T? takeIf(bool Function(T) predicate) => (predicate(this)) ? this : null;

  T? takeUnless(bool Function(T) predicate) => (!predicate(this)) ? this : null;
}
