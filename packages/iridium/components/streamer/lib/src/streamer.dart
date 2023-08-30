// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/archive.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:mno_streamer/pdf.dart';
import 'package:mno_streamer/src/readium/readium_web_pub_parser.dart';

/// Subclass of [Try<SuccessT, UserException>] that is useful when parsing a
/// [Publication].
class PublicationTry<SuccessT> extends Try<SuccessT, UserException> {
  PublicationTry.success(SuccessT super.success) : super.success();

  PublicationTry.failure(UserException super.failure) : super.failure();
}

/// Definition of the [OnCreatePublication] callback.
typedef OnCreatePublication = void Function(PublicationBuilder);

OnCreatePublication get _emptyOnCreatePublication => (pb) {};

/// Opens a Publication using a list of parsers.
///
/// The [Streamer] is configured to use Readium's default parsers, which you can bypass using
/// [ignoreDefaultParsers]. However, you can provide additional [parsers] which will take precedence
/// over the default ones. This can also be used to provide an alternative configuration of a
/// default parser.
///
/// @param context Application context.
/// @param parsers Parsers used to open a publication, in addition to the default parsers.
/// @param ignoreDefaultParsers When true, only parsers provided in parsers will be used.
/// @param archiveFactory Opens an archive (e.g. ZIP, RAR), optionally protected by credentials.
/// @param onCreatePublication Called on every parsed [PublicationBuilder]. It can be used to modify
///   the [Manifest], the root [Fetcher] or the list of service factories of a [Publication].
class Streamer {
  final List<StreamPublicationParser> _parsers;

  /// This property indicate that it should ignore default parsers when parsing
  /// a publication.
  final bool ignoreDefaultParsers;

  /// This property indicate that it should use sniffers when searching
  /// mediaTypes for links in  a publication.
  final bool useSniffers;

  /// List of the [ContentProtection] implementation that are supported.
  final List<ContentProtection> contentProtections;

  /// The [archiveFactory] instance that can create an [Archive] corresponding to
  /// the actual file.
  final ArchiveFactory archiveFactory;

  /// [pdfFactory] provide a way to create [PdfDocument] instance.
  final PdfDocumentFactory? pdfFactory;

  /// [onCreatePublication] is a callback that is called after the
  /// [PublicationBuilder] is created.
  final OnCreatePublication onCreatePublication;
  List<StreamPublicationParser>? _defaultParsers;

  /// Creates an instance of [Streamer].
  Streamer(
      {List<StreamPublicationParser> parsers = const [],
      this.ignoreDefaultParsers = false,
      this.useSniffers = true,
      this.contentProtections = const [],
      this.archiveFactory = const DefaultArchiveFactory(),
      this.pdfFactory,
      OnCreatePublication? onCreatePublication})
      : _parsers = parsers,
        this.onCreatePublication =
            onCreatePublication ?? _emptyOnCreatePublication;

