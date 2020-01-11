class BookDetails {
  Entry entry;

  BookDetails({this.entry});

  BookDetails.fromJson(Map<String, dynamic> json) {
    entry = json['entry'] != null ? new Entry.fromJson(json['entry']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.entry != null) {
      data['entry'] = this.entry.toJson();
    }
    return data;
  }
}

class Entry {
  String xmlnsSchema;
  String xmlnsThr;
  String xmlns;
  String xmlnsDcterms;
  String title;
  String id;
  Author author;
  String published;
  String updated;
  String dctermsLanguage;
  String dctermsIssued;
  String dctermsPublisher;
  List<Category> category;
  String summary;
  String dctermsExtent;
  String dctermsSource;
  String rights;
  List<Link> link;
  Content content;

  Entry(
      {this.xmlnsSchema,
        this.xmlnsThr,
        this.xmlns,
        this.xmlnsDcterms,
        this.title,
        this.id,
        this.author,
        this.published,
        this.updated,
        this.dctermsLanguage,
        this.dctermsIssued,
        this.dctermsPublisher,
        this.category,
        this.summary,
        this.dctermsExtent,
        this.dctermsSource,
        this.rights,
        this.link,
        this.content});

  Entry.fromJson(Map<String, dynamic> json) {
    xmlnsSchema = json['xmlns:schema'];
    xmlnsThr = json['xmlns:thr'];
    xmlns = json['xmlns'];
    xmlnsDcterms = json['xmlns:dcterms'];
    title = json['title'];
    id = json['id'];
    author =
    json['author'] != null ? new Author.fromJson(json['author']) : null;
    published = json['published'];
    updated = json['updated'];
    dctermsLanguage = json['dcterms:language'];
    dctermsIssued = json['dcterms:issued'];
    dctermsPublisher = json['dcterms:publisher'];
    if (json['category'] != null) {
      category = new List<Category>();
      json['category'].forEach((v) {
        category.add(new Category.fromJson(v));
      });
    }
    summary = json['summary'];
    dctermsExtent = json['dcterms:extent'];
    dctermsSource = json['dcterms:source'];
    rights = json['rights'];
    if (json['link'] != null) {
      link = new List<Link>();
      json['link'].forEach((v) {
        link.add(new Link.fromJson(v));
      });
    }
    content =
    json['content'] != null ? new Content.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xmlns:schema'] = this.xmlnsSchema;
    data['xmlns:thr'] = this.xmlnsThr;
    data['xmlns'] = this.xmlns;
    data['xmlns:dcterms'] = this.xmlnsDcterms;
    data['title'] = this.title;
    data['id'] = this.id;
    if (this.author != null) {
      data['author'] = this.author.toJson();
    }
    data['published'] = this.published;
    data['updated'] = this.updated;
    data['dcterms:language'] = this.dctermsLanguage;
    data['dcterms:issued'] = this.dctermsIssued;
    data['dcterms:publisher'] = this.dctermsPublisher;
    if (this.category != null) {
      data['category'] = this.category.map((v) => v.toJson()).toList();
    }
    data['summary'] = this.summary;
    data['dcterms:extent'] = this.dctermsExtent;
    data['dcterms:source'] = this.dctermsSource;
    data['rights'] = this.rights;
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    if (this.content != null) {
      data['content'] = this.content.toJson();
    }
    return data;
  }
}

class Author {
  String name;
  String uri;
  String schemaBirthDate;
  String schemaDeathDate;

  Author({this.name, this.uri, this.schemaBirthDate, this.schemaDeathDate});

  Author.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uri = json['uri'];
    schemaBirthDate = json['schema:birthDate'];
    schemaDeathDate = json['schema:deathDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['uri'] = this.uri;
    data['schema:birthDate'] = this.schemaBirthDate;
    data['schema:deathDate'] = this.schemaDeathDate;
    return data;
  }
}

class Category {
  String scheme;
  String term;
  String label;

  Category({this.scheme, this.term, this.label});

  Category.fromJson(Map<String, dynamic> json) {
    scheme = json['scheme'];
    term = json['term'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['scheme'] = this.scheme;
    data['term'] = this.term;
    data['label'] = this.label;
    return data;
  }
}

class Link {
  String type;
  String title;
  String rel;
  String href;

  Link({this.type, this.title, this.rel, this.href});

  Link.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    rel = json['rel'];
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['title'] = this.title;
    data['rel'] = this.rel;
    data['href'] = this.href;
    return data;
  }
}

class Content {
  String type;
  String content;

  Content({this.type, this.content});

  Content.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['content'] = this.content;
    return data;
  }
}
