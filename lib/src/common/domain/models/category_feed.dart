class CategoryFeed {
  String? version;
  String? encoding;
  Feed? feed;

  CategoryFeed({this.version, this.encoding, this.feed});

  CategoryFeed.fromJson(Map<String, dynamic> json) {
    version = json['version'] as String?;
    encoding = json['encoding'] as String?;
    feed = json['feed'] != null
        ? Feed.fromJson(json['feed'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    data['encoding'] = encoding;
    if (feed != null) {
      data['feed'] = feed!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'CategoryFeed(version: $version, encoding: $encoding, feed: $feed)';
  }
}

class Feed {
  String? xmlLang;
  String? xmlns;
  String? xmlnsDcterms;
  String? xmlnsThr;
  String? xmlnsApp;
  String? xmlnsOpensearch;
  String? xmlnsOpds;
  String? xmlnsXsi;
  String? xmlnsOdl;
  String? xmlnsSchema;
  Id? id;
  Id? title;
  Id? updated;
  Id? icon;
  Author? author;
  List<Link>? link;
  Id? opensearchTotalResults;
  Id? opensearchItemsPerPage;
  Id? opensearchStartIndex;
  List<Entry>? entry;

  Feed({
    this.xmlLang,
    this.xmlns,
    this.xmlnsDcterms,
    this.xmlnsThr,
    this.xmlnsApp,
    this.xmlnsOpensearch,
    this.xmlnsOpds,
    this.xmlnsXsi,
    this.xmlnsOdl,
    this.xmlnsSchema,
    this.id,
    this.title,
    this.updated,
    this.icon,
    this.author,
    this.link,
    this.opensearchTotalResults,
    this.opensearchItemsPerPage,
    this.opensearchStartIndex,
    this.entry,
  });

  Feed.fromJson(Map<String, dynamic> json) {
    xmlLang = json['xml:lang'] as String?;
    xmlns = json['xmlns'] as String?;
    xmlnsDcterms = json[r'xmlns$dcterms'] as String?;
    xmlnsThr = json[r'xmlns$thr'] as String?;
    xmlnsApp = json[r'xmlns$app'] as String?;
    xmlnsOpensearch = json[r'xmlns$opensearch'] as String?;
    xmlnsOpds = json[r'xmlns$opds'] as String?;
    xmlnsXsi = json[r'xmlns$xsi'] as String?;
    xmlnsOdl = json[r'xmlns$odl'] as String?;
    xmlnsSchema = json[r'xmlns$schema'] as String?;
    id = json['id'] != null
        ? Id.fromJson(json['id'] as Map<String, dynamic>)
        : null;
    title = json['title'] != null
        ? Id.fromJson(json['title'] as Map<String, dynamic>)
        : null;
    updated = json['updated'] != null
        ? Id.fromJson(json['updated'] as Map<String, dynamic>)
        : null;
    icon = json['icon'] != null
        ? Id.fromJson(json['icon'] as Map<String, dynamic>)
        : null;
    author = json['author'] != null
        ? Author.fromJson(json['author'] as Map<String, dynamic>)
        : null;
    if (json['link'] != null) {
      link = <Link>[];
      json['link'].forEach((v) {
        link!.add(Link.fromJson(v as Map<String, dynamic>));
      });
    }
    opensearchTotalResults = json[r'opensearch$totalResults'] != null
        ? Id.fromJson(json[r'opensearch$totalResults'] as Map<String, dynamic>)
        : null;
    opensearchItemsPerPage = json[r'opensearch$itemsPerPage'] != null
        ? Id.fromJson(json[r'opensearch$itemsPerPage'] as Map<String, dynamic>)
        : null;
    opensearchStartIndex = json[r'opensearch$startIndex'] != null
        ? Id.fromJson(json[r'opensearch$startIndex'] as Map<String, dynamic>)
        : null;
    if (json['entry'] != null) {
      final String t = json['entry'].runtimeType.toString();
      try {
        entry = <Entry>[];
        json['entry'].forEach((v) {
          entry!.add(Entry.fromJson(v as Map<String, dynamic>));
        });
      } catch (_) {
        entry = <Entry>[];
        entry!.add(Entry.fromJson(json['entry'] as Map<String, dynamic>));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['xml:lang'] = xmlLang;
    data['xmlns'] = xmlns;
    data[r'xmlns$dcterms'] = xmlnsDcterms;
    data[r'xmlns$thr'] = xmlnsThr;
    data[r'xmlns$app'] = xmlnsApp;
    data[r'xmlns$opensearch'] = xmlnsOpensearch;
    data[r'xmlns$opds'] = xmlnsOpds;
    data[r'xmlns$xsi'] = xmlnsXsi;
    data[r'xmlns$odl'] = xmlnsOdl;
    data[r'xmlns$schema'] = xmlnsSchema;
    if (id != null) {
      data['id'] = id!.toJson();
    }
    if (title != null) {
      data['title'] = title!.toJson();
    }
    if (updated != null) {
      data['updated'] = updated!.toJson();
    }
    if (icon != null) {
      data['icon'] = icon!.toJson();
    }
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (link != null) {
      data['link'] = link!.map((v) => v.toJson()).toList();
    }
    if (opensearchTotalResults != null) {
      data[r'opensearch$totalResults'] = opensearchTotalResults!.toJson();
    }
    if (opensearchItemsPerPage != null) {
      data[r'opensearch$itemsPerPage'] = opensearchItemsPerPage!.toJson();
    }
    if (opensearchStartIndex != null) {
      data[r'opensearch$startIndex'] = opensearchStartIndex!.toJson();
    }
    if (entry != null) {
      data['entry'] = entry!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'Feed(xmlLang: $xmlLang, xmlns: $xmlns, xmlnsDcterms: $xmlnsDcterms, xmlnsThr: $xmlnsThr, xmlnsApp: $xmlnsApp, xmlnsOpensearch: $xmlnsOpensearch, xmlnsOpds: $xmlnsOpds, xmlnsXsi: $xmlnsXsi, xmlnsOdl: $xmlnsOdl, xmlnsSchema: $xmlnsSchema, id: $id, title: $title, updated: $updated, icon: $icon, author: $author, link: $link, opensearchTotalResults: $opensearchTotalResults, opensearchItemsPerPage: $opensearchItemsPerPage, opensearchStartIndex: $opensearchStartIndex, entry: $entry)';
  }
}

class Id {
  String? t;

  Id({this.t});

  Id.fromJson(Map<String, dynamic> json) {
    t = json[r'$t'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[r'$t'] = t;
    return data;
  }

  @override
  String toString() {
    return 'Id(t: $t)';
  }
}

class Author {
  Id? name;
  Id? uri;
  Id? email;

  Author({this.name, this.uri, this.email});

  Author.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null
        ? Id.fromJson(json['name'] as Map<String, dynamic>)
        : null;
    uri = json['uri'] != null
        ? Id.fromJson(json['uri'] as Map<String, dynamic>)
        : null;
    email = json['email'] != null
        ? Id.fromJson(json['email'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name!.toJson();
    }
    if (uri != null) {
      data['uri'] = uri!.toJson();
    }
    if (email != null) {
      data['email'] = email!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'Author(name: $name, uri: $uri, email: $email)';
  }
}

class Link {
  String? rel;
  String? type;
  String? href;
  String? title;
  String? opdsActiveFacet;
  String? opdsFacetGroup;
  String? thrCount;

  Link({
    this.rel,
    this.type,
    this.href,
    this.title,
    this.opdsActiveFacet,
    this.opdsFacetGroup,
    this.thrCount,
  });

  Link.fromJson(Map<String, dynamic> json) {
    rel = json['rel'] as String?;
    type = json['type'] as String?;
    href = json['href'] as String?;
    title = json['title'] as String?;
    opdsActiveFacet = json['opds:activeFacet'] as String?;
    opdsFacetGroup = json['opds:facetGroup'] as String?;
    thrCount = json['thr:count'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rel'] = rel;
    data['type'] = type;
    data['href'] = href;
    data['title'] = title;
    data['opds:activeFacet'] = opdsActiveFacet;
    data['opds:facetGroup'] = opdsFacetGroup;
    data['thr:count'] = thrCount;
    return data;
  }

  @override
  String toString() {
    return 'Link(rel: $rel, type: $type, href: $href, title: $title, opdsActiveFacet: $opdsActiveFacet, opdsFacetGroup: $opdsFacetGroup, thrCount: $thrCount)';
  }
}

class Entry {
  Id? title;
  Id? id;
  Author1? author;
  Id? published;
  Id? updated;
  Id? dctermsLanguage;
  Id? dctermsPublisher;
  Id? dctermsIssued;
  Id? summary;
  List<Category>? category;
  List<Link1>? link;
  SchemaSeries? schemaSeries;

  Entry({
    this.title,
    this.id,
    this.author,
    this.published,
    this.updated,
    this.dctermsLanguage,
    this.dctermsPublisher,
    this.dctermsIssued,
    this.summary,
    this.category,
    this.link,
    this.schemaSeries,
  });

  Entry.fromJson(Map<String, dynamic> json) {
    title = json['title'] != null
        ? Id.fromJson(json['title'] as Map<String, dynamic>)
        : null;
    id = json['id'] != null
        ? Id.fromJson(json['id'] as Map<String, dynamic>)
        : null;
    if (json['author'] != null) {
      try {
        author = Author1.fromJson(json['author'][0] as Map<String, dynamic>);
      } catch (_) {
        author = Author1.fromJson(json['author'] as Map<String, dynamic>);
      }
    }

    published = json['published'] != null
        ? Id.fromJson(json['published'] as Map<String, dynamic>)
        : null;
    updated = json['updated'] != null
        ? Id.fromJson(json['updated'] as Map<String, dynamic>)
        : null;
    dctermsLanguage = json[r'dcterms$language'] != null
        ? Id.fromJson(json[r'dcterms$language'] as Map<String, dynamic>)
        : null;
    dctermsPublisher = json[r'dcterms$publisher'] != null
        ? Id.fromJson(json[r'dcterms$publisher'] as Map<String, dynamic>)
        : null;
    dctermsIssued = json[r'dcterms$issued'] != null
        ? Id.fromJson(json[r'dcterms$issued'] as Map<String, dynamic>)
        : null;
    summary = json['summary'] != null
        ? Id.fromJson(json['summary'] as Map<String, dynamic>)
        : null;
    if (json['category'] != null) {
      category = <Category>[];
      try {
        json['category'].forEach((v) {
          category!.add(Category.fromJson(v as Map<String, dynamic>));
        });
      } catch (_) {
        category!.add(
          Category.fromJson(json['category'] as Map<String, dynamic>),
        );
      }
    }
    if (json['link'] != null) {
      link = <Link1>[];
      try {
        json['link'].forEach((v) {
          link!.add(Link1.fromJson(v as Map<String, dynamic>));
        });
      } catch (_) {}
    }
    schemaSeries = json[r'schema$Series'] != null
        ? SchemaSeries.fromJson(json[r'schema$Series'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (title != null) {
      data['title'] = title!.toJson();
    }
    if (id != null) {
      data['id'] = id!.toJson();
    }
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (published != null) {
      data['published'] = published!.toJson();
    }
    if (updated != null) {
      data['updated'] = updated!.toJson();
    }
    if (dctermsLanguage != null) {
      data[r'dcterms$language'] = dctermsLanguage!.toJson();
    }
    if (dctermsPublisher != null) {
      data[r'dcterms$publisher'] = dctermsPublisher!.toJson();
    }
    if (dctermsIssued != null) {
      data[r'dcterms$issued'] = dctermsIssued!.toJson();
    }
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (link != null) {
      data['link'] = link!.map((v) => v.toJson()).toList();
    }
    if (schemaSeries != null) {
      data[r'schema$Series'] = schemaSeries!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'Entry(title: $title, id: $id, author: $author, published: $published, updated: $updated, dctermsLanguage: $dctermsLanguage, dctermsPublisher: $dctermsPublisher, dctermsIssued: $dctermsIssued, summary: $summary, category: $category, link: $link, schemaSeries: $schemaSeries)';
  }
}

class Author1 {
  Id? name;
  Id? uri;

  Author1({this.name, this.uri});

  Author1.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null
        ? Id.fromJson(json['name'] as Map<String, dynamic>)
        : null;
    uri = json['uri'] != null
        ? Id.fromJson(json['uri'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name!.toJson();
    }
    if (uri != null) {
      data['uri'] = uri!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'Author1(name: $name, uri: $uri)';
  }
}

class Category {
  String? label;
  String? term;
  String? scheme;

  Category({this.label, this.term, this.scheme});

  Category.fromJson(Map<String, dynamic> json) {
    label = json['label'] as String?;
    term = json['term'] as String?;
    scheme = json['scheme'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['term'] = term;
    data['scheme'] = scheme;
    return data;
  }

  @override
  String toString() {
    return 'Category(label: $label, term: $term, scheme: $scheme)';
  }
}

class Link1 {
  String? type;
  String? rel;
  String? title;
  String? href;

  Link1({this.type, this.rel, this.title, this.href});

  Link1.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    rel = json['rel'] as String?;
    title = json['title'] as String?;
    href = json['href'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['rel'] = rel;
    data['title'] = title;
    data['href'] = href;
    return data;
  }

  @override
  String toString() {
    return 'Link1(type: $type, rel: $rel, title: $title, href: $href)';
  }
}

class SchemaSeries {
  String? schemaPosition;
  String? schemaName;
  String? schemaUrl;

  SchemaSeries({this.schemaPosition, this.schemaName, this.schemaUrl});

  SchemaSeries.fromJson(Map<String, dynamic> json) {
    schemaPosition = json['schema:position'] as String?;
    schemaName = json['schema:name'] as String?;
    schemaUrl = json['schema:url'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['schema:position'] = schemaPosition;
    data['schema:name'] = schemaName;
    data['schema:url'] = schemaUrl;
    return data;
  }

  @override
  String toString() {
    return 'SchemaSeries(schemaPosition: $schemaPosition, schemaName: $schemaName, schemaUrl: $schemaUrl)';
  }
}
