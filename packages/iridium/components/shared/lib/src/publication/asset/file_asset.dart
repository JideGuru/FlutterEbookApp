// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/io.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/mediatype/mediatype.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart' hide Link;

/// Represents a publication stored as a file on the local file system.
///
/// @param file File on the file system.
class FileAsset extends PublicationAsset {
  final FileSystemEntity file;
  final MediaType? knownMediaType;
  final String? mediaTypeHint;
  MediaType? _mediaType;

  /// Creates a [FileAsset] from a [File] and an optional media type, when known or an optional media type hint.
  /// Providing a media type hint will improve performances when sniffing the media type.
  FileAsset(this.file, {this.knownMediaType, this.mediaTypeHint});

  @override
  String get name => basename(file.path);

  @override
  Future<MediaType> get mediaType async => await getMediaType();

  Future<MediaType> getMediaType() async {
    if (_mediaType != null) {
      return Future.value(_mediaType);
    }

    if (knownMediaType != null) {
      _mediaType = knownMediaType;
      return Future.value(_mediaType ??= knownMediaType);
    }

    MediaType? ofFile =
        await MediaType.ofFileWithSingleHint(file, mediaType: mediaTypeHint);

    if (ofFile != null) {
      return _mediaType ??= ofFile;
    }

    return _mediaType ??= MediaType.binary;
  }

  @override
  Future<Try<Fetcher, OpeningException>> createFetcher(
      PublicationAssetDependencies dependencies, String? credentials,
      {bool useSniffers = true}) async {
    try {
      Fetcher? fetcher;
      if (await FileSystemEntity.isDirectory(file.path)) {
        fetcher = FileFetcher.single(href: "/", file: file);
      } else if (await file.exists()) {
        if ((await mediaType).isZip) {
          fetcher = await ArchiveFetcher.fromPath(file.path,
              archiveFactory: dependencies.archiveFactory,
              useSniffers: useSniffers);
        } else {
          fetcher = FileFetcher.single(href: "/$name", file: file);
        }
      } else {
        throw FileNotFoundException(file.path);
      }
      return Try.success(fetcher);
    } on FileNotFoundException {
      return Try.failure(OpeningException.notFound);
    }
  }

  @override
  String toString() => '$runtimeType{${file.path}}';
}
