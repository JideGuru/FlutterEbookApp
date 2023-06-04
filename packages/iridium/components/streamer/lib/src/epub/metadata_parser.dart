// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart' hide IterableGroupBy;
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/clock_value_parser.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:mno_streamer/src/epub/extensions/xml_node.dart';
import 'package:mno_streamer/src/epub/property_data_type.dart';
import 'package:xml/xml.dart' show XmlElement, XmlNode, XmlFindExtension;

class Title {
  final LocalizedString value;
  final LocalizedString? fileAs;
  final String? type;
  final int? displaySeq;

  Title(this.value, this.fileAs, this.type, this.displaySeq);
}

class EpubLink {
  final String href;
  final Set<String> rels;
  final String? mediaType;
  final String? refines;
  final List<String> properties;

  EpubLink(this.href, this.rels, this.mediaType, this.refines, this.properties);
}

class EpubMetadata {
  final Map<String, List<MetadataItem>> global;
  final Map<String, Map<String, List<MetadataItem>>> refine;
  final List<EpubLink> links;

  EpubMetadata(this.global, this.refine, this.links);
}

class MetadataParser {
  final double epubVersion;
  final Map<String, String> prefixMap;

  MetadataParser(this.epubVersion, this.prefixMap);

  EpubMetadata? parse(XmlNode document, String filePath) {
    XmlElement? metadata =
        document.getElement("metadata", namespace: Namespaces.opf);
    if (metadata == null) {
      return null;
    }
    var elements =
        _parseElements(metadata, filePath);
    List<MetadataItem> metas = elements.$1;
    List<EpubLink> links = elements.$2;
    List<MetadataItem> metaHierarchy = _resolveMetaHierarchy(metas);
    List<List<MetadataItem>> partitions =
        metaHierarchy.partition((it) => it.refines.isNullOrBlank);
    List<MetadataItem> globalMetas = partitions[0];
    List<MetadataItem> refineMetas = partitions[1];
    Map<String, List<MetadataItem>> globalCollection =
        globalMetas.groupBy((it) => it.property);
    Map<String, Map<String, List<MetadataItem>>> refineCollections =
        (refineMetas.groupBy((it) => it.refines!)).map(
            (key, value) => MapEntry(key, value.groupBy((it) => it.property)));
    return EpubMetadata(globalCollection, refineCollections, links);
  }

  (List<MetadataItem>, List<EpubLink>) _parseElements(
      XmlElement metadataElement, String filePath) {
    List<MetadataItem> metas = [];
    List<EpubLink> links = [];
    for (XmlElement e in metadataElement.findElements("*")) {
      if (e.name.namespaceUri == Namespaces.dc) {
        _parseDcElement(e)?.let((it) {
          metas.add(it);
        });
      } else if (e.name.namespaceUri == Namespaces.opf &&
          e.name.local == "meta") {
        _parseMetaElement(e)?.let((it) {
          metas.add(it);
        });
      } else if (e.name.namespaceUri == Namespaces.opf &&
          e.name.local == "link") {
        _parseLinkElement(e, filePath)?.let((it) {
          links.add(it);
        });
      }
    }
    return (metas, links);
  }

  EpubLink? _parseLinkElement(XmlElement element, String filePath) {
    String? href = element.getAttribute("href");
    if (href == null) {
      return null;
    }
    String relAttr = element.getAttribute("rel") ?? "";
    Set<String> rel = parseProperties(relAttr)
        .mapNotNull((it) =>
            resolveProperty(it, prefixMap, defaultVocab: DefaultVocab.link))
        .toSet();
    String propAttr = element.getAttribute("properties") ?? "";
    List<String> properties = parseProperties(propAttr)
        .mapNotNull((it) =>
            resolveProperty(it, prefixMap, defaultVocab: DefaultVocab.link))
        .toList();
    String? mediaType = element.getAttribute("media-type");
    String? refines = element.getAttribute("refines")?.removePrefix("#");
    return EpubLink(Href(href, baseHref: filePath).string, rel, mediaType,
        refines, properties);
  }

