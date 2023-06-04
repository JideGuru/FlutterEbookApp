// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/extensions/uri.dart';
import 'package:mno_commons/utils/ref.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/mediatype/mediatype.dart';

typedef ServiceFactory = PublicationService? Function(
    PublicationServiceContext);

/// The Publication shared model is the entry-point for all the metadata and services
/// related to a Readium publication.
///
/// @param manifest The manifest holding the publication metadata extracted from the publication file.
/// @param fetcher The underlying fetcher used to read publication resources.
/// The default implementation returns Resource.Exception.NotFound for all HREFs.
/// @param servicesBuilder Holds the list of service factories used to create the instances of
/// Publication.Service attached to this Publication.
/// @param positionsFactory Factory used to build lazily the [positions].
class Publication with EquatableMixin {
  final Manifest manifest;
  final Fetcher fetcher;

  // FIXME: To refactor after specifying the User and Rendition Settings API
  Map<ReadiumCSSName, bool> userSettingsUIPreset;
  String? cssStyle;

  late List<PublicationService> _services;
  late Manifest _manifest;
  TYPE? _type;
  int nbPages = 0;
  Map<Link, LinkPagination> paginationInfo = {};

  Publication({
    required this.manifest,
    this.fetcher = const EmptyFetcher(),
    ServicesBuilder? servicesBuilder,
    this.userSettingsUIPreset = const {},
    this.cssStyle,
  }) {
    // We use a Ref<Publication> instead of passing directly `this` to the services to prevent
    // them from using the Publication before it is fully initialized.
    Ref<Publication> pubRef = Ref<Publication>();
    servicesBuilder ??= ServicesBuilder.create();

    _services = servicesBuilder
        .build(PublicationServiceContext(pubRef, manifest, fetcher));
    _manifest = manifest.copy(
        links: manifest.links +
            _services.map((it) => it.links).flatten().toList());

    pubRef.ref = this;
  }

  // Shortcuts to manifest properties

  List<String> get context => _manifest.context;

  Metadata get metadata => _manifest.metadata;

  List<Link> get links => _manifest.links;

  /// Identifies a list of resources in reading order for the publication.
  List<Link> get readingOrder => _manifest.readingOrder;

  /// Identifies resources that are necessary for rendering the publication.
  List<Link> get resources => _manifest.resources;

  /// Identifies the collection that contains a table of contents.
  List<Link> get tableOfContents => _manifest.tableOfContents;

  Map<String, List<PublicationCollection>> get subcollections =>
      _manifest.subcollections;

  // FIXME: To be refactored, with the TYPE and EXTENSION enums as well
  TYPE get type {
    if (_type == null) {
      if (metadata.type == "http://schema.org/Audiobook" ||
          readingOrder.allAreAudio) {
        _type = TYPE.audio;
      } else if (readingOrder.allAreBitmap) {
        _type = TYPE.divina;
      } else {
        _type = TYPE.webpub;
      }
    }
    return _type!;
  }

  set type(TYPE type) => _type = type;

  /// Returns the RWPM JSON representation for this [Publication]'s manifest, as a string.
  String get jsonManifest =>
      JsonCodec().encode(_manifest.toJson()).replaceAll("\\/", "/");

  /// The URL where this publication is served, computed from the [Link] with `self` relation.
  Uri? get baseUrl => links
      .firstWithRel("self")
      ?.let((it) => it.href.toUrlOrNull()?.removeLastComponent());

  /// Finds the first [Link] with the given HREF in the publication's links.
  ///
  /// Searches through (in order) [readingOrder], [resources] and [links] recursively following
  /// [alternate] and [children] links.
  ///
  /// If there's no match, try again after removing any query parameter and anchor from the
  /// given [href].
  Link? linkWithHref(String href) {
    Link? find(String href) =>
        readingOrder.deepLinkWithHref(href) ??
        resources.deepLinkWithHref(href) ??
        links.deepLinkWithHref(href);

    return find(href) ?? find(href.takeWhile((it) => !"#?".contains(it)));
  }

  /// Finds the first [Link] having the given [rel] in the publications's links.
  Link? linkWithRel(String rel) => _manifest.linkWithRel(rel);

