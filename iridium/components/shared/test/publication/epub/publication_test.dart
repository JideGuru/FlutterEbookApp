// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/publication/epub/publication.dart';
import 'package:test/test.dart';

void main() {
  Publication createPublication(
          {Map<String, List<PublicationCollection>> subcollections =
              const {}}) =>
      Publication(
          manifest: Manifest(
              metadata:
                  Metadata(localizedTitle: LocalizedString.fromString("Title")),
              subcollections: subcollections));

  test("get {pageList}", () {
    var links = [Link(href: "/page1.html")];
    expect(
        links,
        createPublication(subcollections: {
          "pageList": [PublicationCollection(links: links)]
        }).pageList);
  });

  test("get {pageList} when missing", () {
    expect(0, createPublication().pageList.length);
  });

  test("get {landmarks}", () {
    var links = [Link(href: "/landmark.html")];
    expect(
        links,
        createPublication(subcollections: {
          "landmarks": [PublicationCollection(links: links)]
        }).landmarks);
  });

  test("get {landmarks} when missing", () {
    expect(0, createPublication().landmarks.length);
  });

  test("get {listOfAudioClips}", () {
    var links = [Link(href: "/audio.mp3")];
    expect(
        links,
        createPublication(subcollections: {
          "loa": [PublicationCollection(links: links)]
        }).listOfAudioClips);
  });

  test("get {listOfAudioClips} when missing", () {
    expect(0, createPublication().listOfAudioClips.length);
  });

  test("get {listOfIllustrations}", () {
    var links = [Link(href: "/image.jpg")];
    expect(
        links,
        createPublication(subcollections: {
          "loi": [PublicationCollection(links: links)]
        }).listOfIllustrations);
  });

  test("get {listOfIllustrations} when missing", () {
    expect(0, createPublication().listOfIllustrations.length);
  });

  test("get {listOfTables}", () {
    var links = [Link(href: "/table.html")];
    expect(
        links,
        createPublication(subcollections: {
          "lot": [PublicationCollection(links: links)]
        }).listOfTables);
  });

  test("get {listOfTables} when missing", () {
    expect(0, createPublication().listOfTables.length);
  });

  test("get {listOfVideoClips}", () {
    var links = [Link(href: "/video.mov")];
    expect(
        links,
        createPublication(subcollections: {
          "lov": [PublicationCollection(links: links)]
        }).listOfVideoClips);
  });

  test("get {listOfVideoClips} when missing", () {
    expect(0, createPublication().listOfVideoClips.length);
  });
}
