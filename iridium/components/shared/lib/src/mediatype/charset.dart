// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:mno_shared/src/mediatype/charsets.dart';

class Charset {
  static const Charset ascii = Charset._("US-ASCII", aliases: [
    "ISO-IR-6",
    "ANSI_X3.4-1968",
    "ANSI_X3.4-1986",
    "ISO_646.IRV:1991",
    "ISO646-US",
    "US-ASCII",
    "US",
    "IBM367",
    "CP367",
    "CSASCII",
    "ASCII",
  ]);
  static const Charset utf8 = Charset._(Charsets.utf8);
  static const Charset utf16 = Charset._(Charsets.utf16);
  static const List<Charset> values = [ascii, utf8, utf16];
  final String name;
  final List<String> aliases;

  const Charset._(this.name, {this.aliases = const []});

  static Charset? forName(String name) => values.firstOrNullWhere((c) =>
      c.name == name.toUpperCase() || c.aliases.contains(name.toUpperCase()));

  @override
  String toString() => 'Charset{name: $name, aliases: $aliases}';
}