  /// Finds all [Link]s having the given [rel] in the publications's links.
  List<Link> linksWithRel(String rel) => _manifest.linksWithRel(rel);

  /// Finds the first [Link] to the publication's cover (rel = cover).
  Link? get coverLink => linkWithRel("cover");

  /// Finds the first resource [Link] (asset or [readingOrder] item) at the given relative path.
  Link? resourceWithHref(String href) =>
      readingOrder.deepLinkWithHref(href) ?? resources.deepLinkWithHref(href);

  /// Returns the resource targeted by the given non-templated [link].
  Resource get(Link link) {
    for (PublicationService service in _services) {
      Resource? r = service.get(link);
      if (r != null) {
        return r;
      }
    }
    return fetcher.get(link);
  }

  /// Closes any opened resource associated with the [Publication], including services.
  void close() {
    try {
      fetcher.close();
    } on Exception catch (e) {
      Fimber.e("ERROR closing fetcher $fetcher", ex: e);
    }
    for (PublicationService it in _services) {
      try {
        it.close();
      } on Exception catch (e) {
        Fimber.e("ERROR closing service $it", ex: e);
      }
    }
  }

  /// Returns the first publication service that is an instance of [Type].
  T? findService<T extends PublicationService>() =>
      findServices<T>().firstOrNull;

  /// Returns all the publication services that are instances of [Type].
  Iterable<T> findServices<T extends PublicationService>() =>
      _services.where((service) => service.serviceType == T).whereType<T>();

  /// Sets the URL where this [Publication]'s RWPM manifest is served.
  void setSelfLink(String href) {
    List<Link> list = _manifest.links.toList();
    list.removeWhere((it) => it.rels.contains("self"));
    list.add(Link(
        href: href,
        type: MediaType.readiumWebpubManifest.toString(),
        rels: {"self"}));
    _manifest.links = list;
  }

  /// Returns the [links] of the first child [PublicationCollection] with the given role, or an
  /// empty list.
  List<Link> linksWithRole(String role) =>
      subcollections[role]?.firstOrNull?.links ?? [];

  @override
  List<Object?> get props => [
        manifest,
        cssStyle,
        nbPages,
      ];

  @override
  String toString() =>
      'Publication{metadata: $metadata, fetcher: $fetcher, nbPages: $nbPages}';

  /// Creates the base URL for a [Publication] locally served through HTTP, from the
  /// publication's [filename] and the HTTP server [port].
  ///
  /// Note: This is used for backward-compatibility, but ideally this should be handled by the
  /// Server, and set in the self [Link]. Unfortunately, the self [Link] is not available
  /// in the navigator at the moment without changing the code in reading apps.
  static String localBaseUrlOf(String filename, int port) {
    String sanitizedFilename = filename
        .removePrefix("/")
        .hashWith(crypto.md5)
        .let((it) => Uri.encodeComponent(it));
    return "http://127.0.0.1:$port/$sanitizedFilename";
  }

  /// Gets the absolute URL of a resource locally served through HTTP.
  static String localUrlOf(String filename, int port, String href) =>
      localBaseUrlOf(filename, port) + href;
}

enum TYPE { epub, cbz, fxl, webpub, audio, divina }

class EXTENSION {
  static const EXTENSION epub = EXTENSION._(".epub");
  static const EXTENSION cbz = EXTENSION._(".cbz");
  static const EXTENSION json = EXTENSION._(".json");
  static const EXTENSION divina = EXTENSION._(".divina");
  static const EXTENSION audio = EXTENSION._(".audiobook");
  static const EXTENSION lcpl = EXTENSION._(".lcpl");
  static const EXTENSION unknown = EXTENSION._("");
  static const List<EXTENSION> _values = [
    epub,
    cbz,
    json,
    divina,
    audio,
    lcpl,
    unknown
  ];

  final String value;

  const EXTENSION._(this.value);

  static EXTENSION? fromString(String type) =>
      _values.firstOrNullWhere((element) => element.value == type);
}

