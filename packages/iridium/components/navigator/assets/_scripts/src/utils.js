//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import { TextQuoteAnchor } from "./vendor/hypothesis/anchoring/types";
import flutter from "./flutter";

// Catch JS errors to log them in the app.
window.addEventListener(
  "error",
  function (event) {
    flutter.logError(event.message, event.filename, event.lineno);
  },
  false
);

// Notify native code that the page has loaded.
window.addEventListener(
  "load",
  function () {
    const observer = new ResizeObserver(() => {
      appendVirtualColumnIfNeeded();
    });
    observer.observe(document.body);

    window.addEventListener("orientationchange", function () {
      onViewportWidthChanged().then(() => {
        snapCurrentOffset();
      });
    });
    onViewportWidthChanged();
  },
  false
);

/**
 * Having an odd number of columns when displaying two columns per screen causes snapping and page
 * turning issues. To fix this, we insert a blank virtual column at the end of the resource.
 */
function appendVirtualColumnIfNeeded() {
  const id = "readium-virtual-page";
  var virtualCol = document.getElementById(id);
  if (isScrollModeEnabled() || getColumnCountPerScreen() != 2) {
    if (virtualCol) {
      virtualCol.remove();
    }
  } else {
    var documentWidth = document.scrollingElement.scrollWidth;
    var colCount = documentWidth / pageWidth;
    var hasOddColCount = (Math.round(colCount * 2) / 2) % 1 > 0.1;
    if (hasOddColCount) {
      if (virtualCol) {
        virtualCol.remove();
      } else {
        virtualCol = document.createElement("div");
        virtualCol.setAttribute("id", id);
        virtualCol.style.breakBefore = "column";
        virtualCol.innerHTML = "&#8203;"; // zero-width space
        document.body.appendChild(virtualCol);
      }
    }
  }
}

var pageWidth = 1;

function onViewportWidthChanged() {
  // We can't rely on window.innerWidth for the pageWidth on Android, because if the
  // device pixel ratio is not an integer, we get rounding issues offsetting the pages.
  //
  // See https://github.com/readium/readium-css/issues/97
  // and https://github.com/readium/r2-navigator-kotlin/issues/146
  var width = getViewportWidth();
  pageWidth = width / window.devicePixelRatio;
  setProperty(
    "--RS__viewportWidth",
    "calc(" + width + "px / " + window.devicePixelRatio + ")"
  );
}

function getViewportWidth() {
  return parseInt(
    window
      .getComputedStyle(document.documentElement)
      .getPropertyValue("--RS__nativeViewportWidth")
  );
}

export function getColumnCountPerScreen() {
  return parseInt(
    window
      .getComputedStyle(document.documentElement)
      .getPropertyValue("column-count")
  );
}

export function isScrollModeEnabled() {
  return (
    document.documentElement.style
      .getPropertyValue("--USER__scroll")
      .toString()
      .trim() == "readium-scroll-on"
  );
}

function isRTL() {
  return document.body.dir.toLowerCase() == "rtl";
}

// Scroll to the given TagId in document and snap.
export function scrollToId(id) {
  var element = document.getElementById(id);
  if (!element) {
    return false;
  }

  return scrollToRect(element.getBoundingClientRect());
}

// Position must be in the range [0 - 1], 0-100%.
export function scrollToPosition(position) {
  // flutter.log("scrollToPosition " + position);
  if (position < 0 || position > 1) {
    throw "scrollToPosition() must be given a position from 0.0 to  1.0";
  }

  let offset;
  if (isScrollModeEnabled()) {
    offset = document.scrollingElement.scrollHeight * position;
    document.scrollingElement.scrollTop = offset;
    // window.scrollTo(0, offset);
  } else {
    var documentWidth = document.scrollingElement.scrollWidth;
    var factor = isRTL() ? -1 : 1;
    offset = documentWidth * position * factor;
    document.scrollingElement.scrollLeft = snapOffset(offset);
  }
}

// Scrolls to the first occurrence of the given text snippet.
//
// The expected text argument is a Locator Text object, as defined here:
// https://readium.org/architecture/models/locators/
export function scrollToText(text) {
  let range = rangeFromLocator({ text });
  if (!range) {
    return false;
  }
  scrollToRange(range);
  return true;
}

