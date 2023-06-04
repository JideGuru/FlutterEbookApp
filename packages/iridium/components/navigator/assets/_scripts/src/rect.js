//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import { log as logNative } from "./utils";

const debug = false;

/**
 * Converts a DOMRect into a JSON object understandable by the native side.
 */
export function toNativeRect(rect) {
  const pixelRatio = window.devicePixelRatio;
  const width = rect.width * pixelRatio;
  const height = rect.height * pixelRatio;
  const left = rect.left * pixelRatio;
  const top = rect.top * pixelRatio;
  const right = left + width;
  const bottom = top + height;
  return { width, height, left, top, right, bottom };
}

export function getClientRectsNoOverlap(
  range,
  doNotMergeHorizontallyAlignedRects
) {
  let clientRects = range.getClientRects();

  const tolerance = 1;
  const originalRects = [];
  for (const rangeClientRect of clientRects) {
    originalRects.push({
      bottom: rangeClientRect.bottom,
      height: rangeClientRect.height,
      left: rangeClientRect.left,
      right: rangeClientRect.right,
      top: rangeClientRect.top,
      width: rangeClientRect.width,
    });
  }
  const mergedRects = mergeTouchingRects(
    originalRects,
    tolerance,
    doNotMergeHorizontallyAlignedRects
  );
  const noContainedRects = removeContainedRects(mergedRects, tolerance);
  const newRects = replaceOverlapingRects(noContainedRects);
  const minArea = 2 * 2;
  for (let j = newRects.length - 1; j >= 0; j--) {
    const rect = newRects[j];
    const bigEnough = rect.width * rect.height > minArea;
    if (!bigEnough) {
      if (newRects.length > 1) {
        log("CLIENT RECT: remove small");
        newRects.splice(j, 1);
      } else {
        log("CLIENT RECT: remove small, but keep otherwise empty!");
        break;
      }
    }
  }
  log(`CLIENT RECT: reduced ${originalRects.length} --> ${newRects.length}`);
  return newRects;
}

function mergeTouchingRects(
  rects,
  tolerance,
  doNotMergeHorizontallyAlignedRects
) {
  for (let i = 0; i < rects.length; i++) {
    for (let j = i + 1; j < rects.length; j++) {
      const rect1 = rects[i];
      const rect2 = rects[j];
      if (rect1 === rect2) {
        log("mergeTouchingRects rect1 === rect2 ??!");
        continue;
      }
      const rectsLineUpVertically =
        almostEqual(rect1.top, rect2.top, tolerance) &&
        almostEqual(rect1.bottom, rect2.bottom, tolerance);
      const rectsLineUpHorizontally =
        almostEqual(rect1.left, rect2.left, tolerance) &&
        almostEqual(rect1.right, rect2.right, tolerance);
      const horizontalAllowed = !doNotMergeHorizontallyAlignedRects;
      const aligned =
        (rectsLineUpHorizontally && horizontalAllowed) ||
        (rectsLineUpVertically && !rectsLineUpHorizontally);
      const canMerge = aligned && rectsTouchOrOverlap(rect1, rect2, tolerance);
      if (canMerge) {
        log(
          `CLIENT RECT: merging two into one, VERTICAL: ${rectsLineUpVertically} HORIZONTAL: ${rectsLineUpHorizontally} (${doNotMergeHorizontallyAlignedRects})`
        );
        const newRects = rects.filter((rect) => {
          return rect !== rect1 && rect !== rect2;
        });
        const replacementClientRect = getBoundingRect(rect1, rect2);
        newRects.push(replacementClientRect);
        return mergeTouchingRects(
          newRects,
          tolerance,
          doNotMergeHorizontallyAlignedRects
        );
      }
    }
  }
  return rects;
}

function getBoundingRect(rect1, rect2) {
  const left = Math.min(rect1.left, rect2.left);
  const right = Math.max(rect1.right, rect2.right);
  const top = Math.min(rect1.top, rect2.top);
  const bottom = Math.max(rect1.bottom, rect2.bottom);
  return {
    bottom,
    height: bottom - top,
    left,
    right,
    top,
    width: right - left,
  };
}

function removeContainedRects(rects, tolerance) {
  const rectsToKeep = new Set(rects);
  for (const rect of rects) {
    const bigEnough = rect.width > 1 && rect.height > 1;
    if (!bigEnough) {
      log("CLIENT RECT: remove tiny");
      rectsToKeep.delete(rect);
      continue;
    }
    for (const possiblyContainingRect of rects) {
      if (rect === possiblyContainingRect) {
        continue;
      }
      if (!rectsToKeep.has(possiblyContainingRect)) {
        continue;
      }
      if (rectContains(possiblyContainingRect, rect, tolerance)) {
        log("CLIENT RECT: remove contained");
        rectsToKeep.delete(rect);
        break;
      }
    }
  }
  return Array.from(rectsToKeep);
}

function rectContains(rect1, rect2, tolerance) {
  return (
    rectContainsPoint(rect1, rect2.left, rect2.top, tolerance) &&
    rectContainsPoint(rect1, rect2.right, rect2.top, tolerance) &&
    rectContainsPoint(rect1, rect2.left, rect2.bottom, tolerance) &&
    rectContainsPoint(rect1, rect2.right, rect2.bottom, tolerance)
  );
}

