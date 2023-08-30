// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/uri_template.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/mediatype.dart';

class Link {
  final String href;

  /// Indicates the relationship between the resource and its containing collection.
  final List<String> rel;

  /// Title for the Link.
  final String? title;

  /// MIME type of resource.
  final String? type;

  /// Indicates that the linked resource is a URI template.
  final bool templated;

  /// Expected profile used to identify the external resource. (URI)
  final Uri? profile;

  /// Content length in octets.
  final int? length;

  /// SHA-256 hash of the resource.
  final String? hash;

  Link._(this.href, this.rel, this.title, this.type, this.templated,
      this.profile, this.length, this.hash);

  factory Link.parse(Map json) {
    String? href = json["href"];
    if (href == null) {
      throw LcpException.parsing.link;
    }
    dynamic rel = json["rel"];
    List<String> relations = [];
    if (rel is String) {
      relations.add(rel);
    } else if (rel is Iterable<String>) {
      relations.addAll(rel);
    }
    if (relations.isEmpty) {
      throw LcpException.parsing.link;
    }
    return Link._(
        href,
        relations,
        json["title"] as String?,
        json["type"] as String?,
        json["templated"] as bool? ?? false,
        (json["profile"] != null) ? Uri.parse(json["profile"]) : null,
        json["length"] as int? ?? 0,
        json["hash"] as String?);
  }

  Uri urlWithParams({Map<String, String?> parameters = const {}}) {
    if (!templated) {
      return Uri.parse(href);
    }
    String expandedHref = UriTemplate(href).expand(
        parameters.map((key, dynamic value) => MapEntry(key, value ?? "")));
    return Uri.parse(expandedHref);
  }

  Uri get url => urlWithParams();

  MediaType get mediaType {
    if (type == null) {
      return MediaType.binary;
    } else {
      return MediaType.parse(type!) ?? MediaType.binary;
    }
  }

  /// List of URI template parameter keys, if the [Link] is templated.
  List<String> get templateParameters {
    if (!templated) {
      return [];
    } else {
      return UriTemplate(href).parameters.toList();
    }
  }

  @override
  String toString() =>
      'Link{href: $href, rel: $rel, title: $title, type: $type, templated: $templated, profile: $profile, length: $length, hash: $hash}';
}
