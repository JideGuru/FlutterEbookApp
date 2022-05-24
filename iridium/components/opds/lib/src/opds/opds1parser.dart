// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';
import 'package:xml/xml.dart';

/// Errors related to OPDS1 parser
class OPDSParserError {
  /// Missing title
  static const OPDSParserError missingTitle = OPDSParserError._("missingTitle");

  /// Name describing the error
  final String name;
  const OPDSParserError._(this.name);

  @override
  String toString() => 'OPDSParserError{name: $name}';
}

/// This class describes a Mimetype when parsed in an OPDS feed.
class MimeTypeParameters {
  /// The type component, e.g. `application/atom+xml`.
  final String type;

  /// The parameters in the mime type, such as `charset=utf-8`.
  final Map<String, String> parameters;

  /// Creates a MimeTypeParameters instance.
  MimeTypeParameters({required this.type, required this.parameters});

  @override
  String toString() =>
      'MimeTypeParameters{type: $type, parameters: $parameters}';
}

/// List of namespaces used in the OPDS spec.
class Namespaces {
  static const String opds = "http://opds-spec.org/2010/catalog";
  static const String dc = "http://purl.org/dc/elements/1.1/";
  static const String dcterms = "http://purl.org/dc/terms/";
  static const String atom = "http://www.w3.org/2005/Atom";
  static const String search = "http://a9.com/-/spec/opensearch/1.1/";
  static const String thread = "http://purl.org/syndication/thread/1.0";
}

/// This parser supports the OPDS1 spec.
class Opds1Parser {
  /// Parse an OPDS1 feed or entry with a [url] and optional [headers].
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

  /// Parse an OPDS1 feed or entry with [xmlData] and [url] as context.
  static ParseData parse(String xmlData, Uri url) {
    XmlDocument root = XmlDocument.parse(xmlData);
    return (root.rootElement.name.local == "feed")
        ? ParseData(feed: _parseFeed(root.rootElement, url), type: 1)
        : ParseData(
            publication: _parseEntry(root.rootElement, baseUrl: url), type: 1);
  }

  static Feed _parseFeed(XmlElement root, Uri url) {
    String? feedTitle =
        root.getElement("title", namespace: Namespaces.atom)?.text;
    if (feedTitle == null) {
      throw Exception(OPDSParserError.missingTitle.name);
    }
    Feed feed = Feed(feedTitle, 1, url);
    String? tmpDate =
        root.getElement("updated", namespace: Namespaces.atom)?.text;
    feed.metadata.modified = tmpDate?.let((it) => it.iso8601ToDate());

    String? totalResults =
        root.getElement("TotalResults", namespace: Namespaces.search)?.text;
    totalResults?.let((it) {
      feed.metadata.numberOfItems = int.tryParse(it);
    });
    String? itemsPerPage =
        root.getElement("ItemsPerPage", namespace: Namespaces.search)?.text;
    itemsPerPage?.let((it) {
      feed.metadata.itemsPerPage = int.tryParse(it);
    });

    // Parse entries
    for (XmlElement entry
        in root.findElements("entry", namespace: Namespaces.atom)) {
      bool isNavigation = true;
      Link? collectionLink;
      Iterable<XmlElement> links =
          entry.findElements("link", namespace: Namespaces.atom);
      for (XmlElement link in links) {
        String? href = link.getAttribute("href");
        String? rel = link.getAttribute("rel");
        if (rel != null) {
          if (rel.startsWith("http://opds-spec.org/acquisition")) {
            isNavigation = false;
          }
          if (href != null &&
              (rel == "collection" || rel == "http://opds-spec.org/group")) {
            collectionLink = Link(
                href: Href(href, baseHref: feed.href.toString())
                    .percentEncodedString,
                title: link.getAttribute("title"),
                rels: {"collection"});
          }
        }
      }
      if ((!isNavigation)) {
        Publication? publication = _parseEntry(entry, baseUrl: url);
        if (publication != null) {
          if (collectionLink != null) {
            _addPublicationInGroup(feed, publication, collectionLink);
          } else {
            feed.publications.add(publication);
          }
        }
      } else {
        XmlElement? link = entry.getElement("link", namespace: Namespaces.atom);
        String? href = link?.getAttribute("href");
        if (href != null) {
          Map<String, dynamic> otherProperties = {};
          int? facetElementCount = link
              ?.getAttribute("count", namespace: Namespaces.thread)
              ?.let((it) => int.tryParse(it));
          if (facetElementCount != null) {
            otherProperties["numberOfItems"] = facetElementCount;
          }

          Link newLink = Link(
              href: Href(href, baseHref: feed.href.toString())
                  .percentEncodedString,
              type: link?.getAttribute("type"),
              title:
                  entry.getElement("title", namespace: Namespaces.atom)?.text,
              rels: [link?.getAttribute("rel")].whereNotNull().toSet(),
              properties: Properties(otherProperties: otherProperties));
          if (collectionLink != null) {
            _addNavigationInGroup(feed, newLink, collectionLink);
          } else {
            feed.navigation.add(newLink);
          }
        }
      }
    }

    // Parse links
    for (XmlElement link
        in root.findElements("link", namespace: Namespaces.atom)) {
      String? hrefAttr = link.getAttribute("href");
      if (hrefAttr == null) {
        continue;
      }
      String href =
          Href(hrefAttr, baseHref: feed.href.toString()).percentEncodedString;
      String? title = link.getAttribute("title");
      String? type = link.getAttribute("type");
      Set<String> rels = [link.getAttribute("rel")].whereNotNull().toSet();

      String? facetGroupName =
          link.getAttribute("facetGroup", namespace: Namespaces.opds);
      if (facetGroupName != null &&
          rels.contains("http://opds-spec.org/facet")) {
        Map<String, dynamic> otherProperties = {};
        int? facetElementCount = link
            .getAttribute("count", namespace: Namespaces.thread)
            ?.let((it) => int.tryParse(it));
        if (facetElementCount != null) {
          otherProperties["numberOfItems"] = facetElementCount;
        }
        Link newLink = Link(
            href: href,
            type: type,
            title: title,
            rels: rels,
            properties: Properties(otherProperties: otherProperties));
        _addFacet(feed, newLink, facetGroupName);
      } else {
        feed.links.add(Link(href: href, type: type, title: title, rels: rels));
      }
    }
    return feed;
  }