  MetadataItem? _parseMetaElement(XmlElement element) {
    if (element.getAttribute("property") == null) {
      String? name =
          element.getAttribute("name")?.trim().takeIf((it) => it.isNotEmpty);
      if (name == null) {
        return null;
      }
      String? content =
          element.getAttribute("content")?.trim().takeIf((it) => it.isNotEmpty);
      if (content == null) {
        return null;
      }
      String resolvedName = resolveProperty(name, prefixMap);
      return MetadataItem(resolvedName, content,
          lang: element.lang, id: element.id);
    } else {
      String? propName = element
          .getAttribute("property")
          ?.trim()
          .takeIf((it) => it.isNotEmpty);
      if (propName == null) {
        return null;
      }
      String? propValue = element.text.trim().takeIf((it) => it.isNotEmpty);
      if (propValue == null) {
        return null;
      }
      String resolvedProp =
          resolveProperty(propName, prefixMap, defaultVocab: DefaultVocab.meta);
      String? resolvedScheme = element
          .getAttribute("scheme")
          ?.trim()
          .takeIf((it) => it.isNotEmpty)
          ?.let((it) => resolveProperty(it, prefixMap));
      String? refines = element.getAttribute("refines")?.removePrefix("#");
      return MetadataItem(resolvedProp, propValue,
          lang: element.lang,
          scheme: resolvedScheme,
          refines: refines,
          id: element.id);
    }
  }

  MetadataItem? _parseDcElement(XmlElement element) {
    String? propValue = element.text.trim().takeIf((it) => it.isNotEmpty);
    if (propValue == null) {
      return null;
    }
    String propName = Vocabularies.dcterms + element.name.local;
    switch (element.name.local) {
      case "creator":
      case "contributor":
      case "publisher":
        return _contributorWithLegacyAttr(element, propName, propValue);
      case "date":
        return _dateWithLegacyAttr(element, propName, propValue);
      default:
        return MetadataItem(propName, propValue,
            lang: element.lang, id: element.id);
    }
  }

  MetadataItem _contributorWithLegacyAttr(
      XmlElement element, String name, String value) {
    MetadataItem? fileAs = element
        .getAttribute("file-as", namespace: Namespaces.opf)
        ?.let((it) => MetadataItem("${Vocabularies.meta}file-as", it,
            lang: element.lang, id: element.id));
    MetadataItem? role = element
        .getAttribute("role", namespace: Namespaces.opf)
        ?.let((it) => MetadataItem("${Vocabularies.meta}role", it,
            lang: element.lang, id: element.id));
    Map<String, List<MetadataItem>> children =
        [fileAs, role].filterNotNull().groupBy((it) => it.property);
    return MetadataItem(name, value,
        lang: element.lang, id: element.id, children: children);
  }

  MetadataItem _dateWithLegacyAttr(
      XmlElement element, String name, String value) {
    String? eventAttr =
        element.getAttribute("event", namespace: Namespaces.opf);
    String propName = (eventAttr == "modification")
        ? "${Vocabularies.dcterms}modified"
        : name;
    return MetadataItem(propName, value, lang: element.lang, id: element.id);
  }

  List<MetadataItem> _resolveMetaHierarchy(List<MetadataItem> items) {
    Iterable<String> metadataIds = items.mapNotNull((it) => it.id);
    Iterable<MetadataItem> rootExpr = items.filter(
        (it) => it.refines == null || !metadataIds.contains(it.refines));
    Map<String?, List<MetadataItem>> exprByRefines =
        items.groupBy((it) => it.refines);
    return rootExpr
        .map((it) => _computeMetaItem(it, exprByRefines, {}))
        .toList();
  }

  MetadataItem _computeMetaItem(MetadataItem expr,
      Map<String?, List<MetadataItem>> metas, Set<String> chain) {
    Set<String> updatedChain = chain;
    if (expr.id != null) {
      updatedChain.add(expr.id!);
    }
    List<MetadataItem> refinedBy = expr.id
            ?.let((it) => metas[it])
            ?.filter((it) => !chain.contains(it.id))
            .toList() ??
        [];
    Iterable<MetadataItem> newChildren =
        refinedBy.map((it) => _computeMetaItem(it, metas, updatedChain));
    return expr.copy(
        children: (expr.children.values.flatten() + newChildren)
            .groupBy((it) => it.property));
  }
}

class MetadataAdapter {
  final double epubVersion;
  final Map<String, List<MetadataItem>> items;

  MetadataAdapter(this.epubVersion, this.items);

  double? get duration => firstValue("${Vocabularies.media}duration")
      ?.let((it) => ClockValueParser.parse(it));

  String? firstValue(String property) => items[property]?.firstOrNull?.value;
}

class LinkMetadataAdapter extends MetadataAdapter {
  LinkMetadataAdapter(super.epubVersion, super.items);
}

