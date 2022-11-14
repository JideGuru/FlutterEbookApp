// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xml/xml.dart';

extension XmlNodeExtension on XmlNode {
  static const String _xmlNsUri = "http://www.w3.org/XML/1998/namespace";

  String? get id => getAttribute("id");

  String get lang =>
      getAttribute("lang", namespace: _xmlNsUri) ??
      getAttribute("xml:lang") ??
      parent?.lang ??
      "";
}
