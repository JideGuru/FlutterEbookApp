// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart' hide GroupBy;
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

final Link _positionsLink = Link(
    href: "/~readium/positions",
    type: "application/vnd.readium.position-list+json");

/// Provides a list of discrete locations in the publication, no matter what the original format is.
abstract class PositionsService extends PublicationService {
  /// Returns the list of all the positions in the publication, grouped by the resource reading order index.
  Future<List<List<Locator>>> positionsByReadingOrder();

  /// Returns the list of all the positions in the publication.
  Future<List<Locator>> positions() async =>
      positionsByReadingOrder().then((it) => it.flatten());

  @override
  List<Link> get links => [_positionsLink];

  @override
  Resource? get(Link link) {
    if (link.href != _positionsLink.href) {
      return null;
    }
    return StringResource(_positionsLink, () async {
      List<JSONable> positionList = await positions();
      return json.encode({
        "total": positionList.length,
        "positions": positionList.toJson(),
      });
    });
  }

  @override
  Type get serviceType => PositionsService;
}

/// Simple [PositionsService] for a [Publication] which generates one position per [readingOrder]
/// resource.
///
/// @param fallbackMediaType Media type that will be used as a fallback if the Link doesn't specify
///        any.
class PerResourcePositionsService extends PositionsService {
  final List<Link> readingOrder;
  final String fallbackMediaType;

  PerResourcePositionsService(
      {required this.readingOrder, required this.fallbackMediaType});

  @override
  Future<List<List<Locator>>> positionsByReadingOrder() async {
    int pageCount = readingOrder.length;
    return readingOrder
        .mapIndexed((index, link) => [
              Locator(
                  href: link.href,
                  type: link.type ?? fallbackMediaType,
                  title: link.title,
                  locations: Locations(
                      position: index + 1,
                      totalProgression:
                          index.toDouble() / pageCount.toDouble()))
            ])
        .toList();
  }

  static ServiceFactory createFactory({required String fallbackMediaType}) =>
      (context) => PerResourcePositionsService(
          readingOrder: context.manifest.readingOrder,
          fallbackMediaType: fallbackMediaType);
}

extension ServicesBuilderPositionExtension on ServicesBuilder {
  ServiceFactory? getPositionsServiceFactory() => of<PositionsService>();

  set positionsServiceFactory(ServiceFactory serviceFactory) =>
      set<PositionsService>(serviceFactory);
}

extension PublicationExtension on Publication {
  Future<List<Locator>> positionsFromManifest() async {
    ResourceTry<String?>? resourceString = await links
        .firstWithMediaType(_positionsLink.mediaType)
        ?.let((it) => get(it))
        .readAsString();
    return resourceString
            ?.getOrNull()
            ?.toJsonOrNull()
            ?.optJSONArray("positions")
            ?.mapNotNull((it) => Locator.fromJson(it as Map<String, dynamic>))
            .toList() ??
        [];
  }

  /// Returns the list of all the positions in the publication, grouped by the resource reading order index.
  Future<List<List<Locator>>> positionsByReadingOrder() async {
    PositionsService? service = findService<PositionsService>();
    if (service != null) {
      return service.positionsByReadingOrder();
    }
    Map<String, List<Locator>> locators =
        (await positionsFromManifest()).groupBy((Locator it) => it.href);
    return readingOrder.map((it) => locators[it.href] ?? []).toList();
  }

  /// Returns the list of all the positions in the publication.
  Future<List<Locator>> positions() =>
      findService<PositionsService>()?.positions() ?? positionsFromManifest();
}
