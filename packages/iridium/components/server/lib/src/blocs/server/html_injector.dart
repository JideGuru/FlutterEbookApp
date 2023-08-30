// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/injectable.dart';
import 'package:mno_server/src/blocs/server/resources.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:universal_io/io.dart' hide Link;

/// Inject the Readium CSS and JS links in a publication HTML resources.
class HtmlInjector {
  /// The [publication] that is the context for the HTML injection.
  final Publication publication;
  final ValueGetter<int> viewportWidthGetter;
  final String? userPropertiesPath;
  final Resources? customResources;
  final List<String> googleFonts;

  /// Create an instance [HtmlInjector] for a [publication].
  HtmlInjector(this.publication, this.viewportWidthGetter,
      {this.userPropertiesPath,
      this.customResources,
      this.googleFonts = const []});

  /// Inject CSS and JS links if the resource is HTML.
  Resource transform(Resource resource) => LazyResource(() async {
        Link link = await resource.link();
        if (link.mediaType.isHtml) {
          return _InjectHtmlResource(publication, viewportWidthGetter,
              userPropertiesPath, customResources, googleFonts, resource);
        }
        return resource;
      });
}

class _InjectHtmlResource extends TransformingResource {
  final Publication publication;
  final ValueGetter<int> viewportWidthGetter;
  final String? userPropertiesPath;
  final Resources? customResources;
  final List<String> googleFonts;

  _InjectHtmlResource(
      this.publication,
      this.viewportWidthGetter,
      this.userPropertiesPath,
      this.customResources,
      this.googleFonts,
      Resource resource)
      : super(resource);

  @override
  Future<ResourceTry<ByteData>> transform(ResourceTry<ByteData> data) async {
    Link l = await link();

    return (await resource.readAsString(
            charset: l.mediaType.charset ?? Charsets.utf8))
        .mapCatching((it) {
      String trimmedText = it.trim();
      EpubLayout renditionLayout =
          publication.metadata.presentation.layoutOf(l);
      String res = (renditionLayout == EpubLayout.reflowable)
          ? injectReflowableHtml(trimmedText)
          : injectFixedLayoutHtml(trimmedText);
      return res.toByteData();
    });
  }

  String _insertString(
      String pattern, String content, String contentToAdd, bool insertAfter) {
    Match? match = _matchRegex(pattern, content);
    if (match == null) {
      Fimber.d("Can't find $pattern to insert $contentToAdd");
      return content;
    }
    int insertionPoint = insertAfter ? match.end : match.start;
    return content.insert(insertionPoint, contentToAdd);
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
    return "<style>@import url('https://fonts.googleapis.com/css?family=$fontList');</style>\n";
  }

