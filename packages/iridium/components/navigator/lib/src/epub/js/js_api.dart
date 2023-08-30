// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/src/epub/decoration.dart';
import 'package:mno_navigator/src/epub/decoration_change.dart';
import 'package:mno_navigator/src/epub/extensions/decoration_change.dart';
import 'package:mno_shared/publication.dart';

class JsApi {
  static const bool logJs = false;
  final int index;
  final HtmlDecorationTemplates htmlDecorationTemplates;
  final Future<dynamic> Function(String) _jsLoader;

  JsApi(this.index, this.htmlDecorationTemplates, this._jsLoader);

  Future<dynamic> loadJS(String jScript) {
    if (logJs) {
      Fimber.d(jScript);
    }
    return _jsLoader(jScript);
  }

  void setElementIds(List<String> elementIds) {
    loadJS("readium.elementIds = ${json.encode(elementIds)};");
  }

  void setViewportWidth(int viewportWidth) {
    loadJS(
        "readium.setProperty('--RS__nativeViewportWidth', '$viewportWidth');");
  }

  void openPage(OpenPageRequest openPageRequestData) {
    if (openPageRequestData.spineItemPercentage != null) {
      loadJS(
          "readium.scrollToPosition(\"${openPageRequestData.spineItemPercentage}\");");
    } else if (openPageRequestData.elementId != null) {
      loadJS("readium.scrollToId(\"${openPageRequestData.elementId}\");");
    } else if (openPageRequestData.text != null) {
      String data = json.encode(openPageRequestData.text!.toJson());
      loadJS("readium.scrollToText($data);");
    }
  }

  void setStyles(ReaderThemeConfig readerTheme, ViewerSettings viewerSettings) {
    if (!hasNoStyle()) {
      ReadiumThemeValues values =
          ReadiumThemeValues(readerTheme, viewerSettings);
      values.cssVarsAndValues.forEach((key, value) {
        loadJS("readium.setProperty('$key', '$value');");
      });
      initPagination();
    }
  }

  void registerDecorationTemplates(
      Map<String, List<Decoration>> decorationsByGroup) {
    Map<String, dynamic>? templates = htmlDecorationTemplates.toJson();
    String script =
        "readium.registerDecorationTemplates(${json.encode(templates)});\n";
    script +=
        _buildJavascriptDecorations(decorationsByGroup, DecorationChange.added);
    loadJS(script);
  }

  void addDecorations(Map<String, List<Decoration>> decorationsByGroup) {
    String script =
        _buildJavascriptDecorations(decorationsByGroup, DecorationChange.added);
    loadJS(script);
  }

  void updateDecorations(Map<String, List<Decoration>> decorationsByGroup) {
    String script = _buildJavascriptDecorations(
        decorationsByGroup, DecorationChange.updated);
    loadJS(script);
  }

  String _buildJavascriptDecorations<T>(Map<String, List<T>> decorationsByGroup,
      DecorationChange Function(T) transform) {
    String script = "";
    for (var entry in decorationsByGroup.entries) {
      String group = entry.key;
      List<T> decorations = entry.value;
      Iterable<DecorationChange> changes = decorations.map(transform);
      String? groupScript =
          changes.javascriptForGroup(group, htmlDecorationTemplates);
      if (groupScript == null) {
        continue;
      }
      script += "$groupScript\n";
    }
    return script;
  }

  void deleteDecorations(Map<String, List<String>> decorationIdsByGroup) {
    String script = _buildJavascriptDecorations(
        decorationIdsByGroup, DecorationChange.removed);
    loadJS(script);
  }

  void setBookmarkIndexes(Iterable<int> bookmarkIndexes) {
    loadJS("readium.setBookmarkIndexes(${bookmarkIndexes.toList()})");
  }

  void updateFontSize(ViewerSettings viewerSettings) {
    loadJS(
        "readium.setProperty('$fontSizeName', '${viewerSettings.fontSize}%');");
    initPagination();
  }

  void updateScrollSnapStop(bool shouldStop) {
    loadJS(
        "readium.setProperty('--RS__scroll-snap-stop', '${shouldStop ? "always" : "normal"}');");
    initPagination();
  }

  void initPagination() {
    loadJS("readium.initPagination();");
  }

  void navigateToStart() => loadJS("readium.scrollToStart();");

  void navigateToEnd() => loadJS("readium.scrollToEnd();");

  void clearSelection() => loadJS("window.getSelection().removeAllRanges();");

  bool hasNoStyle() => false;

  Link? getPreviousSpineItem(Publication publication, Link link) {
    List<Link> spine = publication.readingOrder;
    int spineItemIdx = spine.indexOf(link);
    return spineItemIdx > 0 ? spine[spineItemIdx - 1] : null;
  }

  Link? getNextSpineItem(Publication publication, Link link) {
    List<Link> spine = publication.readingOrder;
    int spineItemIdx = spine.indexOf(link);
    return spineItemIdx < spine.length - 1 ? spine[spineItemIdx + 1] : null;
  }

  Future<dynamic> scrollLeft() => loadJS("readium.scrollLeft();");

  Future<dynamic> scrollRight() => loadJS("readium.scrollRight();");

  Future<Selection?> getCurrentSelection(Locator locator) =>
      loadJS("readium.getCurrentSelection();").then((json) {
        if ((json is Map<String, dynamic>)) {
          return Selection.fromJson(json, locator);
        } else {
          return null;
        }
      });

  String? epubLayoutToJson(EpubLayout layout) {
    if (layout == EpubLayout.fixed) {
      return 'pre-paginated';
    } else if (layout == EpubLayout.reflowable) {
      return 'reflowable';
    }
    return null;
  }

  String? renditionOverflowToJson(Presentation presentation) {
    if (presentation.overflow == PresentationOverflow.auto) {
      return 'auto';
    } else if (presentation.overflow == PresentationOverflow.paginated) {
      return 'paginated';
    } else if (presentation.overflow == PresentationOverflow.scrolled) {
      return presentation.continuous == true ? 'continuous' : 'document';
    }
    return null;
  }

  String? renditionOrientationToJson(PresentationOrientation? orientation) =>
      orientation?.value;

  String? renditionSpreadToJson(PresentationSpread? spread) => spread?.value;

  String? pageToJson(PresentationPage? page) =>
      page?.value.let((it) => 'page-spread-$it');

  String readingProgressionToJson(ReadingProgression progression) =>
      progression.value;
}
