// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

abstract class RouteHandler {
  static final List<RouteHandler> handlers = [
    _ContentProtectionHandler(),
    _RightsCopyHandler(),
    _RightsPrintHandler()
  ];

  Link get link;

  static List<Link> get links => handlers.map((it) => it.link).toList();

  static RouteHandler? route(Link link) =>
      handlers.firstOrNullWhere((it) => it.acceptRequest(link));

  bool acceptRequest(Link link);

  Resource handleRequest(Link link, ContentProtectionService service);
}

class _ContentProtectionHandler extends RouteHandler {
  @override
  Link get link => Link(
      href: "/~readium/content-protection",
      type: "application/vnd.readium.content-protection+json");

  @override
  bool acceptRequest(Link link) => link.href == this.link.href;

  @override
  Resource handleRequest(Link link, ContentProtectionService service) =>
      StringResource(
          link,
          () async => json.encode(<String, dynamic>{}
            ..put("isRestricted", service.isRestricted)
            ..putOpt("error", service.error?.toString())
            ..putJSONableIfNotEmpty("name", service.name)
            ..put("rights", service.rights.toJson())));
}

class _RightsCopyHandler extends RouteHandler {
  @override
  Link get link => Link(
      href: "/~readium/rights/copy{?text,peek}",
      type: "application/vnd.readium.rights.copy+json",
      templated: true);

  @override
  bool acceptRequest(Link link) =>
      link.href.startsWith("/~readium/rights/copy");

  @override
  Resource handleRequest(Link link, ContentProtectionService service) {
    Map<String, String> parameters = link.href.queryParameters();
    String? text = parameters["text"];
    if (text == null) {
      return FailureResource(
          link,
          ResourceException.badRequest(parameters,
              cause: Exception("'text' parameter is required")));
    }

    bool? peek = (parameters["peek"] ?? "false").toBooleanOrNull();
    if (peek == null) {
      return FailureResource(
          link,
          ResourceException.badRequest(parameters,
              cause: Exception("if present, 'peek' must be true or false")));
    }
    bool copyAllowed = service.rights
        .let((it) => (peek) ? it.canCopyText(text) : it.copy(text));
    return copyAllowed
        ? FailureResource(link, ResourceException.forbidden)
        : StringResource(link, () async => "true");
  }
}

class _RightsPrintHandler extends RouteHandler {
  @override
  Link get link => Link(
      href: "/~readium/rights/print{?pageCount,peek}",
      type: "application/vnd.readium.rights.print+json",
      templated: true);

  @override
  bool acceptRequest(Link link) =>
      link.href.startsWith("/~readium/rights/print");

  @override
  Resource handleRequest(Link link, ContentProtectionService service) {
    Map<String, String> parameters = link.href.queryParameters();
    String? pageCountString = parameters["pageCount"];
    if (pageCountString == null) {
      return FailureResource(
          link,
          ResourceException.badRequest(parameters,
              cause: Exception("'pageCount' parameter is required")));
    }

    int? pageCount = int.tryParse(pageCountString)?.takeIf((it) => it >= 0);
    if (pageCount == null) {
      return FailureResource(
          link,
          ResourceException.badRequest(parameters,
              cause: Exception("'pageCount' must be a positive integer")));
    }
    bool? peek = (parameters["peek"] ?? "false").toBooleanOrNull();
    if (peek == null) {
      return FailureResource(
          link,
          ResourceException.badRequest(parameters,
              cause: Exception("if present, 'peek' must be true or false")));
    }

    bool printAllowed = service.rights.let(
        (it) => (peek) ? it.canPrintPageCount(pageCount) : it.print(pageCount));
    return printAllowed
        ? FailureResource(link, ResourceException.forbidden)
        : StringResource(link, () async => "true");
  }
}

extension UserRightsExtension on UserRights {
  Map<String, dynamic> toJson() => {
        "canCopy": canCopy,
        "canPrint": canPrint,
      };
}
