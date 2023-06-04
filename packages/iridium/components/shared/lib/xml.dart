// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xml/xml.dart' as xml;

/// Wrapper around the XML package that adds a better API, basic XPath queries
/// handling namespace prefixes.
abstract class XmlNode<Node extends xml.XmlNode> {
  XmlNode(this._node, {Map<String, String>? prefixes})
      : prefixes = prefixes ?? {};

  final Node _node;

  /// Maps a namespace prefix to its URI.
  Map<String, String> prefixes;

  List<XmlElement> xpath(String xpath) => _xpathString(xpath);

  XmlElement? firstXPath(String xpath) {
    List<XmlElement> elements = _xpathString(xpath, onlyFirst: true);
    return (elements.isEmpty) ? null : elements.first;
  }

  List<XmlElement> _xpathString(String xpath, {bool onlyFirst = false}) => xpath
      .split('|')
      .expand((path) => _xpath(path.split('/'), onlyFirst: onlyFirst))
      .toList();

  List<XmlElement> _xpath(List<String> paths,
      {bool relative = true, bool onlyFirst = false}) {
    if (paths.isEmpty) {
      return [if (this is XmlElement) this as XmlElement];
    }
    String path = paths.removeAt(0);
    if (path.isEmpty) {
      return _xpath(paths, relative: false, onlyFirst: onlyFirst);
    }

    RegExpMatch? match = RegExp(r'(?:([-\w]+)\:)?([-\w\*]+)').firstMatch(path);
    if (match == null) {
      return [];
    }
    String prefix = match.group(1)!;
    String tag = match.group(2)!;
    String? namespace = prefixes[prefix];

    Iterable<xml.XmlElement> elements = relative
        ? _node.findElements(tag, namespace: namespace)
        : _node.findAllElements(tag, namespace: namespace);

    if (onlyFirst && elements.isNotEmpty) {
      elements = [elements.first];
    }
    return elements
        .expand((e) => XmlElement(e, prefixes: prefixes)
            ._xpath(paths, onlyFirst: onlyFirst))
        .toList();
  }
}

class XmlDocument extends XmlNode<xml.XmlDocument> {
  XmlDocument(super.node, {super.prefixes});

  factory XmlDocument.parse(String input) =>
      XmlDocument(xml.XmlDocument.parse(input));
}

class XmlElement extends XmlNode<xml.XmlElement> {
  XmlElement(super.node, {super.prefixes});

  String get name => _node.name.local;
  String get text => _node.text;

  String? operator [](String name) => getAttribute(name);

  String? getAttribute(String name, {String? namespace}) {
    namespace = prefixes[namespace] ?? namespace;
    return _node.getAttribute(name, namespace: namespace);
  }
}