class PubMetadataAdapter extends MetadataAdapter {
  final String fallbackTitle;
  final String? uniqueIdentifierId;
  final ReadingProgression readingProgression;
  final Map<String, String> displayOptions;
  late LocalizedString localizedTitle;
  LocalizedString? localizedSubtitle;
  LocalizedString? localizedSortAs;
  late List<Collection> belongsToSeries;
  late List<Collection> belongsToCollections;
  late List<Subject> subjects;
  late Map<String?, List<Contributor>> allContributors;

  PubMetadataAdapter(
      double epubVersion,
      Map<String, List<MetadataItem>> items,
      this.fallbackTitle,
      this.uniqueIdentifierId,
      this.readingProgression,
      this.displayOptions)
      : super(epubVersion, items) {
    List<Title> titles = items["${Vocabularies.dcterms}title"]
            ?.map((it) => it.toTitle())
            .toList() ??
        [];
    Title? mainTitle = titles.firstOrNullWhere((it) => it.type == "main") ??
        titles.firstOrNull;
    localizedTitle =
        mainTitle?.value ?? LocalizedString.fromString(fallbackTitle);
    localizedSubtitle = titles
        .filter((it) => it.type == "subtitle")
        .sortedBy((it) => it.displaySeq ?? 0)
        .firstOrNull
        ?.value;
    localizedSortAs = mainTitle?.fileAs ??
        firstValue("calibre:title_sort")
            ?.let((it) => LocalizedString.fromString(it));

    Iterable<(String?, Collection)> allCollections =
        (items["${Vocabularies.meta}belongs-to-collection"] ?? [])
            .map((it) => it.toCollection());
    List<List<(String?, Collection)>> collectionsPartitions =
        allCollections.partition((it) => it.$1 == "series");
    List<(String?, Collection)> seriesMeta = collectionsPartitions[0];
    List<(String?, Collection)> collectionsMeta =
        collectionsPartitions[1];
    belongsToCollections = collectionsMeta.map((it) => it.$2).toList();

    if (seriesMeta.isNotEmpty) {
      belongsToSeries = seriesMeta.map((it) => it.$2).toList();
    } else {
      belongsToSeries = items["calibre:series"]?.firstOrNull?.let((it) {
            LocalizedString name =
                LocalizedString.fromStrings({it.lang: it.value});
            double? position =
                firstValue("calibre:series_index")?.toDoubleOrNull();
            return [(Collection(localizedName: name, position: position))];
          }) ??
          [];
    }

    List<MetadataItem> subjectItems =
        items["${Vocabularies.dcterms}subject"] ?? [];
    Iterable<Subject> parsedSubjects = subjectItems.map((it) => it.toSubject());
    bool hasToSplit = parsedSubjects.length == 1 &&
        parsedSubjects.first.let((it) =>
            it.localizedName.translations.length == 1 &&
            it.code == null &&
            it.scheme == null &&
            it.sortAs == null);
    subjects = (hasToSplit)
        ? _splitSubject(parsedSubjects.first)
        : parsedSubjects.toList();

    List<MetadataItem> contributors =
        (items["${Vocabularies.dcterms}creator"] ?? []) +
            (items["${Vocabularies.dcterms}contributor"] ?? []) +
            (items["${Vocabularies.dcterms}publisher"] ?? []) +
            (items["${Vocabularies.media}narrator"] ?? []);
    allContributors = contributors
        .map((it) => it.toContributor())
        .groupBy((it) => it.$1)
        .map((key, value) =>
            MapEntry(key, value.map((it) => it.$2).toList()));
  }

  Metadata metadata() => Metadata(
      identifier: _identifier,
      modified: _modified,
      published: _published,
      languages: _languages,
      localizedTitle: localizedTitle,
      localizedSortAs: localizedSortAs,
      localizedSubtitle: localizedSubtitle,
      duration: duration,
      subjects: subjects,
      description: _description,
      readingProgression: readingProgression,
      belongsToCollections: belongsToCollections,
      belongsToSeries: belongsToSeries,
      otherMetadata: _otherMetadata,
      rendition: _presentation,
      authors: _contributors("aut"),
      translators: _contributors("trl"),
      editors: _contributors("edt"),
      publishers: _contributors("pbl"),
      artists: _contributors("art"),
      illustrators: _contributors("ill"),
      colorists: _contributors("clr"),
      narrators: _contributors("nrt"),
      contributors: _contributors(null));

  String? get _identifier {
    Map<String, String> identifiers = items["${Vocabularies.dcterms}identifier"]
            ?.associate((it) => MapEntry(it.property, it.value)) ??
        {};
    return uniqueIdentifierId?.let((it) => identifiers[it]) ??
        identifiers.values.firstOrNull;
  }

