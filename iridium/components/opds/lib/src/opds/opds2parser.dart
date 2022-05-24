// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';

/// Errors related to OPDS2 parser
class OPDS2ParserError {
  /// Metadata not found.
  static const OPDS2ParserError metadataNotFound =
      OPDS2ParserError._("metadataNotFound");

  /// Invalid link.
  static const OPDS2ParserError invalidLink = OPDS2ParserError._("invalidLink");

  /// Missing title
  static const OPDS2ParserError missingTitle =
      OPDS2ParserError._("missingTitle");

  /// Invalid facet
  static const OPDS2ParserError invalidFacet =
      OPDS2ParserError._("invalidFacet");

  /// Invalid group
  static const OPDS2ParserError invalidGroup =
      OPDS2ParserError._("invalidGroup");

  /// Name describing the error
  final String name;
  const OPDS2ParserError._(this.name);

  @override
  String toString() => 'OPDS2ParserError{name: $name}';
}

/// This parser supports the OPDS2 spec.
class OPDS2Parser {
  /// Parse an OPDS2 feed or entry with a [url] and optional [headers].
  static Future<Try<ParseData, Exception>> parseURL(Uri url,
      {Map<String, String>? headers}) async {
    try {
      return http.get(url, headers: headers).then((response) {
        int status = response.statusCode;
        if (status >= 400) {
          return Try<ParseData, Exception>.failure(
              Exception("Connection error"));
        } else {
          ParseData data = parse(response.body, url);
          return Try<ParseData, Exception>.success(data);
        }
      }).onError<Exception>(
          (error, stackTrace) => Try<ParseData, Exception>.failure(error));
    } on Exception catch (e, stacktrace) {
      Fimber.e("download ERROR", ex: e, stacktrace: stacktrace);
      return Try.failure(Exception("Connection error"));
    }
  }

  /// Parse an OPDS2 feed or entry with [jsonData] and [url] as context.
  static ParseData parse(String jsonData, Uri url) {
    Map<String, dynamic> json = jsonData.toJsonOrNull()!;
    return (_isFeed(json))
        ? ParseData(feed: _parseFeed(json, url), type: 2)
        : ParseData(
            publication:
                Manifest.fromJson(json)?.let((it) => Publication(manifest: it)),
            type: 2);
  }

  static bool _isFeed(Map<String, dynamic> json) =>
      json.let((it) => (it.containsKey("navigation") ||
          it.containsKey("groups") ||
          it.containsKey("publications") ||
          it.containsKey("facets")));

