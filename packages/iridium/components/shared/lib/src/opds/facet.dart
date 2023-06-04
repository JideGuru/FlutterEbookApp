// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/opds/opds_metadata.dart';

class Facet with EquatableMixin {
  final String title;
  OpdsMetadata metadata;
  List<Link> links;

  Facet({
    required this.title,
    OpdsMetadata? metadata,
    List<Link>? links,
  })  : this.metadata = metadata ?? OpdsMetadata(title: title),
        this.links = links ?? [];

  @override
  List<Object> get props => [
        title,
        metadata,
        links,
      ];

  @override
  String toString() =>
      'Facet{title: $title, metadata: $metadata, links: $links}';
}
