// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:path/path.dart' as p;

/// Inject the XPUB CSS and JS links in a publication HTML resources.
class HtmlInjector {
  /// The [publication] that is the context for the HTML injection.
  final Publication publication;
  final List<String> googleFonts;

  /// Create an instance [HtmlInjector] for a [publication].
  HtmlInjector(this.publication, {this.googleFonts = const []});

  /// Inject CSS and JS links if the resource is HTML.
  Resource transform(Resource resource) => LazyResource(() async {
        Link link = await resource.link();
        if (link.mediaType.isHtml) {
          return _InjectHtmlResource(publication, googleFonts, resource);
        }
        return resource;
      });
}

class _InjectHtmlResource extends TransformingResource {
  final Publication publication;
  final List<String> googleFonts;

  _InjectHtmlResource(this.publication, this.googleFonts, Resource resource)
      : super(resource);

  @override
  Future<ResourceTry<ByteData>> transform(ResourceTry<ByteData> data) async {
    Link l = await link();
    EpubLayout renditionLayout = publication.metadata.presentation.layoutOf(l);
    return (await resource.readAsString(
            charset: l.mediaType.charset ?? Charsets.utf8))
        .mapCatching((html) {
      html = _injectLinks(html, renditionLayout);
      html = _wrapHtmlContent(html, renditionLayout);
      return html.toByteData();
    });
  }

  /// Injects the links before </head>.
  String _injectLinks(String html, EpubLayout renditionLayout) {
    int headIndex = html.indexOf('</head>');
    if (headIndex == -1) {
      Fimber.d("Can't find </head> to inject HTML links");
      return html;
    }

    String linksHtml = _createLinksToInjectHtml(renditionLayout);
    String googleFonts = _createGoogleFontsHtml();

    return "${html.substring(0, headIndex)}\n$linksHtml\n$googleFonts\n${html.substring(headIndex)}";
  }

  /// Builds the HTML for the list of links to be injected in <head>
  String _createLinksToInjectHtml(EpubLayout renditionLayout) =>
      _createLinksToInject(renditionLayout)
          .map((path) {
            switch (p.extension(path).toLowerCase()) {
              case '.css':
                return '<link href="$path" rel="stylesheet" />';
              case '.js':
                return '<script type="text/javascript" src="$path"></script>';
              default:
                Fimber.d("Can't HTML inject path: $path");
                return null;
            }
          })
          .where((l) => l != null)
          .join('\n');

  /// Link's href to be injected in <head> for the given [Link] resource.
  /// The file extension is used to know if it's a JS or CSS.
  List<String> _createLinksToInject(EpubLayout renditionLayout) => [
        '/xpub-js/xpub.css',
        '/xpub-js/fonts.css',
        '/xpub-js/ReadiumCSS-before.css',
        '/xpub-js/ReadiumCSS-default.css',
        '/xpub-js/ReadiumCSS-after.css',
        '/xpub-js/pagination.css',
        '/xpub-shared-js/polyfill.js',
        '/xpub-shared-js/underscore-min.js',
        '/xpub-shared-js/jquery-2.1.0.min.js',
        '/xpub-shared-js/jquery.mobile-1.4.5.min.js',
        '/xpub-shared-js/jquerymobile-swipeupdown.js',
        '/xpub-shared-js/readium-cfi-js.js',
        '/xpub-shared-js/globals.js',
        '/xpub-shared-js/helpers.js',
        '/xpub-js/model/bookmark_data.js',
        '/xpub-js/model/current_pages_info.js',
        '/xpub-js/model/spine_item.js',
        '/xpub-js/model/location.js',
        '/xpub-js/model/page_open_request.js',
        '/xpub-js/model/package_data.js',
        '/xpub-js/model/package.js',
        '/xpub-js/utils/rangefix.js',
        '/xpub-js/utils/cfi_navigation_logic.js',
        '/xpub-js/utils/cfi.js',
        '/xpub-js/utils/tools.js',
        '/xpub-js/controllers/bookmarks.js',
        '/xpub-js/controllers/highlight.js',
        '/xpub-js/controllers/tts.js',
        '/xpub-js/Main.js',
        '/xpub-js/xpub_location.js',
        '/xpub-js/xpub_navigation.js',
        '/xpub-js/Gestures.js',
        '/xpub-js/Recordings.js',
        '/xpub-js/Theme.js',
        if (renditionLayout == EpubLayout.fixed)
          '/xpub-js/xpub_navigation_fixed_layout.js',
        if (renditionLayout == EpubLayout.reflowable) ...[
          '/xpub-js/xpub_navigation_reflow_layout.js',
          '/xpub-js/Reflowable_Viewport.js',
        ]
      ];

  /// Wraps the HTML for pagination.
  String _wrapHtmlContent(String html, EpubLayout renditionLayout) {
    if (renditionLayout == EpubLayout.reflowable) {
      html = _insertString('(<body[^>]*>)', html,
          '<div class="xpub_container"><div id="xpub_contenuSpineItem">', true);
      html = _insertString('(</body>)', html,
          '</div><div id="xpub_paginator"></div></div>', false);
    }
    return html;
  }

  String _insertString(
      String pattern, String content, String contentToAdd, bool insertAfter) {
    Match? match = _matchRegex(pattern, content);
    if (match == null) {
      Fimber.d("Can't find $pattern to insert $contentToAdd");
      return content;
    }
    int insertionPoint = insertAfter ? match.end : match.start;
    return content.substring(0, insertionPoint) +
        contentToAdd +
        content.substring(insertionPoint);
  }

  Match? _matchRegex(String pattern, String html) {
    RegExp exp = RegExp(pattern);
    Match? startBody = exp.firstMatch(html);
    return startBody;
  }

  String _createGoogleFontsHtml() {
    if (googleFonts.isEmpty) {
      return "";
    }
    String fontList = googleFonts.map((f) => f.replaceAll(" ", "+")).join("|");
    return "<style>@import url('https://fonts.googleapis.com/css?family=$fontList');</style>";
  }
}
