// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:mno_streamer/src/container/container.dart';
import 'package:mno_streamer/src/container/publication_container.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:mno_streamer/src/epub/encryption_parser.dart';
import 'package:mno_streamer/src/epub/epub_deobfuscator.dart';
import 'package:mno_streamer/src/epub/epub_positions_service.dart';
import 'package:mno_streamer/src/epub/navigation_document_parser.dart';
import 'package:mno_streamer/src/epub/ncx_parser.dart';
import 'package:universal_io/io.dart' hide Link;
import 'package:xml/xml.dart';

/// Constants settings for EPUB publication.
class EPUBConstant {
  /// Left-to-right preset.
  static Map<ReadiumCSSName, bool> get ltrPreset =>
      {ReadiumCSSName.hyphens: false, ReadiumCSSName.ligatures: false};

  /// Right-to-left preset.
  static Map<ReadiumCSSName, bool> get rtlPreset => {
        ReadiumCSSName.hyphens: false,
        ReadiumCSSName.wordSpacing: false,
        ReadiumCSSName.letterSpacing: false,
        ReadiumCSSName.ligatures: true
      };

  /// CJK horizontal preset.
  static Map<ReadiumCSSName, bool> get cjkHorizontalPreset => {
        ReadiumCSSName.textAlignment: false,
        ReadiumCSSName.hyphens: false,
        ReadiumCSSName.paraIndent: false,
        ReadiumCSSName.wordSpacing: false,
        ReadiumCSSName.letterSpacing: false
      };

  /// CJK vertical preset.
  static Map<ReadiumCSSName, bool> get cjkVerticalPreset => {
        ReadiumCSSName.scroll: true,
        ReadiumCSSName.columnCount: false,
        ReadiumCSSName.textAlignment: false,
        ReadiumCSSName.hyphens: false,
        ReadiumCSSName.paraIndent: false,
        ReadiumCSSName.wordSpacing: false,
        ReadiumCSSName.letterSpacing: false
      };

  /// Force scroll preset.
  static Map<ReadiumCSSName, bool> get forceScrollPreset =>
      {ReadiumCSSName.scroll: true};
}

/// Errors related to EPUB parser.
class EpubParserException implements Exception {
  /// Invalid EPUB package.
  factory EpubParserException.invalidEpub(String message) =>
      EpubParserException("Invalid EPUB: $message");

  const EpubParserException(this.message);

  final String message;
}

/// Parses a Publication from an EPUB publication.
class EpubParser extends PublicationParser implements StreamPublicationParser {
  @override
  Future<PublicationBuilder?> parseFile(
          PublicationAsset asset, Fetcher fetcher) =>
      _parse(asset, fetcher, asset.name);

  Future<PublicationBuilder?> _parse(
      PublicationAsset asset, Fetcher fetcher, String fallbackTitle) async {
    if (await asset.mediaType != MediaType.epub) {
      return null;
    }
    String opfPath = await _getRootFilePath(fetcher);
    XmlDocument opfXmlDocument =
        (await fetcher.getWithHref(opfPath).readAsXml()).getOrThrow();
    PackageDocument? packageDocument =
        PackageDocument.parse(opfXmlDocument.firstElementChild!, opfPath);
    if (packageDocument == null) {
      throw Exception("Invalid OPF file.");
    }

    Manifest manifest = PublicationFactory(
            fallbackTitle: fallbackTitle,
            packageDocument: packageDocument,
            navigationData:
                await _parseNavigationData(packageDocument, fetcher),
            encryptionData: await _parseEncryptionData(fetcher),
            displayOptions: await _parseDisplayOptions(fetcher))
        .create();

    Fetcher finalFetcher = fetcher;
    manifest.metadata.identifier?.let((it) {
      finalFetcher =
          TransformingFetcher.single(fetcher, EpubDeobfuscator(it).transform);
    });

    return PublicationBuilder(
        manifest: manifest,
        fetcher: finalFetcher,
        servicesBuilder:
            ServicesBuilder.create(positions: EpubPositionsService.create));
  }

