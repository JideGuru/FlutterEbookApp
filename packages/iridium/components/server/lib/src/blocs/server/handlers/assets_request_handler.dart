// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:path/path.dart' as p;

/// Function to transform a response data based on href provided.
typedef TransformData = Uint8List Function(String href, Uint8List data);

Uint8List _defaultTransformData(String href, Uint8List data) => data;

/// This [RequestHandler] is used to provide access to assets
class AssetsRequestHandler extends RequestHandler {
  /// Folder containing the assets, relative to the root bundle.
  final String path;

  /// The [assetProvider] implementation may depend on the platform
  /// (Native or JS).
  final AssetProvider assetProvider;

  /// This function is able to modify a resource based on the [String] param.
  final TransformData transformData;

  /// Creates an instance of [AssetsRequestHandler] with a root [path] and an [assetProvider].
  ///
  /// A [transformData] parameter is optional.
  AssetsRequestHandler(
    this.path, {
    required this.assetProvider,
    TransformData? transformData,
  }) : this.transformData = transformData ?? _defaultTransformData;

  @override
  Future<bool> handle(int requestId, Request request, String href) async {
    try {
      Uint8List uint8List =
          (await assetProvider.load(p.join(path, href))).buffer.asUint8List();
      uint8List = transformData(href, uint8List);

      await sendData(
        request,
        data: uint8List,
        mediaType:
            await MediaType.ofSingleHint(fileExtension: href.extension()),
      );
      return true;
    } on Error {
      // For debugging
      // Fimber.d("Error loading: $href", ex: ex, stacktrace: st);
      return false;
    }
  }
}
