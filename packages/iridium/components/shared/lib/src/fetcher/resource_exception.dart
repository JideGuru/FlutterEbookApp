// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/src/publication/user_exception.dart';

/// Errors occurring while accessing a resource.
class ResourceException extends UserException {
  ResourceException._(super.userMessageId, {dynamic super.cause});

  static BadRequest badRequest(Map<String, String> parameters,
          {Exception? cause}) =>
      BadRequest._(parameters, cause: cause);

  /// Equivalent to a 404 HTTP error.
  static ResourceException get notFound =>
      ResourceException._("r2_shared_resource_exception_not_found");

  /// Equivalent to a 403 HTTP error.
  ///
  /// This can be returned when trying to read a resource protected with a DRM that is not
  /// unlocked.
  static ResourceException get forbidden =>
      ResourceException._("r2_shared_resource_exception_forbidden");

  /// Equivalent to a 503 HTTP error.
  ///
  /// Used when the source can't be reached, e.g. no Internet connection, or an issue with the
  /// file system. Usually this is a temporary error.
  static ResourceException get unavailable =>
      ResourceException._("r2_shared_resource_exception_unavailable");

  /// Equivalent to a 507 HTTP error.
  ///
  /// Used when the requested range is too large to be read in memory.
  static ResourceException outOfMemory(OutOfMemoryError cause) =>
      ResourceException._("r2_shared_resource_exception_out_of_memory",
          cause: cause);

  /// The request was cancelled by the caller.
  ///
  /// For example, when a coroutine is cancelled.
  static ResourceException get cancelled =>
      ResourceException._("r2_shared_resource_exception_cancelled");

  /// For any other error, such as HTTP 500.
  static ResourceException other(Exception cause) =>
      ResourceException._("r2_shared_resource_exception_other", cause: cause);

  static ResourceException wrap(dynamic e) {
    if (e is ResourceException) {
      return e;
    }
    // if (e is CancellationException) {
    //   return cancelled;
    // }
    if (e is OutOfMemoryError) {
      return outOfMemory(e);
    }
    return other(e);
  }
}

/// Equivalent to a 400 HTTP error.
class BadRequest extends ResourceException {
  final Map<String, String> parameters;

  BadRequest._(this.parameters, {Exception? cause})
      : super._("r2_shared_resource_exception_bad_request", cause: cause);
}
