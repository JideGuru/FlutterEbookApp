// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:dfunc/dfunc.dart';
import 'package:image/image.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

/// Provides an easy access to a bitmap version of the publication cover.
///
/// While at first glance, getting the cover could be seen as a helper, the implementation actually
/// depends on the publication format:
///
/// - Some might allow vector images or even HTML pages, in which case they need to be converted to
///   bitmaps.
/// - Others require to render the cover from a specific file format, e.g. PDF.
///
/// Furthermore, a reading app might want to use a custom strategy to choose the cover image, for
/// example by:
///
/// - iterating through the images collection for a publication parsed from an OPDS 2 feed
/// - generating a bitmap from scratch using the publication's title
/// - using a cover selected by the user.
abstract class CoverService extends PublicationService {
  /// Returns the publication cover as a [Bitmap] at its maximum size.
  ///
  /// If the cover is not a bitmap format (e.g. SVG), it should be scaled down to fit the screen.
  Future<Image?> cover();

  ///  Returns the publication cover as a [Bitmap], scaled down to fit the given [maxSize].
  Future<Image?> coverFitting(ImageSize maxSize) async =>
      cover().then((value) => value?.let((it) => copyResize(it,
          width: maxSize.width.toInt(), height: maxSize.height.toInt())));

  @override
  Type get serviceType => CoverService;
}

extension PublicationCoverExtension on Publication {
  Future<Image?> _coverFromManifest() async {
    for (Link link in linksWithRel("cover")) {
      ByteData? data = (await get(link).read()).getOrNull();
      if (data == null) {
        continue;
      }
      Image? cover = decodeImage(data.buffer.asUint8List());
      if (cover != null) {
        return cover;
      }
    }
    return null;
  }

  /// Returns the publication cover as a [Bitmap] at its maximum size.
  Future<Image?> cover() async {
    final coverService = findService<CoverService>();
    Image? cover = await coverService?.cover();
    if (cover != null) {
      return cover;
    }
    return _coverFromManifest();
  }

  /// Returns the publication cover as a [Bitmap], scaled down to fit the given [maxSize].
  Future<Image?> coverFitting(ImageSize maxSize) async {
    Image? cover = await findService<CoverService>()?.coverFitting(maxSize);
    if (cover != null) {
      return cover;
    }
    return _coverFromManifest().then((value) => value?.let((it) => copyResize(
        it,
        width: maxSize.width.toInt(),
        height: maxSize.height.toInt())));
  }
}

extension ServicesBuilderExtension on ServicesBuilder {
  /// Factory to build a [CoverService].
  ServiceFactory? getCoverServiceFactory() => of<CoverService>();

  set coverServiceFactory(ServiceFactory serviceFactory) =>
      set<CoverService>(serviceFactory);
}

/// A [CoverService] which provides a unique cover for each Publication.
abstract class GeneratedCoverService extends CoverService {
  Link get coverLink =>
      Link(href: "/~readium/cover", type: "image/png", rels: {"cover"});

  @override
  Future<Image?> cover();

  @override
  List<Link> get links => [coverLink];

  @override
  Resource? get(Link link) {
    if (link.href != coverLink.href) {
      return null;
    }
    return LazyResource(() async {
      Image? image = await cover();
      if (image == null) {
        ResourceException error = ResourceException.other(
            Exception("Unable to convert cover to PNG."));
        return FailureResource(coverLink, error);
      } else {
        List<int> png = encodePng(image);
        Link link = coverLink.copy(width: image.width, height: image.height);
        return BytesResource(link, () async => png.toByteData());
      }
    });
  }
}

/// A [CoverService] which uses a provided in-memory bitmap.
class InMemoryCoverService extends GeneratedCoverService {
  final Image? _cover;

  InMemoryCoverService(this._cover);

  static ServiceFactory createFactory(Image cover) =>
      (context) => InMemoryCoverService(cover);

  @override
  Future<Image?> cover() async => _cover;
}
