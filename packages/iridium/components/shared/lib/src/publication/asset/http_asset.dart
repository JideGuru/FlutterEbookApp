// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/fetcher/http_fetcher.dart';
import 'package:mno_shared/src/mediatype/mediatype.dart';
import 'package:path/path.dart';

/// Represents a publication stored on a server in an exploded form.
///
/// @param rootHref String.
class HttpAsset extends PublicationAsset {
  final String rootHref;
  final MediaType? knownMediaType;
  final String? mediaTypeHint;
  MediaType? _mediaType;

  /// Creates a [HttpAsset] from a [File] and an optional media type, when known or an optional media type hint.
  /// Providing a media type hint will improve performances when sniffing the media type.
  HttpAsset(this.rootHref, {this.knownMediaType, this.mediaTypeHint});

  @override
  String get name => basename(rootHref);

  @override
  Future<MediaType> get mediaType async => _mediaType ??= (knownMediaType ??
      mediaTypeHint?.let((it) => MediaType.parse(it)) ??
      MediaType.binary);

  @override
  Future<Try<Fetcher, OpeningException>> createFetcher(
          PublicationAssetDependencies dependencies, String? credentials,
          {bool useSniffers = true}) async =>
      Try.success(HttpFetcher(rootHref));

  @override
  String toString() => '$runtimeType{$rootHref}';
}
