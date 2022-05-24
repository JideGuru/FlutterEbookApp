// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:mno_shared/streams.dart';

/// Applies a transformation on a [Publication] resource's [DataStream].
abstract class ContentFilter {
  /// Priority of this filter in the chain. Higher number means executed first.
  int get priority;

  /// Transforms the given [DataStream].
  Future<DataStream> transform(
      DataStream stream, Link link, Publication publication);
}

class ContentFilterPriority {
  ContentFilterPriority._();

  /// If you absolutely must see the bytes EXACTLY as they exist in the
  /// [Container], use this priority.
  static int rawBytes = 1000;

  /// This is the priority at which the content is fully decrypted and
  /// decompressed.
  static int content = 500;
}