  List<String> get _languages =>
      items["${Vocabularies.dcterms}language"]
          ?.map((it) => it.value)
          .toList() ??
      [];

  DateTime? get _published =>
      firstValue("${Vocabularies.dcterms}date")?.iso8601ToDate();

  DateTime? get _modified =>
      firstValue("${Vocabularies.dcterms}modified")?.iso8601ToDate();

  String? get _description => firstValue("${Vocabularies.dcterms}description");

  String? get cover => firstValue("cover");

  List<Subject> _splitSubject(Subject subject) {
    String? lang = subject.localizedName.translations.keys.first;
    List<String> names = subject.localizedName.translations.values.first.string
        .split(RegExp("[,;]"))
        .map((it) => it.trim())
        .filter((it) => it.isNotEmpty)
        .toList();
    return names.map((it) {
      LocalizedString newName = LocalizedString.fromStrings({lang: it});
      return Subject(localizedName: newName);
    }).toList();
  }

  List<Contributor> _contributors(String? role) => allContributors[role] ?? [];

  Presentation get _presentation {
    String? flowProp = firstValue("${Vocabularies.rendition}flow");
    String? spreadProp = firstValue("${Vocabularies.rendition}spread");
    String? orientationProp =
        firstValue("${Vocabularies.rendition}orientation");
    String? layoutProp;
    if (epubVersion < 3.0) {
      layoutProp = (displayOptions["fixed-layout"] == "true")
          ? "pre-paginated"
          : "reflowable";
    } else {
      layoutProp = firstValue("${Vocabularies.rendition}layout");
    }

    (PresentationOverflow, bool) scrollInfos;
    switch (flowProp) {
      case "paginated":
        scrollInfos = (PresentationOverflow.paginated, false);
        break;
      case "scrolled-continuous":
        scrollInfos = (PresentationOverflow.scrolled, true);
        break;
      case "scrolled-doc":
        scrollInfos = (PresentationOverflow.scrolled, false);
        break;
      default:
        scrollInfos = (PresentationOverflow.auto, false);
    }
    PresentationOverflow overflow = scrollInfos.$1;
    bool continuous = scrollInfos.$2;

    EpubLayout layout;
    switch (layoutProp) {
      case "pre-paginated":
        layout = EpubLayout.fixed;
        break;
      default:
        layout = EpubLayout.reflowable;
    }

    PresentationOrientation orientation;
    switch (orientationProp) {
      case "landscape":
        orientation = PresentationOrientation.landscape;
        break;
      case "portrait":
        orientation = PresentationOrientation.portrait;
        break;
      default:
        orientation = PresentationOrientation.auto;
    }

    PresentationSpread spread;
    switch (spreadProp) {
      case "none":
        spread = PresentationSpread.none;
        break;
      case "landscape":
        spread = PresentationSpread.landscape;
        break;
      case "both":
      case "portrait":
        spread = PresentationSpread.both;
        break;
      default:
        spread = PresentationSpread.auto;
    }

    return Presentation(
        overflow: overflow,
        continuous: continuous,
        layout: layout,
        orientation: orientation,
        spread: spread);
  }

  Map<String, dynamic> get _otherMetadata {
    Iterable<String> dcterms = [
      "identifier",
      "language",
      "title",
      "date",
      "modified",
      "description",
      "duration",
      "creator",
      "publisher",
      "contributor"
    ].map((it) => Vocabularies.dcterms + it);
    Iterable<String> media =
        ["narrator", "duration"].map((it) => Vocabularies.media + it);
    Iterable<String> rendition = ["flow", "spread", "orientation", "layout"]
        .map((it) => Vocabularies.rendition + it);
    List<String> usedProperties = [...dcterms, ...media, ...rendition];

    Map<String, List<MetadataItem>> copy = Map.of(items)
      ..removeWhere((String key, List<MetadataItem> metadataItems) =>
          usedProperties.contains(key));
    Map<String, dynamic> otherMap = copy.map((key, value) {
      List<dynamic> values = value.map((it) => it.toMap()).toList();
      return MapEntry(key, (values.length == 1) ? values[0] : values);
    });
    return otherMap..["presentation"] = _presentation.toJson();
  }
}

class MetadataItem {
  static final List<String> contributorProperties = [
    "creator",
    "contributor",
    "publisher"
  ].map((it) => Vocabularies.dcterms + it).toList()
    ..add("${Vocabularies.media}narrator")
    ..add("${Vocabularies.meta}belongs-to-collection");

  final String property;
  final String value;
  final String lang;
  final String? scheme;
  final String? refines;
  final String? id;
  final Map<String, List<MetadataItem>> children;

