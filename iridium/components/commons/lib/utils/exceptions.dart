// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Returns the result of the given [closure], or null if an [Exception] was raised.
T? tryOrNull<T>(T Function() closure) => tryOr(null, closure);

/// Returns the result of the given [closure], or [default] if an [Exception] was raised.
T? tryOr<T>(T? defaultValue, T Function() closure) {
  try {
    return closure();
  } on Exception {
    return defaultValue;
  }
}

/// Returns the result of the given [closure], or null if an [Exception] was raised.
Future<T?> waitTryOrNull<T>(Future<T?> Function() closure) =>
    waitTryOr(null, closure);

/// Returns the result of the given [closure], or [default] if an [Exception] was raised.
Future<T?> waitTryOr<T>(T? defaultValue, Future<T?> Function() closure) async {
  try {
    return await closure();
  } on Exception {
    return defaultValue;
  }
}
