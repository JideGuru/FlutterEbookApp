// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/container/container.dart';

/// Temporary solution to migrate to [Publication.get] while ensuring backward compatibility with
/// [Container].
class PublicationContainer extends Container {
  final String _path;
  final MediaType _mediaType;
  @override
  final Drm? drm;

  /// Creates an instance of [PublicationContainer].
  PublicationContainer({
    required String path,
    required MediaType mediaType,
    this.drm,
  })  : _path = path,
        _mediaType = mediaType;

  @override
  RootFile get rootFile =>
      RootFile(rootPath: _path, mimetype: _mediaType.toString());
}
