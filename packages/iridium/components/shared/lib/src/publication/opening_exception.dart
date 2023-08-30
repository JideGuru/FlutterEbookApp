// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/src/publication/user_exception.dart';

/// Errors occurring while opening a Publication.
class OpeningException extends UserException {
  //(@StringRes userMessageId: Int, cause: Throwable? = null)

  //(userMessageId, cause = cause)
  OpeningException._(super.userMessageId, {Exception? super.cause});

  /// The file format could not be recognized by any parser.
  static OpeningException get unsupportedFormat => OpeningException._(
      "r2_shared_publication_opening_exception_unsupported_format");

  /// The publication file was not found on the file system.
  static OpeningException get notFound =>
      OpeningException._("r2_shared_publication_opening_exception_not_found");

  /// The publication parser failed with the given underlying exception.
  static OpeningException parsingFailed(Exception cause) => OpeningException._(
      "r2_shared_publication_opening_exception_parsing_failed",
      cause: cause);

  /// We're not allowed to open the publication at all, for example because it expired.
  static OpeningException forbidden(Exception cause) =>
      OpeningException._("r2_shared_publication_opening_exception_forbidden",
          cause: cause);

  /// The publication can't be opened at the moment, for example because of a networking error.
  /// This error is generally temporary, so the operation may be retried or postponed.
  static OpeningException unavailable(Exception cause) =>
      OpeningException._("r2_shared_publication_opening_exception_unavailable",
          cause: cause);

  /// The provided credentials are incorrect and we can't open the publication in a
  /// `restricted` state (e.g. for a password-protected ZIP).
  static OpeningException get incorrectCredentials => OpeningException._(
      "r2_shared_publication_opening_exception_incorrect_credentials");
}