export function rectContainsPoint(rect, x, y, tolerance) {
  return (
    (rect.left < x || almostEqual(rect.left, x, tolerance)) &&
    (rect.right > x || almostEqual(rect.right, x, tolerance)) &&
    (rect.top < y || almostEqual(rect.top, y, tolerance)) &&
    (rect.bottom > y || almostEqual(rect.bottom, y, tolerance))
  );
}

function replaceOverlapingRects(rects) {
  for (let i = 0; i < rects.length; i++) {
    for (let j = i + 1; j < rects.length; j++) {
      const rect1 = rects[i];
      const rect2 = rects[j];
      if (rect1 === rect2) {
        log("replaceOverlapingRects rect1 === rect2 ??!");
        continue;
      }
      if (rectsTouchOrOverlap(rect1, rect2, -1)) {
        let toAdd = [];
        let toRemove;
        const subtractRects1 = rectSubtract(rect1, rect2);
        if (subtractRects1.length === 1) {
          toAdd = subtractRects1;
          toRemove = rect1;
        } else {
          const subtractRects2 = rectSubtract(rect2, rect1);
          if (subtractRects1.length < subtractRects2.length) {
            toAdd = subtractRects1;
            toRemove = rect1;
          } else {
            toAdd = subtractRects2;
            toRemove = rect2;
          }
        }
        log(`CLIENT RECT: overlap, cut one rect into ${toAdd.length}`);
        const newRects = rects.filter((rect) => {
          return rect !== toRemove;
        });
        Array.prototype.push.apply(newRects, toAdd);
        return replaceOverlapingRects(newRects);
      }
    }
  }
  return rects;
}

function rectSubtract(rect1, rect2) {
  const rectIntersected = rectIntersect(rect2, rect1);
  if (rectIntersected.height === 0 || rectIntersected.width === 0) {
    return [rect1];
  }
  const rects = [];
  {
    const rectA = {
      bottom: rect1.bottom,
      height: 0,
      left: rect1.left,
      right: rectIntersected.left,
      top: rect1.top,
      width: 0,
    };
    rectA.width = rectA.right - rectA.left;
    rectA.height = rectA.bottom - rectA.top;
    if (rectA.height !== 0 && rectA.width !== 0) {
      rects.push(rectA);
    }
  }
  {
    const rectB = {
      bottom: rectIntersected.top,
      height: 0,
      left: rectIntersected.left,
      right: rectIntersected.right,
      top: rect1.top,
      width: 0,
    };
    rectB.width = rectB.right - rectB.left;
    rectB.height = rectB.bottom - rectB.top;
    if (rectB.height !== 0 && rectB.width !== 0) {
      rects.push(rectB);
    }
  }
  {
    const rectC = {
      bottom: rect1.bottom,
      height: 0,
      left: rectIntersected.left,
      right: rectIntersected.right,
      top: rectIntersected.bottom,
      width: 0,
    };
    rectC.width = rectC.right - rectC.left;
    rectC.height = rectC.bottom - rectC.top;
    if (rectC.height !== 0 && rectC.width !== 0) {
      rects.push(rectC);
    }
  }
  {
    const rectD = {
      bottom: rect1.bottom,
      height: 0,
      left: rectIntersected.right,
      right: rect1.right,
      top: rect1.top,
      width: 0,
    };
    rectD.width = rectD.right - rectD.left;
    rectD.height = rectD.bottom - rectD.top;
    if (rectD.height !== 0 && rectD.width !== 0) {
      rects.push(rectD);
    }
  }
  return rects;
}

function rectIntersect(rect1, rect2) {
  const maxLeft = Math.max(rect1.left, rect2.left);
  const minRight = Math.min(rect1.right, rect2.right);
  const maxTop = Math.max(rect1.top, rect2.top);
  const minBottom = Math.min(rect1.bottom, rect2.bottom);
  return {
    bottom: minBottom,
    height: Math.max(0, minBottom - maxTop),
    left: maxLeft,
    right: minRight,
    top: maxTop,
    width: Math.max(0, minRight - maxLeft),
  };
}

function rectsTouchOrOverlap(rect1, rect2, tolerance) {
  return (
    (rect1.left < rect2.right ||
      (tolerance >= 0 && almostEqual(rect1.left, rect2.right, tolerance))) &&
    (rect2.left < rect1.right ||
      (tolerance >= 0 && almostEqual(rect2.left, rect1.right, tolerance))) &&
    (rect1.top < rect2.bottom ||
      (tolerance >= 0 && almostEqual(rect1.top, rect2.bottom, tolerance))) &&
    (rect2.top < rect1.bottom ||
      (tolerance >= 0 && almostEqual(rect2.top, rect1.bottom, tolerance)))
  );
}

function almostEqual(a, b, tolerance) {
  return Math.abs(a - b) <= tolerance;
}

function log() {
  if (debug) {
    logNative.apply(null, arguments);
  }
}
