// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

void main() {
  Link link1 = Link(href: "found", rels: {"rel1"});
  Link link2 = Link(href: "found", rels: {"rel2"});
  Link link3 = Link(href: "found", rels: {"rel3"});
  Publication publication = Publication(
      manifest: Manifest(
          metadata: Metadata(
              localizedTitle: LocalizedString.fromString("Title"),
              languages: ["en"]),
          links: [Link(href: "other"), link1],
          readingOrder: [Link(href: "other"), link2],
          resources: [Link(href: "other"), link3]));
  print("manifest: ${publication.manifest.toJson()}");
}
