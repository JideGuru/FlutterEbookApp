// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/opds/facet.dart';
import 'package:mno_shared/src/opds/group.dart';
import 'package:mno_shared/src/opds/opds_metadata.dart';

class Feed with EquatableMixin {
  final String title;
  final int type;
  final Uri href;
  OpdsMetadata metadata;
  List<Link> links;
  List<Facet> facets;
  List<Group> groups;
  List<Publication> publications;
  List<Link> navigation;
  List<String> context;

  Feed(
    this.title,
    this.type,
    this.href, {
    OpdsMetadata? metadata,
    List<Link>? links,
    List<Facet>? facets,
    List<Group>? groups,
    List<Publication>? publications,
    List<Link>? navigation,
    List<String>? context,
  })  : this.metadata = metadata ?? OpdsMetadata(title: title),
        this.links = links ?? [],
        this.facets = facets ?? [],
        this.groups = groups ?? [],
        this.publications = publications ?? [],
        this.navigation = navigation ?? [],
        this.context = context ?? [];

  @override
  List<Object?> get props => [
        title,
        type,
        href,
        metadata,
        links,
        facets,
        groups,
        publications,
        navigation,
        context,
      ];

  @override
  String toString() =>
      'Feed{title: $title, type: $type, href: $href, metadata: $metadata, '
      'links: $links, facets: $facets, groups: $groups, '
      'publications: $publications, navigation: $navigation, '
      'context: $context}';
}

class ParseData with EquatableMixin {
  final Feed? feed;
  final Publication? publication;
  final int type;

  ParseData({this.feed, this.publication, required this.type});

  @override
  List<Object?> get props => [
        feed,
        publication,
        type,
      ];

  @override
  String toString() =>
      'ParseData{feed: $feed, publication: $publication, type: $type}';
}