  static MimeTypeParameters _parseMimeType({required String mimeTypeString}) {
    List<String> substrings = mimeTypeString.split(";");
    String type = substrings[0].replaceFirst("\\s", "");
    Map<String, String> params = {};
    for (String defn in substrings.drop(0)) {
      List<String> halves = defn.split("=");
      String paramName = halves[0].replaceFirst("\\s", "");
      String paramValue = halves[1].replaceFirst("\\s", "");
      params[paramName] = paramValue;
    }
    return MimeTypeParameters(type: type, parameters: params);
  }

  static Future<Try<String?, Exception>> fetchOpenSearchTemplate(
      Feed feed) async {
    Uri? openSearchURL;
    String? selfMimeType;

    for (Link link in feed.links) {
      if (link.rels.contains("self")) {
        if (link.type != null) {
          selfMimeType = link.type;
        }
      } else if (link.rels.contains("search")) {
        openSearchURL = Uri.tryParse(link.href);
      }
    }

    Uri? unwrappedURL = openSearchURL?.let((it) => it);
    return http.get(unwrappedURL!).then((response) {
      XmlDocument document = XmlDocument.parse(response.body);

      Iterable<XmlElement> urls =
          document.findElements("Url", namespace: Namespaces.search);

      XmlElement? typeAndProfileMatch;
      XmlElement? typeMatch;
      return selfMimeType?.let((s) {
            MimeTypeParameters selfMimeParams =
                _parseMimeType(mimeTypeString: s);
            for (XmlElement url in urls) {
              String? urlMimeType = url.getAttribute("type");
              if (urlMimeType == null) {
                continue;
              }
              MimeTypeParameters otherMimeParams =
                  _parseMimeType(mimeTypeString: urlMimeType);
              if (selfMimeParams.type == otherMimeParams.type) {
                typeMatch ??= url;
                if (selfMimeParams.parameters["profile"] ==
                    otherMimeParams.parameters["profile"]) {
                  typeAndProfileMatch = url;
                  break;
                }
              }
            }
            XmlElement match = typeAndProfileMatch ?? (typeMatch ?? urls.first);
            String? template = match.getAttribute("template");

            return Try<String?, Exception>.success(template);
          }) ??
          Try<String?, Exception>.failure(Exception("No selfMimeType found"));
    }).onError<Exception>(
        (error, stackTrace) => Try<String?, Exception>.failure(error));
  }

