// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

/// Format of the [Publication] file.
class PublicationFormat extends Equatable {
  static const epub = PublicationFormat(PublicationFormatEnum.epub);
  static const video = PublicationFormat(PublicationFormatEnum.video);

  /// Underlying enum value for [Format]. To be used with `switch` to make sure the cases match all values.
  final PublicationFormatEnum value;
  const PublicationFormat(this.value);

  @override
  List<Object> get props => [value];

  /// Finds the [PublicationFormat] for the given [mimetype], or fallback on a [fileExtension].
  static PublicationFormat? fromMIMEType(String mimetype,
      {String? fileExtension}) {
    List<String> mimetypes = [mimetype];
    return PublicationFormat.fromMIMETypes(mimetypes,
        fileExtension: fileExtension);
  }

  /// Finds the [PublicationFormat] from a list of possible [mimetypes] or fallback on a [fileExtension].
  static PublicationFormat? fromMIMETypes(List<String> mimetypes,
      {String? fileExtension}) {
    for (String mimetype in mimetypes) {
      // FIXME: video MIME types?
      switch (mimetype) {
        case "application/epub+zip":
        case "application/oebps-package+xml":
          return PublicationFormat.epub;
        default:
          break;
      }
    }

    // FIXME: video file extensions?
    switch (fileExtension?.toLowerCase()) {
      case 'epub':
        return PublicationFormat.epub;
      default:
        return null;
    }
  }

  /// Finds the [PublicationFormat] of the file at the given [path], using an optionally provided [mimetype].
  static PublicationFormat? fromPath(String path, {required String mimetype}) {
    String? extension = p.extension(path);
    if (extension.length > 1) {
      // Removes the dot.
      extension = extension.substring(1);
    } else {
      extension = null;
    }

    return PublicationFormat.fromMIMEType(mimetype, fileExtension: extension);
  }
}

enum PublicationFormatEnum { epub, video }