  /// Parses a [Publication] from the given asset.
  ///
  /// If you are opening the publication to render it in a Navigator, you must set [allowUserInteraction]
  /// to true to prompt the user for its credentials when the publication is protected. However,
  /// set it to false if you just want to import the [Publication] without reading its content, to
  /// avoid prompting the user.
  ///
  /// When using Content Protections, you can use [sender] to provide a free object which can be
  /// used to give some context. For example, it could be the source Activity or Fragment which
  /// would be used to present a credentials dialog.
  ///
  /// The [warnings] logger can be used to observe non-fatal parsing warnings, caused by
  /// publication authoring mistakes. This can be useful to warn users of potential rendering
  /// issues.
  ///
  /// @param asset Digital medium (e.g. a file) used to access the publication.
  /// @param credentials Credentials that Content Protections can use to attempt to unlock a
  ///   publication, for example a password.
  /// @param allowUserInteraction Indicates whether the user can be prompted, for example for its
  ///   credentials.
  /// @param sender Free object that can be used by reading apps to give some UX context when
  ///   presenting dialogs.
  /// @param onCreatePublication Transformation which will be applied on the Publication Builder.
  ///   It can be used to modify the [Manifest], the root [Fetcher] or the list of service
  ///   factories of the [Publication].
  /// @param warnings Logger used to broadcast non-fatal parsing warnings.
  /// @return Null if the asset was not recognized by any parser, or a
  ///   [Publication.UserException] in case of failure.
  Future<PublicationTry<Publication>> open(
    PublicationAsset asset,
    bool allowUserInteraction, {
    String? credentials,
    dynamic sender,
    OnCreatePublication? onCreatePublication,
  }) async {
    onCreatePublication ??= _emptyOnCreatePublication;
    try {
      Fetcher fetcher = (await asset.createFetcher(
              PublicationAssetDependencies(archiveFactory), credentials,
              useSniffers: useSniffers))
          .getOrThrow();

      Try<ProtectedAsset, UserException>? protectedAssetResult =
          (await contentProtections.lazyMapFirstNotNullOrNull((it) => it.open(
              asset, fetcher, credentials, allowUserInteraction, sender)));

      if (allowUserInteraction &&
          protectedAssetResult != null &&
          protectedAssetResult.isFailure) {
        throw protectedAssetResult.failure!;
      }

      ProtectedAsset? protectedAsset = protectedAssetResult?.getOrNull();
      if (protectedAsset != null) {
        asset = protectedAsset.asset;
        fetcher = protectedAsset.fetcher;
      }

      PublicationBuilder? builder =
          (await _getParsers().lazyMapFirstNotNullOrNull((it) {
        try {
          return it.parseFile(asset, fetcher).catchError(
              (e, st) => it.parseFile(asset, fetcher).catchError((e, st) {
                    Fimber.d("ERROR $it", ex: e, stacktrace: st);
                    return null;
                  }));
        } on Exception catch (e) {
          throw OpeningException.parsingFailed(e);
        }
      }));
      if (builder == null) {
        throw OpeningException.unsupportedFormat;
      }

      // Transform from the Content Protection.
      protectedAsset?.let((it) => it.onCreatePublication);
      // Transform provided by the reading app during the construction of the Streamer.
      builder.also(this.onCreatePublication);
      // Transform provided by the reading app in `Streamer.open()`.
      builder.also(onCreatePublication);

      Publication publication = builder.also(onCreatePublication).build();

      publication.addLegacyProperties(await asset.mediaType);
      var infos =
          await PaginationInfosService.computePaginationInfos(publication);
      publication.nbPages = infos.$1;
      publication.paginationInfo = infos.$2;
      // Fimber.d("publication.manifest: ${publication.manifest}");

      return PublicationTry.success(publication);
    } on UserException catch (e, stacktrace) {
      Fimber.e("ERROR", ex: e, stacktrace: stacktrace);
      return PublicationTry.failure(e);
    }
  }

  List<StreamPublicationParser> _getDefaultParsers() => _defaultParsers ??= [
        EpubParser(),
        if (pdfFactory != null) PdfParser(pdfFactory!),
        ImageParser(),
        ReadiumWebPubParser(pdfFactory),
      ];

  List<StreamPublicationParser> _getParsers() => List.of(_parsers)
    ..addAll((!ignoreDefaultParsers) ? _getDefaultParsers() : []);
}

extension _LazyMapFirstNotNullOrNullList<T> on List<T> {
  Future<R?> lazyMapFirstNotNullOrNull<R>(
      Future<R?> Function(T) transform) async {
    for (T it in this) {
      R? result = await transform(it);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

extension _AddLegacyPropertiesPublication on Publication {
  void addLegacyProperties(MediaType mediaType) {
    type = mediaType.toPublicationType();

    if (mediaType == MediaType.epub) {
      setLayoutStyle();
    }
  }
}

/// Extension on MediaType adding [toPublicationType] method.
extension ToPublicationTypeMediaType on MediaType {
  /// Convert [MediaType] to [TYPE]
  TYPE toPublicationType() {
    if ([
      MediaType.readiumAudiobook,
      MediaType.readiumAudiobookManifest,
      MediaType.lcpProtectedAudiobook,
    ].contains(this)) {
      return TYPE.audio;
    }
    if ([
      MediaType.divina,
      MediaType.divinaManifest,
    ].contains(this)) {
      return TYPE.divina;
    }
    if (this == MediaType.cbz) {
      return TYPE.cbz;
    }
    if (this == MediaType.epub) {
      return TYPE.epub;
    }
    return TYPE.webpub;
  }
}
