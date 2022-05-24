// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';

class EventType {
  static const EventType register = EventType._("register");
  static const EventType renew = EventType._("renew");
  static const EventType return_ = EventType._("return");
  static const EventType revoke = EventType._("revoke");
  static const EventType cancel = EventType._("cancel");
  final String val;

  const EventType._(this.val);

  @override
  String toString() => 'EventType{val: $val}';
}

class Event {
  final String type;
  final String name;
  final String id;
  final DateTime date;

  Event._(this.type, this.name, this.id, this.date);

  factory Event.parse(Map json) {
    try {
      String name = json["name"];
      DateTime date = DateTime.parse(json["timestamp"]);
      String type = json["type"];
      String id = json["id"];
      return Event._(type, name, id, date);
    } on Exception {
      throw Exception(LcpParsingError.errorDescription(LcpParsingErrors.json));
    }
  }

  static List<Event> parseEvents(List json) =>
      json.map((l) => Event.parse(l)).toList();

  @override
  String toString() => 'Event{type: $type, name: $name, id: $id, date: $date}';
}
