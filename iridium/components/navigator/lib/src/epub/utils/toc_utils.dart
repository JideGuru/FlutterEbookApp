// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

class TocUtils {
  /// Creates a list of Link that contains the Link in the reading order.
  /// @param A list of root Link, representing the first level of Link.
  /// @return A new list which contains the original Link as found when reading from start to end.
  static List<Link> flatten(List<Link> roots) => _flattenListRec(roots, []);

  static List<Link> _flattenListRec(
      List<Link> roots, List<Link> flattenedRoots) {
    String? prevHref;
    for (Link tocItem in roots) {
      String href = tocItem.href;
      // Small heuristic to avoid adding the same Link twice...
      if (prevHref == null || prevHref != href) {
        flattenedRoots.add(tocItem);
      }
      if (tocItem.children.isNotEmpty) {
        _flattenListRec(tocItem.children, flattenedRoots);
        prevHref = flattenedRoots.last.href;
      } else {
        prevHref = href;
      }
    }
    return flattenedRoots;
  }

  static Map<Link, int> mapTableOfContentToSpineItemIndex(
      Publication? publication, List<Link> flattenedTableOfContents) {
    Map<Link, int> result = {};
    if (publication != null) {
      for (Link link in flattenedTableOfContents) {
        int index = publication.readingOrder
            .indexWhere((spineItem) => spineItem.href == link.hrefPart);
        result[link] = index;
      }
    }
    return result;
  }
}
