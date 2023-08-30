// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/utils/exceptions.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/util/archive/archive.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart' hide Link;
import 'package:xml/xml.dart';

/// Provides access to a [Resource] from a [Link].
abstract class Fetcher {
  const Fetcher();

  /// Known resources available in the medium, such as file paths on the file system
  /// or entries in a ZIP archive. This list is not exhaustive, and additional
  /// unknown resources might be reachable.
  ///
  /// If the medium has an inherent resource order, it should be followed.
  /// Otherwise, HREFs are sorted alphabetically.
  Future<List<Link>> links();

  /// Returns the [Resource] at the given [link]'s HREF.
  ///
  /// A [Resource] is always returned, since for some cases we can't know if it exists before
  /// actually fetching it, such as HTTP. Therefore, errors are handled at the Resource level.
  Resource get(Link link);

  /// Returns the [Resource] at the given [href].
  Resource getWithHref(String href) => get(Link(href: href));

  /// Closes any opened file handles, removes temporary files, etc.
  ///
  /// If the Fetcher is already closed then invoking this method has no effect.
  Future<void> close();

  Future<String?> guessTitle() async {
    List<Link> links = await this.links();
    Link? firstLink = (links).firstOrNull;
    if (firstLink == null) {
      return null;
    }
    File? commonFirstComponent = links.hrefCommonFirstComponent();
    if (commonFirstComponent == null) {
      return null;
    }
    String name = basename(commonFirstComponent.path);
    if (name == firstLink.href.removePrefix("/")) {
      return null;
    }
    return name;
  }

  /// Returns the resource data at the given [Link]'s HREF, or throws a [Resource.Exception]
  Future<ByteData> readBytes(Link link) =>
      get(link).use((it) => it.read().then((data) => data.getOrThrow()));

  /// Returns the resource data at the given [href], or throws a [Resource.Exception]
  Future<ByteData> readBytesWithHref(String href) => getWithHref(href)
      .use((it) => it.read().then((data) => data.getOrThrow()));

  /// Returns the resource data as an XML Document at the given [href], or null.
  Future<XmlDocument?> readAsXmlOrNull(String href) => getWithHref(href)
      .use((it) => it.readAsXml().then((xml) => xml.getOrNull()));

  /// Returns the resource data as a JSON object at the given [href], or null.
  Future<Map<String, dynamic>?> readAsJsonOrNull(String href) =>
      getWithHref(href)
          .use((it) => it.readAsJson().then((json) => json.getOrNull()));

  /// Creates a [Fetcher] from either an archive file, or an exploded directory.
  static Future<Fetcher?> fromArchiveOrDirectory(String path,
      {ArchiveFactory archiveFactory = const DefaultArchiveFactory()}) async {
    File file = File(path);
    bool? isDirectory = tryOrNull(() => FileSystemEntity.isDirectorySync(path));
    if (isDirectory == null) {
      return null;
    }
    if (isDirectory) {
      return FileFetcher.single(href: "/", file: file);
    } else {
      return ArchiveFetcher.fromPath(path, archiveFactory: archiveFactory);
    }
  }
}

/// A [Fetcher] providing no resources at all.
class EmptyFetcher extends Fetcher {
  const EmptyFetcher();

  @override
  Future<List<Link>> links() async => [];

  @override
  Resource get(Link link) => FailureResource(link, ResourceException.notFound);

  @override
  Future<void> close() async {}
}