  @override
  Future<PubBox?> parseWithFallbackTitle(
      String fileAtPath, String fallbackTitle) async {
    File file = File(fileAtPath);
    FileAsset asset = FileAsset(file);

    Fetcher? fetcher = await Fetcher.fromArchiveOrDirectory(fileAtPath);
    if (fetcher == null) {
      throw ContainerError.missingFile(fileAtPath);
    }

    Drm? drm = (await fetcher.isProtectedWithLcp()) ? Drm.lcp : null;
    PublicationBuilder? builder;
    try {
      builder = await _parse(asset, fetcher, fallbackTitle);
    } on Exception {
      return null;
    }
    if (builder == null) {
      return null;
    }
    Publication publication = builder.build().also((pub) {
      pub.type = TYPE.epub;

      // This might need to be moved as it's not really about parsing the EPUB but it
      // sets values needed (in UserSettings & ContentFilter)
      pub.setLayoutStyle();
    });

    PublicationContainer container = PublicationContainer(
        path: file.canonicalPath, mediaType: MediaType.epub, drm: drm);
    container.rootFile.rootFilePath = await _getRootFilePath(fetcher);

    return PubBox(publication, container);
  }

  Future<String> _getRootFilePath(Fetcher fetcher) async {
    String? path = (await fetcher.readAsXmlOrNull("/META-INF/container.xml"))
        ?.firstElementChild
        ?.getElement("rootfiles", namespace: Namespaces.opc)
        ?.getElement("rootfile", namespace: Namespaces.opc)
        ?.getAttribute("full-path");
    if (path == null) {
      throw Exception("Unable to find an OPF file.");
    }
    return path;
  }

  Future<Map<String, Encryption>> _parseEncryptionData(Fetcher fetcher) async =>
      (await fetcher.readAsXmlOrNull("/META-INF/encryption.xml"))
          ?.let(EncryptionParser.parse) ??
      {};

  Future<Map<String, List<Link>>> _parseNavigationData(
      PackageDocument packageDocument, Fetcher fetcher) async {
    if (packageDocument.epubVersion < 3.0) {
      Item? ncxItem = packageDocument.manifest.firstOrNullWhere(
          (it) => MediaType.ncx.containsFromName(it.mediaType));
      return await ncxItem?.let((it) async {
            String ncxPath = Href(it.href).string;
            return (await fetcher.readAsXmlOrNull(ncxPath))
                    ?.let((it) => NcxParser.parse(it.rootElement, ncxPath)) ??
                {};
          }) ??
          {};
    } else {
      Item? navItem = packageDocument.manifest.firstOrNullWhere(
          (it) => it.properties.contains("${Vocabularies.item}nav"));
      return await navItem?.let((it) async {
            String navPath =
                Href(navItem.href, baseHref: packageDocument.path).string;
            return (await fetcher.readAsXmlOrNull(navPath))?.let(
                    (it) => NavigationDocumentParser.parse(it, navPath)) ??
                {};
          }) ??
          {};
    }
  }

  Future<Map<String, String>> _parseDisplayOptions(Fetcher fetcher) async {
    XmlDocument? displayOptionsXml = await fetcher.readAsXmlOrNull(
            "/META-INF/com.apple.ibooks.display-options.xml") ??
        await fetcher
            .readAsXmlOrNull("/META-INF/com.kobobooks.display-options.xml");

    return displayOptionsXml
            ?.getElement("platform", namespace: "")
            ?.findElements("option", namespace: "")
            .map((element) {
              String? optName = element.getAttribute("name");
              String optVal = element.text;
              return (optName != null) ? MapEntry(optName, optVal) : null;
            })
            .whereNotNull()
            .let((entries) => Map.fromEntries(entries)) ??
        {};
  }
}

/// Extension that adds [setLayoutStyle] on [Publication].
extension PublicationLayoutStyle on Publication {
  /// Update [cssStyle] and [userSettingsUIPreset] based on the publication
  /// metadata.
  void setLayoutStyle() {
    ReadiumCssLayout layout = ReadiumCssLayout.findWithMetadata(metadata);
    cssStyle = layout.cssId;
    switch (layout) {
      case ReadiumCssLayout.rtl:
        userSettingsUIPreset = EPUBConstant.rtlPreset;
        break;
      case ReadiumCssLayout.ltr:
        userSettingsUIPreset = EPUBConstant.ltrPreset;
        break;
      case ReadiumCssLayout.cjkVertical:
        userSettingsUIPreset = EPUBConstant.cjkVerticalPreset;
        break;
      case ReadiumCssLayout.cjkHorizontal:
        userSettingsUIPreset = EPUBConstant.cjkHorizontalPreset;
        break;
    }
  }
}

extension _FetcherProtectedWithLcp on Fetcher {
  Future<bool> isProtectedWithLcp() async =>
      await getWithHref("/META-INF/license.lcpl")
          .use((it) async => (await it.length()).isSuccess);
}
