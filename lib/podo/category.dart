class CategoryFeed {
  String version;
  String encoding;
  Feed feed;

  CategoryFeed({this.version, this.encoding, this.feed});

  CategoryFeed.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    encoding = json['encoding'];
    feed = json['feed'] != null ? new Feed.fromJson(json['feed']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['encoding'] = this.encoding;
    if (this.feed != null) {
      data['feed'] = this.feed.toJson();
    }
    return data;
  }
}

class Feed {
  String xmlLang;
  String xmlns;
  String xmlnsDcterms;
  String xmlnsThr;
  String xmlnsApp;
  String xmlnsOpensearch;
  String xmlnsOpds;
  String xmlnsXsi;
  String xmlnsOdl;
  String xmlnsSchema;
  Id id;
  Id title;
  Id updated;
  Id icon;
  Author author;
  List<Link> link;
  Id opensearchTotalResults;
  Id opensearchItemsPerPage;
  Id opensearchStartIndex;
  List<Entry> entry;

  Feed(
      {this.xmlLang,
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
        this.entry});

  Feed.fromJson(Map<String, dynamic> json) {
    xmlLang = json['xml:lang'];
    xmlns = json[r'xmlns'];
    xmlnsDcterms = json[r'xmlns$dcterms'];
    xmlnsThr = json[r'xmlns$thr'];
    xmlnsApp = json[r'xmlns$app'];
    xmlnsOpensearch = json[r'xmlns$opensearch'];
    xmlnsOpds = json[r'xmlns$opds'];
    xmlnsXsi = json[r'xmlns$xsi'];
    xmlnsOdl = json[r'xmlns$odl'];
    xmlnsSchema = json[r'xmlns$schema'];
    id = json['id'] != null ? new Id.fromJson(json['id']) : null;
    title = json['title'] != null ? new Id.fromJson(json['title']) : null;
    updated = json['updated'] != null ? new Id.fromJson(json['updated']) : null;
    icon = json['icon'] != null ? new Id.fromJson(json['icon']) : null;
    author =
    json['author'] != null ? new Author.fromJson(json['author']) : null;
    if (json['link'] != null) {
      link = new List<Link>();
      json['link'].forEach((v) {
        link.add(new Link.fromJson(v));
      });
    }
    opensearchTotalResults = json[r'opensearch$totalResults'] != null
        ? new Id.fromJson(json[r'opensearch$totalResults'])
        : null;
    opensearchItemsPerPage = json[r'opensearch$itemsPerPage'] != null
        ? new Id.fromJson(json[r'opensearch$itemsPerPage'])
        : null;
    opensearchStartIndex = json[r'opensearch$startIndex'] != null
        ? new Id.fromJson(json[r'opensearch$startIndex'])
        : null;
    if (json['entry'] != null) {
      String t = json['entry'].runtimeType.toString();
      if(t == "List<dynamic>" || t == "_GrowableList<dynamic>"){
        entry = new List<Entry>();
        json['entry'].forEach((v) {
          entry.add(new Entry.fromJson(v));
        });
      }else{
        entry = new List<Entry>();
        entry.add(new Entry.fromJson(json['entry']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xml:lang'] = this.xmlLang;
    data[r'xmlns'] = this.xmlns;
    data[r'xmlns$dcterms'] = this.xmlnsDcterms;
    data[r'xmlns$thr'] = this.xmlnsThr;
    data[r'xmlns$app'] = this.xmlnsApp;
    data[r'xmlns$opensearch'] = this.xmlnsOpensearch;
    data[r'xmlns$opds'] = this.xmlnsOpds;
    data[r'xmlns$xsi'] = this.xmlnsXsi;
    data[r'xmlns$odl'] = this.xmlnsOdl;
    data[r'xmlns$schema'] = this.xmlnsSchema;
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    if (this.updated != null) {
      data['updated'] = this.updated.toJson();
    }
    if (this.icon != null) {
      data['icon'] = this.icon.toJson();
    }
    if (this.author != null) {
      data['author'] = this.author.toJson();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    if (this.opensearchTotalResults != null) {
      data[r'opensearch$totalResults'] = this.opensearchTotalResults.toJson();
    }
    if (this.opensearchItemsPerPage != null) {
      data[r'opensearch$itemsPerPage'] = this.opensearchItemsPerPage.toJson();
    }
    if (this.opensearchStartIndex != null) {
      data[r'opensearch$startIndex'] = this.opensearchStartIndex.toJson();
    }
    if (this.entry != null) {
      data['entry'] = this.entry.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Id {
  String t;

  Id({this.t});

  Id.fromJson(Map<String, dynamic> json) {
    t = json[r'$t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[r'$t'] = this.t;
    return data;
  }
}

class Author {
  Id name;
  Id uri;
  Id email;

  Author({this.name, this.uri, this.email});

  Author.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null ? new Id.fromJson(json['name']) : null;
    uri = json['uri'] != null ? new Id.fromJson(json['uri']) : null;
    email = json['email'] != null ? new Id.fromJson(json['email']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.name != null) {
      data['name'] = this.name.toJson();
    }
    if (this.uri != null) {
      data['uri'] = this.uri.toJson();
    }
    if (this.email != null) {
      data['email'] = this.email.toJson();
    }
    return data;
  }
}

class Link {
  String rel;
  String type;
  String href;
  String title;
  String opdsActiveFacet;
  String opdsFacetGroup;
  String thrCount;

  Link(
      {this.rel,
        this.type,
        this.href,
        this.title,
        this.opdsActiveFacet,
        this.opdsFacetGroup,
        this.thrCount});

  Link.fromJson(Map<String, dynamic> json) {
    rel = json['rel'];
    type = json['type'];
    href = json['href'];
    title = json['title'];
    opdsActiveFacet = json['opds:activeFacet'];
    opdsFacetGroup = json['opds:facetGroup'];
    thrCount = json['thr:count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rel'] = this.rel;
    data['type'] = this.type;
    data['href'] = this.href;
    data['title'] = this.title;
    data['opds:activeFacet'] = this.opdsActiveFacet;
    data['opds:facetGroup'] = this.opdsFacetGroup;
    data['thr:count'] = this.thrCount;
    return data;
  }
}

class Entry {
  Id title;
  Id id;
  Author1 author;
  Id published;
  Id updated;
  Id dctermsLanguage;
  Id dctermsPublisher;
  Id dctermsIssued;
  Id summary;
  List<Category> category;
  List<Link1> link;
  SchemaSeries schemaSeries;

  Entry(
      {this.title,
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
        this.schemaSeries});

  Entry.fromJson(Map<String, dynamic> json) {
    title = json['title'] != null ? new Id.fromJson(json['title']) : null;
    id = json['id'] != null ? new Id.fromJson(json['id']) : null;
    if(json['author'] != null){
      if(json['author'].runtimeType.toString() == "List<dynamic>"){
        author = Author1.fromJson(json['author'][0]);
      }else{
        author = Author1.fromJson(json['author']);
      }
    }

    published =
    json['published'] != null ? new Id.fromJson(json['published']) : null;
    updated = json['updated'] != null ? new Id.fromJson(json['updated']) : null;
    dctermsLanguage = json[r'dcterms$language'] != null
        ? new Id.fromJson(json[r'dcterms$language'])
        : null;
    dctermsPublisher = json[r'dcterms$publisher'] != null
        ? new Id.fromJson(json[r'dcterms$publisher'])
        : null;
    dctermsIssued = json[r'dcterms$issued'] != null
        ? new Id.fromJson(json[r'dcterms$issued'])
        : null;
    summary = json['summary'] != null ? new Id.fromJson(json['summary']) : null;
    if (json['category'] != null) {
      String t = json['category'].runtimeType.toString();
      if(t == "List<dynamic>" || t == "_GrowableList<dynamic>"){
        category = new List<Category>();
        json['category'].forEach((v) {
          category.add(new Category.fromJson(v));
        });
      }else{
        category = new List<Category>();
        category.add(new Category.fromJson(json['category']));
      }
    }
    if (json['link'] != null) {
      link = new List<Link1>();
      json['link'].forEach((v) {
        link.add(new Link1.fromJson(v));
      });
    }
    schemaSeries = json[r'schema$Series'] != null
        ? new SchemaSeries.fromJson(json[r'schema$Series'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    if (this.author != null) {
      data['author'] = this.author.toJson();
    }
    if (this.published != null) {
      data['published'] = this.published.toJson();
    }
    if (this.updated != null) {
      data['updated'] = this.updated.toJson();
    }
    if (this.dctermsLanguage != null) {
      data[r'dcterms$language'] = this.dctermsLanguage.toJson();
    }
    if (this.dctermsPublisher != null) {
      data[r'dcterms$publisher'] = this.dctermsPublisher.toJson();
    }
    if (this.dctermsIssued != null) {
      data[r'dcterms$issued'] = this.dctermsIssued.toJson();
    }
    if (this.summary != null) {
      data['summary'] = this.summary.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category.map((v) => v.toJson()).toList();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    if (this.schemaSeries != null) {
      data[r'schema$Series'] = this.schemaSeries.toJson();
    }
    return data;
  }
}

class Author1 {
  Id name;
  Id uri;

  Author1({this.name, this.uri});

  Author1.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null ? new Id.fromJson(json['name']) : null;
    uri = json['uri'] != null ? new Id.fromJson(json['uri']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.name != null) {
      data['name'] = this.name.toJson();
    }
    if (this.uri != null) {
      data['uri'] = this.uri.toJson();
    }
    return data;
  }
}

class Category {
  String label;
  String term;
  String scheme;

  Category({this.label, this.term, this.scheme});

  Category.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    term = json['term'];
    scheme = json['scheme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['term'] = this.term;
    data['scheme'] = this.scheme;
    return data;
  }
}

class Link1 {
  String type;
  String rel;
  String title;
  String href;

  Link1({this.type, this.rel, this.title, this.href});

  Link1.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    rel = json['rel'];
    title = json['title'];
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['rel'] = this.rel;
    data['title'] = this.title;
    data['href'] = this.href;
    return data;
  }
}

class SchemaSeries {
  String schemaPosition;
  String schemaName;
  String schemaUrl;

  SchemaSeries({this.schemaPosition, this.schemaName, this.schemaUrl});

  SchemaSeries.fromJson(Map<String, dynamic> json) {
    schemaPosition = json[r'schema:position'];
    schemaName = json[r'schema:name'];
    schemaUrl = json[r'schema:url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[r'schema:position'] = this.schemaPosition;
    data[r'schema:name'] = this.schemaName;
    data[r'schema:url'] = this.schemaUrl;
    return data;
  }
}