function scrollToRange(range) {
  scrollToRect(range.getBoundingClientRect());
}

function scrollToRect(rect) {
  if (isScrollModeEnabled()) {
    document.scrollingElement.scrollTop =
      rect.top + window.scrollY - window.innerHeight / 2;
  } else {
    document.scrollingElement.scrollLeft = snapOffset(
      rect.left + window.scrollX
    );
  }
}

export function scrollToStart() {
  // flutter.log("scrollToStart");
  if (!isScrollModeEnabled()) {
    document.scrollingElement.scrollLeft = 0;
  } else {
    document.scrollingElement.scrollTop = 0;
    window.scrollTo(0, 0);
  }
}

export function scrollToEnd() {
  // flutter.log("scrollToEnd");
  if (!isScrollModeEnabled()) {
    var factor = isRTL() ? -1 : 1;
    document.scrollingElement.scrollLeft = snapOffset(
      document.scrollingElement.scrollWidth * factor
    );
  } else {
    document.scrollingElement.scrollTop = document.body.scrollHeight;
    window.scrollTo(0, document.body.scrollHeight);
  }
}

// Returns false if the page is already at the left-most scroll offset.
export function scrollLeft() {
  var documentWidth = document.scrollingElement.scrollWidth;
  var offset = window.scrollX - pageWidth;
  var minOffset = isRTL() ? -(documentWidth - pageWidth) : 0;
  return scrollToOffset(Math.max(offset, minOffset));
}

// Returns false if the page is already at the right-most scroll offset.
export function scrollRight() {
  var documentWidth = document.scrollingElement.scrollWidth;
  var offset = window.scrollX + pageWidth;
  var nbColumns = Math.round(documentWidth / pageWidth);
  var maxOffset = isRTL() ? 0 : (nbColumns - 1) * pageWidth;
  return scrollToOffset(Math.min(offset, maxOffset));
}

// Scrolls to the given left offset.
// Returns false if the page scroll position is already close enough to the given offset.
function scrollToOffset(offset) {
  // flutter.log("scrollToOffset " + offset);
  if (isScrollModeEnabled()) {
    throw "Called scrollToOffset() with scroll mode enabled. This can only be used in paginated mode.";
  }

  var currentOffset = window.scrollX;
  document.scrollingElement.scrollLeft = snapOffset(offset);
  // In some case the scrollX cannot reach the position respecting to innerWidth
  var diff = Math.abs(currentOffset - offset) / pageWidth;
  return diff > 0.01;
}

// Snap the offset to the screen width (page width).
function snapOffset(offset) {
  var value = offset + (isRTL() ? -1 : 1);
  return value - (value % pageWidth);
}

// Snaps the current offset to the page width.
function snapCurrentOffset() {
  // flutter.log("snapCurrentOffset");
  if (isScrollModeEnabled()) {
    return;
  }
  var currentOffset = window.scrollX;
  // Adds half a page to make sure we don't snap to the previous page.
  var factor = isRTL() ? -1 : 1;
  var delta = factor * (pageWidth / 2);
  document.scrollingElement.scrollLeft = snapOffset(currentOffset + delta);
}

export function rangeFromLocator(locator) {
  let text = locator.text;
  if (!text || !text.highlight) {
    return null;
  }
  try {
    let anchor = new TextQuoteAnchor(document.body, text.highlight, {
      prefix: text.before,
      suffix: text.after,
    });
    return anchor.toRange();
  } catch (e) {
    logError(e);
    return null;
  }
}

/// User Settings.

// For setting user setting.
export function setProperty(key, value) {
  var root = document.documentElement;

  root.style.setProperty(key, value);
}

// For removing user setting.
export function removeProperty(key) {
  var root = document.documentElement;

  root.style.removeProperty(key);
}

/// Toolkit

export function log() {
  var message = Array.prototype.slice.call(arguments).join(" ");
  flutter.log(message);
}

export function logError(message) {
  flutter.logError(message, "", 0);
}
