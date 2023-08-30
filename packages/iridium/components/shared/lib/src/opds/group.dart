// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/opds/opds_metadata.dart';

class Group with EquatableMixin {
  final String title;

  OpdsMetadata metadata;
  List<Link> links;
  List<Publication> publications;
  List<Link> navigation;

  Group({
    required this.title,
    OpdsMetadata? metadata,
    List<Link>? links,
    List<Publication>? publications,
    List<Link>? navigation,
  })  : this.metadata = metadata ?? OpdsMetadata(title: title),
        this.links = links ?? [],
        this.publications = publications ?? [],
        this.navigation = navigation ?? [];

  @override
  List<Object?> get props => [
        title,
        metadata,
        links,
        publications,
        navigation,
      ];

  @override
  String toString() =>
      'Group{title: $title, metadata: $metadata, links: $links, '
      'publications: $publications, navigation: $navigation}';
}