  static Publication? _parseEntry(XmlElement entry, {required Uri baseUrl}) {
    // A title is mandatory
    String? title = entry.getElement("title", namespace: Namespaces.atom)?.text;
    if (title == null) {
      return null;
    }

    List<Link> links = entry
        .findElements("link", namespace: Namespaces.atom)
        .mapNotNull((element) {
      String? href = element.getAttribute("href");
      String? rel = element.getAttribute("rel");
      if (href == null ||
          rel == "collection" ||
          rel == "http://opds-spec.org/group") {
        return null;
      }

      Map<String, dynamic> properties = {};
      List<Acquisition> acquisitions = _AcquisitionFromXml.fromXml(element);
      if (acquisitions.isNotEmpty) {
        properties["indirectAcquisition"] = acquisitions.toJson();
      }

      element.getElement("price", namespace: Namespaces.opds)?.let((it) {
        double? value = it.text.toDoubleOrNull();
        String? currency =
            it.getAttribute("currencyCode") ?? it.getAttribute("currencycode");
        if (value != null && currency != null) {
          properties["price"] =
              Price(currency: currency, value: value).toJson();
        }
      });

      return Link(
          href: Href(href, baseHref: baseUrl.toString()).percentEncodedString,
          type: element.getAttribute("type"),
          title: element.getAttribute("title"),
          rels: [rel].whereNotNull().toSet(),
          properties: Properties(otherProperties: properties));
    }).toList();

    List<Link> images = links
        .filter((it) =>
            it.rels.contains("http://opds-spec.org/image") ||
            it.rels.contains("http://opds-spec.org/image-thumbnail"))
        .toList();

    links = links - images;

    Manifest manifest = Manifest(
      metadata: Metadata(
        identifier:
            entry.getElement("identifier", namespace: Namespaces.dc)?.text ??
                entry.getElement("id", namespace: Namespaces.atom)?.text,
        localizedTitle: LocalizedString.fromString(title),
        modified: entry
            .getElement("updated", namespace: Namespaces.atom)
            ?.let((it) => it.text.iso8601ToDate()),
        published: entry
            .getElement("published", namespace: Namespaces.atom)
            ?.let((it) => it.text.iso8601ToDate()),
        languages: entry
            .findElements("language", namespace: Namespaces.dcterms)
            .mapNotNull((it) => it.text)
            .toList(),
        publishers: entry
            .findElements("publisher", namespace: Namespaces.dcterms)
            .mapNotNull((it) => it.text.let((name) =>
                Contributor(localizedName: LocalizedString.fromString(name))))
            .toList(),
        subjects: entry
            .findElements("category", namespace: Namespaces.atom)
            .mapNotNull((element) => element.getAttribute("label")?.let(
                (name) => Subject(
                    localizedName: LocalizedString.fromString(name),
                    scheme: element.getAttribute("scheme"),
                    code: element.getAttribute("term"))))
            .toList(),
        authors: entry
            .findElements("author", namespace: Namespaces.atom)
            .mapNotNull((element) => element
                .getElement("name", namespace: Namespaces.atom)
                ?.text
                .let((name) => Contributor(
                    localizedName: LocalizedString.fromString(name),
                    links: [
                      element
                          .getElement("uri", namespace: Namespaces.atom)
                          ?.text
                          .let((it) => Link(href: it))
                    ].whereNotNull().toList())))
            .toList(),
        description:
            entry.getElement("content", namespace: Namespaces.atom)?.text ??
                entry.getElement("summary", namespace: Namespaces.atom)?.text,
      ),
      links: links,
      subcollections: {
        "images": [
          images
              .takeIf((it) => it.isNotEmpty)
              ?.let((it) => PublicationCollection(links: it))
        ].whereNotNull().toList()
      }..removeWhere((key, value) => value.isEmpty),
    );

    return Publication(manifest: manifest);
  }

  static void _addFacet(Feed feed, Link link, String title) {
    for (Facet facet in feed.facets) {
      if (facet.metadata.title == title) {
        facet.links.add(link);
        return;
      }
    }
    Facet newFacet = Facet(title: title);
    newFacet.links.add(link);
    feed.facets.add(newFacet);
  }

  static void _addPublicationInGroup(
      Feed feed, Publication publication, Link collectionLink) {
    for (Group group in feed.groups) {
      for (Link l in group.links) {
        if (l.href == collectionLink.href) {
          group.publications.add(publication);
          return;
        }
      }
    }
    String? title = collectionLink.title;
    if (title != null) {
      Link selfLink =
          collectionLink.copy(rels: Set.from(collectionLink.rels)..add("self"));
      Group newGroup = Group(title: title);
      newGroup.links.add(selfLink);
      newGroup.publications.add(publication);
      feed.groups.add(newGroup);
    }
  }

  static void _addNavigationInGroup(Feed feed, Link link, Link collectionLink) {
    for (Group group in feed.groups) {
      for (Link l in group.links) {
        if (l.href == collectionLink.href) {
          group.navigation.add(link);
          return;
        }
      }
    }
    String? title = collectionLink.title;
    if (title != null) {
      Link selfLink =
          collectionLink.copy(rels: Set.from(collectionLink.rels)..add("self"));
      Group newGroup = Group(title: title);
      newGroup.links.add(selfLink);
      newGroup.navigation.add(link);
      feed.groups.add(newGroup);
    }
  }
}

class _AcquisitionFromXml {
  static List<Acquisition> fromXml(XmlElement element) => element
          .findElements("indirectAcquisition", namespace: Namespaces.opds)
          .mapNotNull((child) {
        String? type = child.getAttribute("type");
        if (type == null) {
          return null;
        }
        return Acquisition(type: type, children: fromXml(child));
      }).toList();
}