/// Base interface to be implemented by all publication services.
abstract class PublicationService {
  /// Links which will be added to [Publication.links].
  /// It can be used to expose a web API for the service, through [Publication.get].
  ///
  /// To disambiguate the href with a publication's local resources, you should use the prefix
  /// `/~readium/`. A custom media type or rel should be used to identify the service.
  ///
  /// You can use a templated URI to accept query parameters, e.g.:
  ///
  /// ```
  /// Link(
  ///     href = "/~readium/search{?text}",
  ///     type = "application/vnd.readium.search+json",
  ///     templated = true
  /// )
  /// ```
  List<Link> get links => [];

  /// This is the supertype of the service that the subclass is implementing
  Type get serviceType;

  /// A service can return a Resource to:
  ///  - respond to a request to its web API declared in links,
  ///  - serve additional resources on behalf of the publication,
  ///  - replace a publication resource by its own version.
  ///
  /// Called by [Publication.get] for each request.
  ///
  /// Warning: If you need to request one of the publication resources to answer the request,
  /// use the [Fetcher] provided by the [PublicationServiceContext] instead of
  /// [Publication.get], otherwise it will trigger an infinite loop.
  ///
  /// @return The [Resource] containing the response, or null if the service doesn't recognize
  ///         this request.
  Resource? get(Link link) => null;

  /// Closes any opened file handles, removes temporary files, etc.
  void close() {}
}

/// Container for the context from which a service is created.
///
/// @param publication Reference to the parent publication.
/// Don't store directly the referenced publication, always access it through the
/// [Ref] property. The publication won't be set when the service is created or when
/// calling [PublicationService.links], but you can use it during regular service operations. If
/// you need to initialize your service differently depending on the publication, use
/// `manifest`.
class PublicationServiceContext {
  final Ref<Publication> publication;
  final Manifest manifest;
  final Fetcher fetcher;

  PublicationServiceContext(this.publication, this.manifest, this.fetcher);
}

/// Builds a list of [PublicationService] from a collection of service factories.
///
/// Provides helpers to manipulate the list of services of a [Publication].
class ServicesBuilder {
  final Map<Type, ServiceFactory> serviceFactories;

  const ServicesBuilder._(this.serviceFactories);

  factory ServicesBuilder.create(
          {ServiceFactory? contentProtection,
          ServiceFactory? cover,
          ServiceFactory? locator = _defaultLocator,
          ServiceFactory? positions}) =>
      ServicesBuilder._({
        if (contentProtection != null)
          ContentProtectionService: contentProtection,
        if (cover != null) CoverService: cover,
        if (locator != null) LocatorService: locator,
        if (positions != null) PositionsService: positions
      });

  static LocatorService _defaultLocator(PublicationServiceContext context) =>
      DefaultLocatorService.create(
          context.manifest.readingOrder, context.publication);

  /// Builds the actual list of publication services to use in a Publication.
  List<PublicationService> build(PublicationServiceContext context) =>
      serviceFactories.values
          .whereNotNull()
          .mapNotNull((it) => it(context))
          .toList();

  /// Gets the publication service factory for the given service type.
  ServiceFactory? of<T extends PublicationService>() => serviceFactories[T];

  /// Sets the publication service factory for the given service type.
  void set<T>(ServiceFactory? factory) {
    if (factory != null) {
      serviceFactories[T] = factory;
    } else {
      serviceFactories.remove(T);
    }
  }

  /// Removes the service factory producing the given kind of service, if any.
  void remove(Type serviceType) => serviceFactories.remove(serviceType);

  /// Replaces the service factory associated with the given service type with the result of
  /// [transform].
  void decorate(Type serviceType,
          ServiceFactory Function(ServiceFactory?) transform) =>
      serviceFactories[serviceType] = transform(serviceFactories[serviceType]);
}

/// Builds a Publication from its components.
///
/// A Publication's construction is distributed over the Streamer and its parsers,
/// so a builder is useful to pass the parts around.
class PublicationBuilder {
  Manifest manifest;
  Fetcher fetcher;
  ServicesBuilder servicesBuilder;

  PublicationBuilder(
      {required this.manifest,
      required this.fetcher,
      ServicesBuilder? servicesBuilder})
      : this.servicesBuilder = servicesBuilder ?? ServicesBuilder.create();

  Publication build() => Publication(
      manifest: manifest, fetcher: fetcher, servicesBuilder: servicesBuilder);
}
