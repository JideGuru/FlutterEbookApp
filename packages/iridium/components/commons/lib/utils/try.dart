// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class Try<Success, Failure extends Exception> {
  final Success? success;
  final Failure? failure;

  Try.success(this.success) : failure = null;

  Try.failure(this.failure) : success = null;

  bool get isSuccess => success != null;

  bool get isFailure => failure != null;

  /// Returns the encapsulated value if this instance represents success
  /// or throws the encapsulated Throwable exception if it is failure.
  Success getOrThrow() {
    if (isSuccess) {
      return success!;
    }
    throw failure!;
  }

  @override
  String toString() => '$runtimeType{success: $success, failure: $failure}';

  /// Returns the encapsulated value if this instance represents success or null if it is failure. */
  Success? getOrNull() => success;

  /// Returns the encapsulated [Throwable] exception if this instance represents failure or null if it is success. */
  Failure? exceptionOrNull() => failure;

  Success getOrElse(Success Function(Failure) onFailure) {
    if (isSuccess) {
      return getOrThrow();
    } else {
      return onFailure(exceptionOrNull()!);
    }
  }

  /// Performs the given action on the encapsulated value if this instance represents success.
  /// Returns the original [Try] unchanged.
  Try<Success, Failure> onSuccess(void Function(Success) action) {
    if (isSuccess) {
      action(getOrThrow());
    }
    return this;
  }

  /// Performs the given action on the encapsulated [Throwable] exception if this instance represents failure.
  /// Returns the original [Try] unchanged.
  Try<Success, Failure> onFailure(void Function(Failure) action) {
    if (isFailure) {
      action(exceptionOrNull()!);
    }
    return this;
  }

  /// Returns the encapsulated result of the given transform function applied to the encapsulated value
  /// if this instance represents success or the original encapsulated [Throwable] exception if it is failure.
  ///
  Try<R, Failure> map<R>(R Function(Success value) transform) {
    if (isSuccess) {
      return Try.success(transform(getOrThrow()));
    } else {
      return Try.failure(exceptionOrNull());
    }
  }

  Try<R, Failure> flatMap<R>(
      Try<R, Failure> Function(Success value) transform) {
    if (isSuccess) {
      return transform(getOrThrow());
    } else {
      return Try.failure(exceptionOrNull());
    }
  }
}
