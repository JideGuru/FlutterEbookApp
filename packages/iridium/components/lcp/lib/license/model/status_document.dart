// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:collection/collection.dart';

/// Describes the status of the license.
///
/// - ready: The License Document is available, but the user hasn't accessed
///          the License and/or Status Document yet.
/// - active: The license is active, and a device has been successfully
///           registered for this license. This is the default value if the
///           License Document does not contain a registration link, or a
///           registration mechanism through the license itself.
/// - revoked: The license is no longer active, it has been invalidated by
///            the Issuer.
/// - returned: The license is no longer active, it has been invalidated by
///             the User.
/// - cancelled: The license is no longer active because it was cancelled
///              prior to activation.
/// - expired: The license is no longer active because it has expired.
class Status {
  static const Status ready = Status._("ready");
  static const Status active = Status._("active");
  static const Status revoked = Status._("revoked");
  static const Status returned = Status._("returned");
  static const Status cancelled = Status._("cancelled");
  static const Status expired = Status._("expired");
  static const List<Status> _values = [
    ready,
    active,
    revoked,
    returned,
    cancelled,
    expired,
  ];
  final String value;

  const Status._(this.value);

  @override
  String toString() => 'Status{value: $value}';

  static Status? valueOf(String value) =>
      _values.firstWhereOrNull((status) => status.value == value);
}

class StatusRel {
  static const StatusRel register = StatusRel._("register");
  static const StatusRel license = StatusRel._("license");
  static const StatusRel ret = StatusRel._("return");
  static const StatusRel renew = StatusRel._("renew");
  final String value;

  const StatusRel._(this.value);

  @override
  String toString() => 'StatusRel{value: $value}';
}

/// Document that contains information about the history of a License Document,
/// along with its current status and available interactions.
class StatusDocument {
  final String id;
  final Status status;

  /// A message meant to be displayed to the User regarding the current status
  /// of the license.
  final String message;
  final DateTime licenseUpdated;
  final DateTime statusUpdated;

  /// Must contain at least a link to the LicenseDocument associated to this.
  /// Status Document.
  final Links _links;

  /// Dictionary of potential rights associated with Dates.
  final PotentialRights? potentialRights;

  /// Ordered list of events related to the change in status of a License
  /// Document.
  final List<Event> _events;
  final Map<String, dynamic> jsonObject;

  StatusDocument._(
      this.id,
      this.status,
      this.message,
      this.licenseUpdated,
      this.statusUpdated,
      this._links,
      this.potentialRights,
      this._events,
      this.jsonObject);

  factory StatusDocument.parseData(ByteData data) {
    Uint8List list =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String text = utf8.decode(list);
    Map<String, dynamic> jsonObject;
    try {
      jsonObject = json.decode(text);
      return StatusDocument.parse(jsonObject);
    } on Exception {
      throw Exception(LcpParsingError.errorDescription(LcpParsingErrors.json));
    }
  }

  factory StatusDocument.parse(Map<String, dynamic> json) {
    String? id;
    Status? status;
    String? message;
    Links? links;
    DateTime? licenseUpdated;
    DateTime? statusUpdated;
    PotentialRights? potentialRights;
    List<Event> events = [];

    try {
      if (json.containsKey("id")) id = json["id"];
      if (json.containsKey("status")) {
        status = Status.valueOf(json["status"])!;
      }
      if (json.containsKey("message")) {
        message = json["message"];
      }
      if (json.containsKey("updated")) {
        Map? updatedJson = json["updated"];
        if (updatedJson != null && updatedJson.isNotEmpty) {
          licenseUpdated = DateTime.tryParse(updatedJson["license"]);
          statusUpdated = DateTime.tryParse(updatedJson["status"]);
        }
      }
      if (json.containsKey("links")) {
        links = Links.parse(json["links"] as List);
      }
      if (json.containsKey("events")) {
        events = Event.parseEvents(json["events"] as List);
      }
      if (json.containsKey("potential_rights")) {
        potentialRights = PotentialRights.parse(json["potential_rights"]);
      }
    } on Exception {
      throw Exception(LcpParsingError.errorDescription(LcpParsingErrors.json));
    }
    if (id == null ||
        status == null ||
        message == null ||
        licenseUpdated == null ||
        statusUpdated == null ||
        links == null) {
      throw Exception(LcpParsingError.errorDescription(LcpParsingErrors.json));
    }

    return StatusDocument._(id, status, message, licenseUpdated, statusUpdated,
        links, potentialRights, events, json);
  }

  DateTime? potentialRightsEndDate() => potentialRights?.end;

  Link? link(StatusRel rel, {MediaType? type}) =>
      _links.firstWithRel(rel.value, type: type);

  List<Link>? links(StatusRel rel, {MediaType? type}) =>
      _links.allWithRel(rel.value, type: type);

  Link? linkWithNoType(StatusRel rel) =>
      _links.firstWithRelAndNoType(rel.value);

  Uri url(StatusRel rel,
      {MediaType? preferredType, Map<String, String> parameters = const {}}) {
    Link? l = link(rel, type: preferredType) ?? linkWithNoType(rel);
    if (l == null) {
      throw LcpException.parsing.url(rel.value);
    }

    return l.urlWithParams(parameters: parameters);
  }

  List<Event>? events(EventType type) => eventsWithType(type.val);

  List<Event>? eventsWithType(String type) =>
      _events.where((it) => it.type == type).toList();

  String get description => "Status(${status.value})";

  @override
  String toString() =>
      'StatusDocument{id: $id, status: $status, message: $message, '
      'licenseUpdated: $licenseUpdated, statusUpdated: $statusUpdated, '
      '_links: $_links, potentialRights: $potentialRights, '
      '_events: $_events, jsonObject: $jsonObject}';
}