  MetadataItem(this.property, this.value,
      {required this.lang,
      this.scheme,
      this.refines,
      this.id,
      this.children = const {}});

  MetadataItem copy({
    String? property,
    String? value,
    String? lang,
    String? scheme,
    String? refines,
    String? id,
    Map<String, List<MetadataItem>>? children,
  }) =>
      MetadataItem(
        property ?? this.property,
        value ?? this.value,
        lang: lang ?? this.lang,
        scheme: scheme ?? this.scheme,
        refines: refines ?? this.refines,
        id: id ?? this.id,
        children: children ?? this.children,
      );

  Subject toSubject() {
    assert(property == "${Vocabularies.dcterms}subject");
    LocalizedString values = localizedString();
    LocalizedString? localizedSortAs =
        fileAs?.let((it) => LocalizedString.fromStrings({it.$1: it.$2}));
    return Subject(
        localizedName: values,
        localizedSortAs: localizedSortAs,
        scheme: authority,
        code: term);
  }

  Title toTitle() {
    assert(property == "${Vocabularies.dcterms}title");
    LocalizedString values = localizedString();
    LocalizedString? localizedSortAs =
        fileAs?.let((it) => LocalizedString.fromStrings({it.$1: it.$2}));
    return Title(values, localizedSortAs, titleType, displaySeq);
  }

  (String?, Contributor) toContributor() {
    assert(contributorProperties.contains(property));
    Set<String> knownRoles = {
      "aut",
      "trl",
      "edt",
      "pbl",
      "art",
      "ill",
      "clr",
      "nrt"
    };
    LocalizedString names = localizedString();
    LocalizedString? localizedSortAs =
        fileAs?.let((it) => LocalizedString.fromStrings({it.$1: it.$2}));
    Set<String> roles =
        role.takeUnless((it) => knownRoles.contains(it))?.let((it) => {it}) ??
            {};
    String? type;
    switch (property) {
      case "${Vocabularies.meta}belongs-to-collection":
        type = collectionType;
        break;
      case "${Vocabularies.dcterms}creator":
        type = "aut";
        break;
      case "${Vocabularies.dcterms}publisher":
        type = "pbl";
        break;
      case "${Vocabularies.media}narrator":
        type = "nrt";
        break;
      default:
        type = role.takeIf((it) =>
            knownRoles.contains(it)); // Vocabularies.DCTERMS + "contributor"
    }
    Contributor contributor = Contributor(
        localizedName: names,
        localizedSortAs: localizedSortAs,
        roles: roles,
        identifier: identifier,
        position: groupPosition);

    return (type, contributor);
  }

  (String?, Collection) toCollection() =>
      toContributor().let((t) => (t.$1, t.$2.toCollection()));

  dynamic toMap() {
    if (children.isEmpty) {
      return value;
    } else {
      Map<String, dynamic> mappedChildren = children.values
          .flatten()
          .associate((it) => MapEntry(it.property, it.toMap()));
      mappedChildren["@value"] = value;
      return mappedChildren;
    }
  }

  (String?, String)? get fileAs =>
      children["${Vocabularies.meta}file-as"]?.firstOrNull?.let(
          (it) => (it.lang.takeUnless((it) => it == ""), it.value));

  String? get titleType => firstValue("${Vocabularies.meta}title-type");

  int? get displaySeq =>
      firstValue("${Vocabularies.meta}display-seq")?.toIntOrNull();

  String? get authority => firstValue("${Vocabularies.meta}authority");

  String? get term => firstValue("${Vocabularies.meta}term");

  Map<String, String> get alternateScript =>
      children["${Vocabularies.meta}alternate-script"]
          ?.associate((it) => MapEntry(it.lang, it.value)) ??
      {};

  String? get collectionType =>
      firstValue("${Vocabularies.meta}collection-type");

  double? get groupPosition =>
      firstValue("${Vocabularies.meta}group-position")?.toDoubleOrNull();

  String? get identifier => firstValue("${Vocabularies.dcterms}identifier");

  String? get role => firstValue("${Vocabularies.meta}role");

  LocalizedString localizedString() {
    Map<String?, String> values = {lang.takeUnless((it) => it == ""): value}
      ..addAll(alternateScript);
    return LocalizedString.fromStrings(values);
  }

  String? firstValue(String property) => children[property]?.firstOrNull?.value;

  @override
  String toString() =>
      'MetadataItem{property: $property, value: $value, lang: $lang, '
      'scheme: $scheme, refines: $refines, id: $id, children: $children}';
}