  String injectReflowableHtml(String content) {
    String resourceHtml = content;
    // Inject links to css and js files
    RegExpMatch? head = regexForOpeningHTMLTag("head").firstMatch(resourceHtml);
    if (head == null) {
      Fimber.e("No <head> tag found in this resource");
      return resourceHtml;
    }
    var beginHeadIndex = head.end + 1;
    var endHeadIndex =
        resourceHtml.indexOf(RegExp("</head>", caseSensitive: false));
    if (endHeadIndex == -1) {
      return content;
    }

    ReadiumCssLayout layout =
        ReadiumCssLayout.findWithMetadata(publication.metadata);

    List<String> endIncludes = [];
    List<String> beginIncludes = [];
    beginIncludes.add(getHtmlLink(
        "/readium/readium-css/${layout.readiumCSSPath}ReadiumCSS-before.css"));

    // Fix Readium CSS issue with the positioning of <audio> elements.
    // https://github.com/readium/readium-css/issues/94
    // https://github.com/readium/r2-navigator-kotlin/issues/193
    beginIncludes.add("""
            <style>
            audio[controls] {
                width: revert;
                height: revert;
            }
            </style>
        """
        .trim());

    endIncludes.add(getHtmlLink(
        "/readium/readium-css/${layout.readiumCSSPath}ReadiumCSS-after.css"));
    endIncludes.add(getHtmlLink(
        "/readium/readium-css/${layout.readiumCSSPath}ReadiumCSS-pagination.css"));
    endIncludes.add(getHtmlScript("/readium/scripts/readium-reflowable.js"));
    // for (String script in defaultJsLinks) {
    //   endIncludes.add(getHtmlScript(script));
    // }
    endIncludes.add(_createGoogleFontsHtml());

    customResources?.let((it) {
      // Inject all custom resourses
      for (MapEntry<String, dynamic> entry in it.resources.entries) {
        String key = entry.key;
        dynamic value = entry.value;
        if (value is (String, String)) {
          if (Injectable(value.$2) == Injectable.script) {
            endIncludes
                .add(getHtmlScript("/${Injectable.script.rawValue}/$key"));
          } else if (Injectable(value.$2) == Injectable.style) {
            endIncludes.add(getHtmlLink("/${Injectable.style.rawValue}/$key"));
          }
        }
      }
    });

    for (var element in beginIncludes) {
      resourceHtml = resourceHtml.insert(beginHeadIndex, element);
      beginHeadIndex += element.length;
      endHeadIndex += element.length;
    }
    for (var element in endIncludes) {
      resourceHtml = resourceHtml.insert(endHeadIndex, element);
      endHeadIndex += element.length;
    }
    resourceHtml = resourceHtml.insert(
        endHeadIndex,
        getHtmlFont(
            fontFamily: "OpenDyslexic",
            href: "/readium/fonts/OpenDyslexic-Regular.otf"));
    resourceHtml = resourceHtml.insert(endHeadIndex, _createGoogleFontsHtml());

    // Disable the text selection if the publication is protected.
    // FIXME: This is a hack until proper LCP copy is implemented, see https://github.com/readium/r2-testapp-kotlin/issues/266
    if (publication.isProtected) {
      resourceHtml = resourceHtml.insert(endHeadIndex, """
                <style>
                *:not(input):not(textarea) {
                    user-select: none;
                    -webkit-user-select: none;
                }
                </style>
            """);
    }

    // Inject userProperties
    getProperties(publication.userSettingsUIPreset).let((propertyPair) {
      propertyPair["--RS__nativeViewportWidth"] =
          viewportWidthGetter().toString();
      Match? html =
          regexForOpeningHTMLTag("html").matchAsPrefix(resourceHtml, 0);
      if (html != null) {
        Match? match =
            RegExp("""(style=("([^"]*)"[ >]))|(style='([^']*)'[ >])""")
                .matchAsPrefix(html.input, 0);
        if (match != null) {
          var beginStyle = match.start + 7;
          var newHtml = html.input;
          newHtml = newHtml.insert(
              beginStyle, "${buildStringProperties(propertyPair)} ");
          resourceHtml =
              resourceHtml.replaceAll(regexForOpeningHTMLTag("html"), newHtml);
        } else {
          var beginHtmlIndex =
              resourceHtml.indexOf(RegExp("<html", caseSensitive: false)) + 5;
          resourceHtml = resourceHtml.insert(beginHtmlIndex,
              " style=\"${buildStringProperties(propertyPair)}\"");
        }
      } else {
        var beginHtmlIndex =
            resourceHtml.indexOf(RegExp("<html", caseSensitive: false)) + 5;
        resourceHtml = resourceHtml.insert(beginHtmlIndex,
            " style=\"${buildStringProperties(propertyPair)}\"");
      }
    });
    resourceHtml = applyDirectionAttribute(resourceHtml, publication);
    resourceHtml = _insertString(
        '(</body>)', resourceHtml, '<div id="readium_paginator"></div>', false);

    return resourceHtml;
  }

  String applyDirectionAttribute(String resourceHtml, Publication publication) {
    String resourceHtml1 = resourceHtml;
    String addRTLDir(String tagName, String html) =>
        regexForOpeningHTMLTag(tagName).matchAsPrefix(html, 0)?.let((result) {
          if (RegExp("""dir=""").hasMatch(result.input)) {
            return html;
          }
          var beginHtmlIndex =
              html.indexOf(RegExp("<$tagName", caseSensitive: false)) + 5;
          return html.insert(beginHtmlIndex, " dir=\"rtl\"");
        }) ??
        html;

    if (publication.cssStyle == "rtl") {
      resourceHtml1 = addRTLDir("html", resourceHtml1);
      resourceHtml1 = addRTLDir("body", resourceHtml1);
    }

    return resourceHtml1;
  }

  RegExp regexForOpeningHTMLTag(String name) =>
      RegExp("""<$name.*?>""", caseSensitive: false, dotAll: true);

  String injectFixedLayoutHtml(String content) {
    String resourceHtml = content;
    int endHeadIndex =
        resourceHtml.indexOf(RegExp("</head>", caseSensitive: false));
    if (endHeadIndex == -1) {
      return content;
    }
    List<String> includes = [];
    includes.add(getHtmlScript("/readium/scripts/readium-fixed.js"));
    // for (String script in defaultJsLinks) {
    //   includes.add(getHtmlScript(script));
    // }
    includes.add(_createGoogleFontsHtml());
    return resourceHtml.insert(endHeadIndex, includes.join());
  }

