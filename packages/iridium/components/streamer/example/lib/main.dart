// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:mno_streamer/parser.dart';
import 'package:universal_io/io.dart' hide Link;
import 'package:xml/xml.dart';

void main() async {
  var document = XmlDocument.parse(await File("lib/links.opf").readAsString());
  var manifest = document
      .let((it) => PackageDocument.parse(it.rootElement, "OEBPS/content.opf"))
      ?.let((it) => PublicationFactory(
          fallbackTitle: "fallback title", packageDocument: it))
      .create();
  print("manifest: $manifest");
}
