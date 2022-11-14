// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

/// Transforms the resources' content of a child fetcher using a list of [ResourceTransformer]
/// functions.
class TransformingFetcher extends Fetcher {
  final Fetcher fetcher;
  final List<ResourceTransformer> transformers;

  TransformingFetcher(this.fetcher, this.transformers);

  factory TransformingFetcher.single(
          Fetcher fetcher, ResourceTransformer transformer) =>
      TransformingFetcher(fetcher, [transformer]);

  @override
  Future<List<Link>> links() => fetcher.links();

  @override
  Resource get(Link link) {
    Resource resource = fetcher.get(link);
    return transformers.fold(resource, (res, transformer) => transformer(res));
  }

  @override
  Future<void> close() => fetcher.close();
}
