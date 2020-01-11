class CategoryFeed {
  Feed feed;

  CategoryFeed({this.feed});

  CategoryFeed.fromJson(Map<String, dynamic> json) {
    feed = json['feed'] != null ? new Feed.fromJson(json['feed']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.feed != null) {
      data['feed'] = this.feed.toJson();
    }
    return data;
  }
}

class Feed {
  String xmlnsDcterms;
  String xmlnsThr;
  String xmlnsApp;
  String xmlnsOpensearch;
  String xmlns;
  String xmlnsOpds;
  String xmlnsXsi;
  String xmlLang;
  String xmlnsOdl;
  String xmlnsSchema;
  String id;
  String title;
  String updated;
  String icon;
  Author author;
  List<Link> link;
  String opensearchTotalResults;
  String opensearchItemsPerPage;
  String opensearchStartIndex;
  List<Entry> entry;

  Feed(
      {this.xmlnsDcterms,
        this.xmlnsThr,
        this.xmlnsApp,
        this.xmlnsOpensearch,
        this.xmlns,
        this.xmlnsOpds,
        this.xmlnsXsi,
        this.xmlLang,
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
    xmlnsDcterms = json['xmlns:dcterms'];
    xmlnsThr = json['xmlns:thr'];
    xmlnsApp = json['xmlns:app'];
    xmlnsOpensearch = json['xmlns:opensearch'];
    xmlns = json['xmlns'];
    xmlnsOpds = json['xmlns:opds'];
    xmlnsXsi = json['xmlns:xsi'];
    xmlLang = json['xml:lang'];
    xmlnsOdl = json['xmlns:odl'];
    xmlnsSchema = json['xmlns:schema'];
    id = json['id'];
    title = json['title'];
    updated = json['updated'];
    icon = json['icon'];
    author =
    json['author'] != null ? new Author.fromJson(json['author']) : null;
    if (json['link'] != null) {
      link = new List<Link>();
      json['link'].forEach((v) {
        link.add(new Link.fromJson(v));
      });
    }
    opensearchTotalResults = json['opensearch:totalResults'];
    opensearchItemsPerPage = json['opensearch:itemsPerPage'];
    opensearchStartIndex = json['opensearch:startIndex'];
    if (json['entry'] != null) {
      entry = new List<Entry>();
      json['entry'].forEach((v) {
        entry.add(new Entry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xmlns:dcterms'] = this.xmlnsDcterms;
    data['xmlns:thr'] = this.xmlnsThr;
    data['xmlns:app'] = this.xmlnsApp;
    data['xmlns:opensearch'] = this.xmlnsOpensearch;
    data['xmlns'] = this.xmlns;
    data['xmlns:opds'] = this.xmlnsOpds;
    data['xmlns:xsi'] = this.xmlnsXsi;
    data['xml:lang'] = this.xmlLang;
    data['xmlns:odl'] = this.xmlnsOdl;
    data['xmlns:schema'] = this.xmlnsSchema;
    data['id'] = this.id;
    data['title'] = this.title;
    data['updated'] = this.updated;
    data['icon'] = this.icon;
    if (this.author != null) {
      data['author'] = this.author.toJson();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    data['opensearch:totalResults'] = this.opensearchTotalResults;
    data['opensearch:itemsPerPage'] = this.opensearchItemsPerPage;
    data['opensearch:startIndex'] = this.opensearchStartIndex;
    if (this.entry != null) {
      data['entry'] = this.entry.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Author {
  String name;
  String uri;
  String email;

  Author({this.name, this.uri, this.email});

  Author.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uri = json['uri'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['uri'] = this.uri;
    data['email'] = this.email;
    return data;
  }
}

class Link {
  String rel;
  String title;
  String type;
  String href;
  String opdsActiveFacet;
  String opdsFacetGroup;

  Link(
      {this.rel,
        this.title,
        this.type,
        this.href,
        this.opdsActiveFacet,
        this.opdsFacetGroup});

  Link.fromJson(Map<String, dynamic> json) {
    rel = json['rel'];
    title = json['title'];
    type = json['type'];
    href = json['href'];
    opdsActiveFacet = json['opds:activeFacet'];
    opdsFacetGroup = json['opds:facetGroup'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rel'] = this.rel;
    data['title'] = this.title;
    data['type'] = this.type;
    data['href'] = this.href;
    data['opds:activeFacet'] = this.opdsActiveFacet;
    data['opds:facetGroup'] = this.opdsFacetGroup;
    return data;
  }
}

class Entry {
  String title;
  String id;
  Author1 author;
  String published;
  String updated;
  String dctermsLanguage;
  String dctermsPublisher;
  String dctermsIssued;
  String summary;
  List<Category1> category;
  List<Link1> link;

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
        this.link});

  Entry.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    id = json['id'];
    author =
    json['author'] != null ? new Author1.fromJson(json['author']) : null;
    published = json['published'];
    updated = json['updated'];
    dctermsLanguage = json['dcterms:language'];
    dctermsPublisher = json['dcterms:publisher'];
    dctermsIssued = json['dcterms:issued'];
    summary = json['summary'];
    if (json['category'] != null) {
      category = new List<Category1>();
      json['category'].forEach((v) {
        category.add(new Category1.fromJson(v));
      });
    }
    if (json['link'] != null) {
      link = new List<Link1>();
      json['link'].forEach((v) {
        link.add(new Link1.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['id'] = this.id;
    if (this.author != null) {
      data['author'] = this.author.toJson();
    }
    data['published'] = this.published;
    data['updated'] = this.updated;
    data['dcterms:language'] = this.dctermsLanguage;
    data['dcterms:publisher'] = this.dctermsPublisher;
    data['dcterms:issued'] = this.dctermsIssued;
    data['summary'] = this.summary;
    if (this.category != null) {
      data['category'] = this.category.map((v) => v.toJson()).toList();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Author1 {
  String name;
  String uri;

  Author1({this.name, this.uri});

  Author1.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uri = json['uri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['uri'] = this.uri;
    return data;
  }
}

class Category1 {
  String label;
  String term;
  String scheme;

  Category1({this.label, this.term, this.scheme});

  Category1.fromJson(Map<String, dynamic> json) {
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
