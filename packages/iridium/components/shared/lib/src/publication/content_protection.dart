// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:universal_io/io.dart' hide Link;

/// Bridge between a Content Protection technology and the Readium toolkit.
///
/// Its responsibilities are to:
/// - Unlock a publication by returning a customized [Fetcher].
/// - Create a [ContentProtectionService] publication service.
mixin ContentProtection {
  /// Attempts to unlock a potentially protected file.
  ///
  /// The Streamer will create a leaf [fetcher] for the low-level [file] access (e.g.
  /// ArchiveFetcher for a ZIP archive), to avoid having each Content Protection open the file to
  /// check if it's protected or not.
  ///
  /// A publication might be protected in such a way that the package format can't be recognized,
  /// in which case the Content Protection will have the responsibility of creating a new leaf
  /// [Fetcher].
  ///
  /// @return A [ProtectedAsset] in case of success, null if the file is not protected by this
  /// technology or a [UserException] if the file can't be successfully opened,
  /// even in restricted mode.
  Future<Try<ProtectedAsset, UserException>?> open(
      PublicationAsset asset,
      Fetcher fetcher,
      String? credentials,
      bool allowUserInteraction,
      dynamic sender);
}

/// Holds the result of opening a [File] with a [ContentProtection].
///
/// @property file Protected file which will be provided to the parsers.
/// In most cases, this will be the file provided to ContentProtection::open(),
/// but a Content Protection might modify it in some cases:
/// - If the original file has a media type that can't be recognized by parsers,
///   the Content Protection must return a file with the matching unprotected media type.
/// - If the Content Protection technology needs to redirect the Streamer to a different file.
///   For example, this could be used to decrypt a publication to a temporary secure location.
///
/// @property fetcher Primary leaf fetcher to be used by parsers.
/// The Content Protection can unlock resources by modifying the Fetcher provided to
/// ContentProtection::open(), for example by:
/// - Wrapping the given fetcher in a TransformingFetcher with a decryption Resource.Transformer
///   function.
/// - Discarding the provided fetcher altogether and creating a new one to handle access
///   restrictions. For example, by creating an HTTPFetcher which will inject a Bearer Token in
///   requests.
///
/// @property onCreatePublication Called on every parsed Publication.Builder.
/// It can be used to modify the `Manifest`, the root [Fetcher] or the list of service factories
/// of a [Publication].
class ProtectedAsset {
  final PublicationAsset asset;
  final Fetcher fetcher;
  final void Function(ServicesBuilder) onCreatePublication;

  ProtectedAsset(
      {required this.asset,
      required this.fetcher,
      required this.onCreatePublication});
}