  static Feed _parseFeed(Map<String, dynamic> topLevelDict, Uri url) {
    Map<String, dynamic>? metadataDict = topLevelDict["metadata"];
    if (metadataDict == null) {
      throw Exception(OPDS2ParserError.metadataNotFound.name);
    }
    String? title = metadataDict["title"] as String?;
    if (title == null) {
      throw Exception(OPDS2ParserError.missingTitle.name);
    }
    Feed feed = Feed(title, 2, url);
    _parseFeedMetadata(opdsMetadata: feed.metadata, metadataDict: metadataDict);
    if (topLevelDict.containsKey("@context")) {
      if (topLevelDict["@context"] is Map<String, dynamic>) {
        feed.context
            .add(json.encode(topLevelDict["@context"] as Map<String, dynamic>));
      } else if (topLevelDict["@context"] is List<String>) {
        List<String> array = topLevelDict["@context"] as List<String>;
        for (int i = 0; i < array.length; i++) {
          feed.context.add(array[i]);
        }
      }
    }

    if (topLevelDict.containsKey("links")) {
      topLevelDict["links"].let((it) {
        List? links = it as List?;
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        _parseLinks(feed, links);
      });
    }

    if (topLevelDict.containsKey("facets")) {
      topLevelDict["facets"].let((it) {
        List? facets = it as List?;
        if (facets == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        _parseFacets(feed, facets);
      });
    }

    if (topLevelDict.containsKey("publications")) {
      topLevelDict["publications"].let((it) {
        List? publications = it as List?;
        if (publications == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        _parsePublications(feed, publications);
      });
    }

    if (topLevelDict.containsKey("navigation")) {
      topLevelDict["navigation"].let((it) {
        List? navigation = it as List?;
        if (navigation == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        _parseNavigation(feed, navigation);
      });
    }

    if (topLevelDict.containsKey("groups")) {
      topLevelDict["groups"].let((it) {
        List? groups = it as List?;
        if (groups == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        _parseGroups(feed, groups);
      });
    }
    return feed;
  }

  static void _parseFeedMetadata(
      {required OpdsMetadata opdsMetadata,
      required Map<String, dynamic> metadataDict}) {
    if (metadataDict.containsKey("title")) {
      metadataDict["title"].let((it) => opdsMetadata.title = it.toString());
    }
    if (metadataDict.containsKey("numberOfItems")) {
      metadataDict["numberOfItems"]
          .let((it) => opdsMetadata.numberOfItems = it.toString().toInt());
    }
    if (metadataDict.containsKey("itemsPerPage")) {
      metadataDict["itemsPerPage"]
          .let((it) => opdsMetadata.itemsPerPage = it.toString().toInt());
    }
    if (metadataDict.containsKey("modified")) {
      metadataDict["modified"]
          .let((it) => opdsMetadata.modified = it.toString().iso8601ToDate());
    }
    if (metadataDict.containsKey("@type")) {
      metadataDict["@type"].let((it) => opdsMetadata.rdfType = it.toString());
    }
    if (metadataDict.containsKey("currentPage")) {
      metadataDict["currentPage"]
          .let((it) => opdsMetadata.currentPage = it.toString().toInt());
    }
  }

  static void _parseFacets(Feed feed, List facets) {
    for (int i = 0; i < facets.length; i++) {
      Map<String, dynamic> facetDict = facets[i];
      Map<String, dynamic>? metadata = facetDict["metadata"];
      if (metadata == null) {
        throw Exception(OPDS2ParserError.invalidFacet.name);
      }
      String? title = metadata["title"] as String?;
      if (title == null) {
        throw Exception(OPDS2ParserError.invalidFacet.name);
      }
      Facet facet = Facet(title: title);
      _parseFeedMetadata(opdsMetadata: facet.metadata, metadataDict: metadata);
      if (facetDict.containsKey("links")) {
        List? links = facetDict["links"] as List?;
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidFacet.name);
        }
        for (int k = 0; k < links.length; k++) {
          Map<String, dynamic> linkDict = links[k];
          Link.fromJSON(linkDict)?.let((it) {
            facet.links.add(it);
          });
        }
      }
      feed.facets.add(facet);
    }
  }

  static void _parseLinks(Feed feed, List links) {
    for (int i = 0; i < links.length; i++) {
      Map<String, dynamic> linkDict = links[i];
      Link.fromJSON(linkDict)?.let((it) {
        feed.links.add(it);
      });
    }
  }

  static void _parsePublications(Feed feed, List publications) {
    for (int i = 0; i < publications.length; i++) {
      Map<String, dynamic> pubDict = publications[i];
      Manifest.fromJson(pubDict)?.let((manifest) {
        feed.publications.add(Publication(manifest: manifest));
      });
    }
  }

  static void _parseNavigation(Feed feed, List navLinks) {
    for (int i = 0; i < navLinks.length; i++) {
      Map<String, dynamic> navDict = navLinks[i];
      Link.fromJSON(navDict)?.let((link) {
        feed.navigation.add(link);
      });
    }
  }

  static void _parseGroups(Feed feed, List groups) {
    for (int i = 0; i < groups.length; i++) {
      Map<String, dynamic> groupDict = groups[i];
      Map<String, dynamic>? metadata = groupDict["metadata"];
      if (metadata == null) {
        throw Exception(OPDS2ParserError.invalidGroup.name);
      }
      String? title = metadata["title"] as String?;
      if (title == null) {
        throw Exception(OPDS2ParserError.invalidGroup.name);
      }
      Group group = Group(title: title);
      _parseFeedMetadata(opdsMetadata: group.metadata, metadataDict: metadata);

      if (groupDict.containsKey("links")) {
        List? links = groupDict["links"] as List?;
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidGroup.name);
        }
        for (int j = 0; j < links.length; j++) {
          Map<String, dynamic> linkDict = links[j];
          Link.fromJSON(linkDict)?.let((link) {
            group.links.add(link);
          });
        }
      }
      if (groupDict.containsKey("navigation")) {
        List? links = groupDict["navigation"] as List?;
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidGroup.name);
        }
        for (int j = 0; j < links.length; j++) {
          Map<String, dynamic> linkDict = links[j];
          Link.fromJSON(linkDict)?.let((link) {
            group.navigation.add(link);
          });
        }
      }
      if (groupDict.containsKey("publications")) {
        List? publications = groupDict["publications"] as List?;
        if (publications == null) {
          throw Exception(OPDS2ParserError.invalidGroup.name);
        }
        for (int j = 0; j < publications.length; j++) {
          Map<String, dynamic> pubDict = publications[j];
          Manifest.fromJson(pubDict)?.let((manifest) {
            group.publications.add(Publication(manifest: manifest));
          });
        }
      }

      feed.groups.add(group);
    }
  }
}
