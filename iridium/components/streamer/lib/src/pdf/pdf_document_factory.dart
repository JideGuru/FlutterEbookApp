// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/fetcher.dart';
import 'package:mno_streamer/pdf.dart';

/// [PdfDocumentFactory] defines methods to create a [PdfDocument].
mixin PdfDocumentFactory {
  /// Create a [PdfDocument] based on a [filePath] and an optional [password].
  Future<PdfDocument> openFile(String filePath, {String? password});

  /// Create a [PdfDocument] based on a [resource] and an optional [password].
  Future<PdfDocument> openResource(Resource resource, {String? password});
}
