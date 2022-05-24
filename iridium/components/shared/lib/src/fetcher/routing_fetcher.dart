// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

typedef AcceptLink = bool Function(Link);

/// Routes requests to child fetchers, depending on a provided predicate.
///
/// This can be used for example to serve a publication containing both local and remote resources,
/// and more generally to concatenate different content sources.
///
/// The [routes] will be tested in the given order.
class RoutingFetcher extends Fetcher {
  final List<Route> routes;

  RoutingFetcher(this.routes);

  factory RoutingFetcher.simple(Fetcher local, Fetcher remote) =>
      RoutingFetcher([
        Route(local, accepts: (l) => l.href.startsWith("/")),
        Route(remote)
      ]);

  @override
  Future<List<Link>> links() async {
    List<Link> links = [];
    for (Route route in routes) {
      links.addAll(await route.fetcher.links());
    }
    return links;
  }

  @override
  Resource get(Link link) {
    Route? route = routes.firstOrNullWhere((it) => it.accepts(link));
    if (route != null) {
      return route.fetcher.get(link);
    }
    return FailureResource(link, ResourceException.notFound);
  }

  @override
  Future<void> close() async {
    for (Route route in routes) {
      route.fetcher.close();
    }
  }
}

AcceptLink get _defaultAcceptLink => (Link l) => true;

class Route {
  final Fetcher fetcher;
  final AcceptLink accepts;

  Route(this.fetcher, {AcceptLink? accepts})
      : this.accepts = accepts ?? _defaultAcceptLink;
}