  String getHtmlFont({required String fontFamily, required String href}) =>
      "<style type=\"text/css\"> @font-face{font-family: \"$fontFamily\"; src:url(\"" + href + "\") format('truetype');}</style>\n";

  String getHtmlLink(String resourceName) =>
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"$resourceName\"/>\n";

  String getHtmlScript(String resourceName) =>
      "<script type=\"text/javascript\" src=\"$resourceName\"></script>\n";

  Map<String, String> getProperties(Map<ReadiumCSSName, bool> preset) {
    // userProperties is a JSON string containing the css userProperties
    String? userPropertiesString;
    userPropertiesPath?.let((it) async {
      userPropertiesString = "";
      File file = File(it);
      if (FileSystemEntity.typeSync(it) == FileSystemEntityType.file &&
          file.existsSync()) {
        userPropertiesString = await file.readAsString();
      }
    });

    return userPropertiesString?.let((it) {
          // Parsing of the String into a JSONArray of JSONObject with each "name" and "value" of the css properties
          // Making that JSONArray a MutableMap<String, String> to make easier the access of data
          try {
            List<dynamic>? propertiesArray = it.toJsonArrayOrNull();
            Map<String, String> properties = {};
            if (propertiesArray != null) {
              for (var i = 0; i < propertiesArray.length; i++) {
                Map<String, dynamic> value =
                    propertiesArray[i].toString().toJsonOrNull()!;
                bool isInPreset = false;

                for (MapEntry<ReadiumCSSName, bool> property
                    in preset.entries) {
                  if (property.key.ref == value["name"]) {
                    isInPreset = true;
                    (ReadiumCSSName, bool?) presetPair =
                        (property.key, preset[property.key]);
                    Map<String, String> presetValue = applyPreset(presetPair);
                    properties[presetValue["name"]!] = presetValue["value"]!;
                  }
                }

                if (!isInPreset) {
                  properties[value["name"]] = value["value"];
                }
              }
            }

            return properties;
          } on Exception {
            return null;
          }
        }) ??
        {};
  }

  Map<String, String> applyPreset((ReadiumCSSName, bool?) preset) {
    Map<String, String> readiumCSSProperty = {};

    readiumCSSProperty["name"] = preset.$1.ref;

    if (preset.$1 == ReadiumCSSName.hyphens) {
      readiumCSSProperty["value"] = "";
    } else if (preset.$1 == ReadiumCSSName.fontOverride) {
      readiumCSSProperty["value"] = "readium-font-off";
    } else if (preset.$1 == ReadiumCSSName.appearance) {
      readiumCSSProperty["value"] = "readium-default-on";
    } else if (preset.$1 == ReadiumCSSName.publisherDefault) {
      readiumCSSProperty["value"] = "";
    } else if (preset.$1 == ReadiumCSSName.columnCount) {
      readiumCSSProperty["value"] = "auto";
    } else if (preset.$1 == ReadiumCSSName.pageMargins) {
      readiumCSSProperty["value"] = "0.5";
    } else if (preset.$1 == ReadiumCSSName.lineHeight) {
      readiumCSSProperty["value"] = "1.0";
    } else if (preset.$1 == ReadiumCSSName.ligatures) {
      readiumCSSProperty["value"] = "";
    } else if (preset.$1 == ReadiumCSSName.fontFamily) {
      readiumCSSProperty["value"] = "Original";
    } else if (preset.$1 == ReadiumCSSName.fontSize) {
      readiumCSSProperty["value"] = "100%";
    } else if (preset.$1 == ReadiumCSSName.wordSpacing) {
      readiumCSSProperty["value"] = "0.0rem";
    } else if (preset.$1 == ReadiumCSSName.letterSpacing) {
      readiumCSSProperty["value"] = "0.0em";
    } else if (preset.$1 == ReadiumCSSName.textAlignment) {
      readiumCSSProperty["value"] = "justify";
    } else if (preset.$1 == ReadiumCSSName.paraIndent) {
      readiumCSSProperty["value"] = "";
    } else if (preset.$1 == ReadiumCSSName.scroll) {
      if (preset.$2!) {
        readiumCSSProperty["value"] = "readium-scroll-on";
      } else {
        readiumCSSProperty["value"] = "readium-scroll-off";
      }
    }
    return readiumCSSProperty;
  }

  String buildStringProperties(Map<String, String> list) {
    String string = "";
    for (MapEntry<String, String> property in list.entries) {
      string = "$string ${property.key}: ${property.value};";
    }
    return string;
  }
}
