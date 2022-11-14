// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

void main() {
  Publication createPublication(
          {Map<String, List<PublicationCollection>> subCollections =
              const {}}) =>
      Publication(
          manifest: Manifest(
              metadata:
                  Metadata(localizedTitle: LocalizedString.fromString("Title")),
              subcollections: subCollections));

  test("get {images}", () {
    var links = [Link(href: "/image.png")];
    expect(
        links,
        createPublication(subCollections: {
          "images": [PublicationCollection(links: links)]
        }).images);
  });

  test("get {images} when missing", () {
    expect(0, createPublication().images.length);
  });
}
