// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

/// Container of a publication
///
/// @var rootFile : a RootFile class containing the path the publication, the version
///                 and the mime type of it
///
/// @var drm : contain the brand, scheme, profile and license of DRM if it exist
abstract class Container {
  /// RootFile that contains the path to the publication, version and mime type.
  RootFile get rootFile;

  /// An optional Drm type if the publication is protected.
  Drm? get drm;
}

/// Errors related to [Container].
class ContainerError implements Exception {
  ContainerError._();

  /// Stream initialization failed.
  ContainerError.streamInitFailed();

  /// File not found.
  ContainerError.fileNotFound();

  /// File error.
  ContainerError.fileError();

  /// Missing file.
  static _MissingFile missingFile(String path) => _MissingFile(path);

  /// Error parsing XML.
  static _XmlParse xmlParse(Error underlyingError) =>
      _XmlParse(underlyingError);

  /// Missing link.
  static _MissingLink missingLink(String title) => _MissingLink(title);
}

class _MissingFile extends ContainerError {
  final String path;

  _MissingFile(this.path) : super._();
}

class _XmlParse extends ContainerError {
  final Error underlyingError;

  _XmlParse(this.underlyingError) : super._();
}

class _MissingLink extends ContainerError {
  final String title;

  _MissingLink(this.title) : super._();
}
