/* eslint-disable */
//
//  highlight.js
//  r2-navigator-kotlin
//
//  Organized by Taehyun Kim on 6/27/19 from r2-navigator-js.
//
//  Copyright 2019 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

const ROOT_CLASS_REDUCE_MOTION = "r2-reduce-motion";
const ROOT_CLASS_NO_FOOTNOTES = "r2-no-popup-foonotes";
const POPUP_DIALOG_CLASS = "r2-popup-dialog";
const FOOTNOTES_CONTAINER_CLASS = "r2-footnote-container";
const FOOTNOTES_CLOSE_BUTTON_CLASS = "r2-footnote-close";
const FOOTNOTE_FORCE_SHOW = "r2-footnote-force-show";
const TTS_ID_PREVIOUS = "r2-tts-previous";
const TTS_ID_NEXT = "r2-tts-next";
const TTS_ID_SLIDER = "r2-tts-slider";
const TTS_ID_ACTIVE_WORD = "r2-tts-active-word";
const TTS_ID_CONTAINER = "r2-tts-txt";
const TTS_ID_INFO = "r2-tts-info";
const TTS_NAV_BUTTON_CLASS = "r2-tts-button";
const TTS_ID_SPEAKING_DOC_ELEMENT = "r2-tts-speaking-el";
const TTS_CLASS_INJECTED_SPAN = "r2-tts-speaking-txt";
const TTS_CLASS_INJECTED_SUBSPAN = "r2-tts-speaking-word";
const TTS_ID_INJECTED_PARENT = "r2-tts-speaking-txt-parent";
const ID_HIGHLIGHTS_CONTAINER = "R2_ID_HIGHLIGHTS_CONTAINER";
const ID_ANNOTATION_CONTAINER = "R2_ID_ANNOTATION_CONTAINER";
const CLASS_HIGHLIGHT_CONTAINER = "R2_CLASS_HIGHLIGHT_CONTAINER";
const CLASS_ANNOTATION_CONTAINER = "R2_CLASS_ANNOTATION_CONTAINER";
const CLASS_HIGHLIGHT_AREA = "R2_CLASS_HIGHLIGHT_AREA";
const CLASS_ANNOTATION_AREA = "R2_CLASS_ANNOTATION_AREA";
const CLASS_HIGHLIGHT_BOUNDING_AREA = "R2_CLASS_HIGHLIGHT_BOUNDING_AREA";
const CLASS_ANNOTATION_BOUNDING_AREA = "R2_CLASS_ANNOTATION_BOUNDING_AREA";
// tslint:disable-next-line:max-line-length
const _blacklistIdClassForCFI = [
  POPUP_DIALOG_CLASS,
  TTS_CLASS_INJECTED_SPAN,
  TTS_CLASS_INJECTED_SUBSPAN,
  ID_HIGHLIGHTS_CONTAINER,
  CLASS_HIGHLIGHT_CONTAINER,
  CLASS_HIGHLIGHT_AREA,
  CLASS_HIGHLIGHT_BOUNDING_AREA,
  "resize-sensor",
];
const CLASS_PAGINATED = "r2-css-paginated";

//const IS_DEV = (process.env.NODE_ENV === "development" || process.env.NODE_ENV === "dev");
const IS_DEV = false;
const _highlights = [];

let _highlightsContainer;
let _annotationContainer;
let lastMouseDownX = -1;
let lastMouseDownY = -1;
let bodyEventListenersSet = false;

const USE_SVG = false;
const DEFAULT_BACKGROUND_COLOR_OPACITY = 0.3;
const ALT_BACKGROUND_COLOR_OPACITY = 0.45;

//const DEBUG_VISUALS = false;
const DEBUG_VISUALS = false;
const DEFAULT_BACKGROUND_COLOR = {
  blue: 100,
  green: 50,
  red: 230,
};

const ANNOTATION_WIDTH = 15;

function resetHighlightBoundingStyle(_win, highlightBounding) {
  if (
    highlightBounding.getAttribute("class") == CLASS_ANNOTATION_BOUNDING_AREA
  ) {
    return;
  }
  highlightBounding.style.outline = "none";
  highlightBounding.style.setProperty(
    "background-color",
    "transparent",
    "important"
  );
}

function setHighlightAreaStyle(win, highlightAreas, highlight) {
  const useSVG = !DEBUG_VISUALS && USE_SVG;
  for (const highlightArea of highlightAreas) {
    const isSVG = useSVG && highlightArea.namespaceURI === SVG_XML_NAMESPACE;
    const opacity = ALT_BACKGROUND_COLOR_OPACITY;
    if (isSVG) {
      highlightArea.style.setProperty(
        "fill",
        `rgb(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue})`,
        "important"
      );
      highlightArea.style.setProperty(
        "fill-opacity",
        `${opacity}`,
        "important"
      );
      highlightArea.style.setProperty(
        "stroke",
        `rgb(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue})`,
        "important"
      );
      highlightArea.style.setProperty(
        "stroke-opacity",
        `${opacity}`,
        "important"
      );
    } else {
      highlightArea.style.setProperty(
        "background-color",
        `rgba(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue}, ${opacity})`,
        "important"
      );
    }
  }
}

function resetHighlightAreaStyle(win, highlightArea) {
  const useSVG = !DEBUG_VISUALS && USE_SVG;
  //const useSVG = USE_SVG;
  const isSVG = useSVG && highlightArea.namespaceURI === SVG_XML_NAMESPACE;
  const id = isSVG
    ? highlightArea.parentNode &&
      highlightArea.parentNode.parentNode &&
      highlightArea.parentNode.parentNode.nodeType === Node.ELEMENT_NODE &&
      highlightArea.parentNode.parentNode.getAttribute
      ? highlightArea.parentNode.parentNode.getAttribute("id")
      : undefined
    : highlightArea.parentNode &&
      highlightArea.parentNode.nodeType === Node.ELEMENT_NODE &&
      highlightArea.parentNode.getAttribute
    ? highlightArea.parentNode.getAttribute("id")
    : undefined;
  if (id) {
    const highlight = _highlights.find((h) => {
      return h.id === id;
    });
    if (highlight) {
      const opacity = DEFAULT_BACKGROUND_COLOR_OPACITY;
      if (isSVG) {
        highlightArea.style.setProperty(
          "fill",
          `rgb(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue})`,
          "important"
        );
        highlightArea.style.setProperty(
          "fill-opacity",
          `${opacity}`,
          "important"
        );
        highlightArea.style.setProperty(
          "stroke",
          `rgb(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue})`,
          "important"
        );
        highlightArea.style.setProperty(
          "stroke-opacity",
          `${opacity}`,
          "important"
        );
      } else {
        highlightArea.style.setProperty(
          "background-color",
          `rgba(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue}, ${opacity})`,
          "important"
        );
      }
    }
  }
}
function processTouchEvent(win, ev) {
  const document = win.document;
  const scrollElement = getScrollingElement(document);
  const x = ev.changedTouches[0].clientX;
  const y = ev.changedTouches[0].clientY;
  if (!_highlightsContainer) {
    return;
  }
  const paginated = isPaginated(document);
  const bodyRect = document.body.getBoundingClientRect();
  let xOffset;
  let yOffset;
  if (navigator.userAgent.match(/Android/i)) {
    xOffset = paginated ? -scrollElement.scrollLeft : bodyRect.left;
    yOffset = paginated ? -scrollElement.scrollTop : bodyRect.top;
  } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
    xOffset = paginated ? 0 : -scrollElement.scrollLeft;
    yOffset = paginated ? 0 : bodyRect.top;
  }
  let foundHighlight;
  let foundElement;
  let foundRect;
  //    _highlights.sort(function(a, b) {
  //        console.log(JSON.stringify(a.selectionInfo))
  //        return a.selectionInfo.cleanText.length < b.selectionInfo.cleanText.length
  //    })
  for (let i = _highlights.length - 1; i >= 0; i--) {
    const highlight = _highlights[i];
    let highlightParent = document.getElementById(`${highlight.id}`);
    if (!highlightParent) {
      highlightParent = _highlightsContainer.querySelector(`#${highlight.id}`);
    }
    if (!highlightParent) {
      continue;
    }
    let hit = false;
    const highlightFragments = highlightParent.querySelectorAll(
      `.${CLASS_HIGHLIGHT_AREA}`
    );
    for (const highlightFragment of highlightFragments) {
      const withRect = highlightFragment;
      const left = withRect.rect.left + xOffset;
      const top = withRect.rect.top + yOffset;
      foundRect = withRect.rect;
      if (
        x >= left &&
        x < left + withRect.rect.width &&
        y >= top &&
        y < top + withRect.rect.height
      ) {
        hit = true;
        break;
      }
    }
    if (hit) {
      foundHighlight = highlight;
      foundElement = highlightParent;
      break;
    }
  }
  if (!foundHighlight || !foundElement) {
    const highlightBoundings = _highlightsContainer.querySelectorAll(
      `.${CLASS_HIGHLIGHT_BOUNDING_AREA}`
    );
    for (const highlightBounding of highlightBoundings) {
      resetHighlightBoundingStyle(win, highlightBounding);
    }
    const allHighlightAreas = Array.from(
      _highlightsContainer.querySelectorAll(`.${CLASS_HIGHLIGHT_AREA}`)
    );
    for (const highlightArea of allHighlightAreas) {
      resetHighlightAreaStyle(win, highlightArea);
    }
    return;
  }

  if (foundElement.getAttribute("data-click")) {
    if (ev.type === "mousemove") {
      const foundElementHighlightAreas = Array.from(
        foundElement.querySelectorAll(`.${CLASS_HIGHLIGHT_AREA}`)
      );
      const allHighlightAreas = _highlightsContainer.querySelectorAll(
        `.${CLASS_HIGHLIGHT_AREA}`
      );
      for (const highlightArea of allHighlightAreas) {
        if (foundElementHighlightAreas.indexOf(highlightArea) < 0) {
          resetHighlightAreaStyle(win, highlightArea);
        }
      }
      setHighlightAreaStyle(win, foundElementHighlightAreas, foundHighlight);
      const foundElementHighlightBounding = foundElement.querySelector(
        `.${CLASS_HIGHLIGHT_BOUNDING_AREA}`
      );
      const allHighlightBoundings = _highlightsContainer.querySelectorAll(
        `.${CLASS_HIGHLIGHT_BOUNDING_AREA}`
      );
      for (const highlightBounding of allHighlightBoundings) {
        if (
          !foundElementHighlightBounding ||
          highlightBounding !== foundElementHighlightBounding
        ) {
          resetHighlightBoundingStyle(win, highlightBounding);
        }
      }
      if (foundElementHighlightBounding) {
        if (DEBUG_VISUALS) {
          setHighlightBoundingStyle(
            win,
            foundElementHighlightBounding,
            foundHighlight
          );
        }
      }
    } else if (ev.type === "touchstart" || ev.type === "touchend") {
      const size = {
        screenWidth: window.outerWidth,
        screenHeight: window.outerHeight,
        left: foundRect.left,
        width: foundRect.width,
        top: foundRect.top,
        height: foundRect.height,
      };
      const payload = {
        highlight: foundHighlight.id,
        size: size,
      };

      if (
        typeof window !== "undefined" &&
        typeof window.process === "object" &&
        window.process.type === "renderer"
      ) {
        electron_1.ipcRenderer.sendToHost(R2_EVENT_HIGHLIGHT_CLICK, payload);
      } else if (window.webkitURL) {
        console.log(foundHighlight.id.includes("R2_ANNOTATION_"));
        if (foundHighlight.id.search("R2_ANNOTATION_") >= 0) {
          if (navigator.userAgent.match(/Android/i)) {
            Flutter.highlightAnnotationMarkActivated(foundHighlight.id);
          } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
            webkit.messageHandlers.highlightAnnotationMarkActivated.postMessage(
              foundHighlight.id
            );
          }
        } else if (foundHighlight.id.search("R2_HIGHLIGHT_") >= 0) {
          if (navigator.userAgent.match(/Android/i)) {
            Flutter.highlightActivated(foundHighlight.id);
          } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
            webkit.messageHandlers.highlightActivated.postMessage(
              foundHighlight.id
            );
          }
        }
      }

      ev.stopPropagation();
      ev.preventDefault();
    }
  }
}

function processMouseEvent(win, ev) {
  const document = win.document;
  const scrollElement = getScrollingElement(document);
  const x = ev.clientX;
  const y = ev.clientY;
  if (!_highlightsContainer) {
    return;
  }

  const paginated = isPaginated(document);
  const bodyRect = document.body.getBoundingClientRect();
  let xOffset;
  let yOffset;
  if (navigator.userAgent.match(/Android/i)) {
    xOffset = paginated ? -scrollElement.scrollLeft : bodyRect.left;
    yOffset = paginated ? -scrollElement.scrollTop : bodyRect.top;
  } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
    xOffset = paginated ? 0 : -scrollElement.scrollLeft;
    yOffset = paginated ? 0 : bodyRect.top;
  }
  let foundHighlight;
  let foundElement;
  let foundRect;
  for (let i = _highlights.length - 1; i >= 0; i--) {
    const highlight = _highlights[i];
    let highlightParent = document.getElementById(`${highlight.id}`);
    if (!highlightParent) {
      highlightParent = _highlightsContainer.querySelector(`#${highlight.id}`);
    }
    if (!highlightParent) {
      continue;
    }
    let hit = false;
    const highlightFragments = highlightParent.querySelectorAll(
      `.${CLASS_HIGHLIGHT_AREA}`
    );
    for (const highlightFragment of highlightFragments) {
      const withRect = highlightFragment;
      const left = withRect.rect.left + xOffset;
      const top = withRect.rect.top + yOffset;
      foundRect = withRect.rect;
      if (
        x >= left &&
        x < left + withRect.rect.width &&
        y >= top &&
        y < top + withRect.rect.height
      ) {
        hit = true;
        break;
      }
    }
    if (hit) {
      foundHighlight = highlight;
      foundElement = highlightParent;
      break;
    }
  }

  if (!foundHighlight || !foundElement) {
    const highlightBoundings = _highlightsContainer.querySelectorAll(
      `.${CLASS_HIGHLIGHT_BOUNDING_AREA}`
    );
    for (const highlightBounding of highlightBoundings) {
      resetHighlightBoundingStyle(win, highlightBounding);
    }
    const allHighlightAreas = Array.from(
      _highlightsContainer.querySelectorAll(`.${CLASS_HIGHLIGHT_AREA}`)
    );
    for (const highlightArea of allHighlightAreas) {
      resetHighlightAreaStyle(win, highlightArea);
    }
    return;
  }

  if (foundElement.getAttribute("data-click")) {
    if (ev.type === "mousemove") {
      const foundElementHighlightAreas = Array.from(
        foundElement.querySelectorAll(`.${CLASS_HIGHLIGHT_AREA}`)
      );
      const allHighlightAreas = _highlightsContainer.querySelectorAll(
        `.${CLASS_HIGHLIGHT_AREA}`
      );
      for (const highlightArea of allHighlightAreas) {
        if (foundElementHighlightAreas.indexOf(highlightArea) < 0) {
          resetHighlightAreaStyle(win, highlightArea);
        }
      }
      setHighlightAreaStyle(win, foundElementHighlightAreas, foundHighlight);
      const foundElementHighlightBounding = foundElement.querySelector(
        `.${CLASS_HIGHLIGHT_BOUNDING_AREA}`
      );
      const allHighlightBoundings = _highlightsContainer.querySelectorAll(
        `.${CLASS_HIGHLIGHT_BOUNDING_AREA}`
      );
      for (const highlightBounding of allHighlightBoundings) {
        if (
          !foundElementHighlightBounding ||
          highlightBounding !== foundElementHighlightBounding
        ) {
          resetHighlightBoundingStyle(win, highlightBounding);
        }
      }
      if (foundElementHighlightBounding) {
        if (DEBUG_VISUALS) {
          setHighlightBoundingStyle(
            win,
            foundElementHighlightBounding,
            foundHighlight
          );
        }
      }
    } else if (ev.type === "mouseup" || ev.type === "touchend") {
      const touchedPosition = {
        screenWidth: window.outerWidth,
        screenHeight: window.innerHeight,
        left: foundRect.left,
        width: foundRect.width,
        top: foundRect.top,
        height: foundRect.height,
      };

      const payload = {
        highlight: foundHighlight,
        position: touchedPosition,
      };

      if (
        typeof window !== "undefined" &&
        typeof window.process === "object" &&
        window.process.type === "renderer"
      ) {
        electron_1.ipcRenderer.sendToHost(R2_EVENT_HIGHLIGHT_CLICK, payload);
      } else if (window.webkitURL) {
        if (foundHighlight.id.search("R2_ANNOTATION_") >= 0) {
          if (navigator.userAgent.match(/Android/i)) {
            Flutter.highlightAnnotationMarkActivated(foundHighlight.id);
          } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
            webkit.messageHandlers.highlightAnnotationMarkActivated.postMessage(
              foundHighlight.id
            );
          }
        } else if (foundHighlight.id.search("R2_HIGHLIGHT_") >= 0) {
          if (navigator.userAgent.match(/Android/i)) {
            Flutter.highlightActivated(foundHighlight.id);
          } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
            webkit.messageHandlers.highlightActivated.postMessage(
              foundHighlight.id
            );
          }
        }
      }

      ev.stopPropagation();
    }
  }
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

function replaceOverlapingRects(rects) {
  for (let i = 0; i < rects.length; i++) {
    for (let j = i + 1; j < rects.length; j++) {
      const rect1 = rects[i];
      const rect2 = rects[j];
      if (rect1 === rect2) {
        if (IS_DEV) {
          console.log("replaceOverlapingRects rect1 === rect2 ??!");
        }
        continue;
      }
      if (rectsTouchOrOverlap(rect1, rect2, -1)) {
        let toAdd = [];
        let toRemove;
        let toPreserve;
        const subtractRects1 = rectSubtract(rect1, rect2);
        if (subtractRects1.length === 1) {
          toAdd = subtractRects1;
          toRemove = rect1;
          toPreserve = rect2;
        } else {
          const subtractRects2 = rectSubtract(rect2, rect1);
          if (subtractRects1.length < subtractRects2.length) {
            toAdd = subtractRects1;
            toRemove = rect1;
            toPreserve = rect2;
          } else {
            toAdd = subtractRects2;
            toRemove = rect2;
            toPreserve = rect1;
          }
        }
        if (IS_DEV) {
          const toCheck = [];
          toCheck.push(toPreserve);
          Array.prototype.push.apply(toCheck, toAdd);
          checkOverlaps(toCheck);
        }
        if (IS_DEV) {
          console.log(
            `CLIENT RECT: overlap, cut one rect into ${toAdd.length}`
          );
        }
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

function checkOverlaps(rects) {
  const stillOverlapingRects = [];
  for (const rect1 of rects) {
    for (const rect2 of rects) {
      if (rect1 === rect2) {
        continue;
      }
      const has1 = stillOverlapingRects.indexOf(rect1) >= 0;
      const has2 = stillOverlapingRects.indexOf(rect2) >= 0;
      if (!has1 || !has2) {
        if (rectsTouchOrOverlap(rect1, rect2, -1)) {
          if (!has1) {
            stillOverlapingRects.push(rect1);
          }
          if (!has2) {
            stillOverlapingRects.push(rect2);
          }
          console.log("CLIENT RECT: overlap ---");
          console.log(
            `#1 TOP:${rect1.top} BOTTOM:${rect1.bottom} LEFT:${rect1.left} RIGHT:${rect1.right} WIDTH:${rect1.width} HEIGHT:${rect1.height}`
          );
          console.log(
            `#2 TOP:${rect2.top} BOTTOM:${rect2.bottom} LEFT:${rect2.left} RIGHT:${rect2.right} WIDTH:${rect2.width} HEIGHT:${rect2.height}`
          );
          const xOverlap = getRectOverlapX(rect1, rect2);
          console.log(`xOverlap: ${xOverlap}`);
          const yOverlap = getRectOverlapY(rect1, rect2);
          console.log(`yOverlap: ${yOverlap}`);
        }
      }
    }
  }
  if (stillOverlapingRects.length) {
    console.log(`CLIENT RECT: overlaps ${stillOverlapingRects.length}`);
  }
}

function removeContainedRects(rects, tolerance) {
  const rectsToKeep = new Set(rects);
  for (const rect of rects) {
    const bigEnough = rect.width > 1 && rect.height > 1;
    if (!bigEnough) {
      if (IS_DEV) {
        console.log("CLIENT RECT: remove tiny");
      }
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
        if (IS_DEV) {
          console.log("CLIENT RECT: remove contained");
        }
        rectsToKeep.delete(rect);
        break;
      }
    }
  }
  return Array.from(rectsToKeep);
}

function almostEqual(a, b, tolerance) {
  return Math.abs(a - b) <= tolerance;
}

function rectIntersect(rect1, rect2) {
  const maxLeft = Math.max(rect1.left, rect2.left);
  const minRight = Math.min(rect1.right, rect2.right);
  const maxTop = Math.max(rect1.top, rect2.top);
  const minBottom = Math.min(rect1.bottom, rect2.bottom);
  const rect = {
    bottom: minBottom,
    height: Math.max(0, minBottom - maxTop),
    left: maxLeft,
    right: minRight,
    top: maxTop,
    width: Math.max(0, minRight - maxLeft),
  };
  return rect;
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

function rectContainsPoint(rect, x, y, tolerance) {
  return (
    (rect.left < x || almostEqual(rect.left, x, tolerance)) &&
    (rect.right > x || almostEqual(rect.right, x, tolerance)) &&
    (rect.top < y || almostEqual(rect.top, y, tolerance)) &&
    (rect.bottom > y || almostEqual(rect.bottom, y, tolerance))
  );
}

function rectContains(rect1, rect2, tolerance) {
  return (
    rectContainsPoint(rect1, rect2.left, rect2.top, tolerance) &&
    rectContainsPoint(rect1, rect2.right, rect2.top, tolerance) &&
    rectContainsPoint(rect1, rect2.left, rect2.bottom, tolerance) &&
    rectContainsPoint(rect1, rect2.right, rect2.bottom, tolerance)
  );
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
        if (IS_DEV) {
          console.log("mergeTouchingRects rect1 === rect2 ??!");
        }
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
        if (IS_DEV) {
          console.log(
            `CLIENT RECT: merging two into one, VERTICAL: ${rectsLineUpVertically} HORIZONTAL: ${rectsLineUpHorizontally} (${doNotMergeHorizontallyAlignedRects})`
          );
        }
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

function getClientRectsNoOverlap(range, doNotMergeHorizontallyAlignedRects) {
  const rangeClientRects = range.getClientRects();
  return getClientRectsNoOverlap_(
    rangeClientRects,
    doNotMergeHorizontallyAlignedRects
  );
}

function getClientRectsNoOverlap_(
  clientRects,
  doNotMergeHorizontallyAlignedRects
) {
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
        if (IS_DEV) {
          console.log("CLIENT RECT: remove small");
        }
        newRects.splice(j, 1);
      } else {
        if (IS_DEV) {
          console.log("CLIENT RECT: remove small, but keep otherwise empty!");
        }
        break;
      }
    }
  }
  if (IS_DEV) {
    checkOverlaps(newRects);
  }
  if (IS_DEV) {
    console.log(
      `CLIENT RECT: reduced ${originalRects.length} --> ${newRects.length}`
    );
  }
  return newRects;
}

function isPaginated(document) {
  return (
    document &&
    document.documentElement &&
    document.documentElement.classList.contains(CLASS_PAGINATED)
  );
}

function getScrollingElement(document) {
  if (document.scrollingElement) {
    return document.scrollingElement;
  }
  return document.body;
}

function ensureContainer(win, annotationFlag) {
  const document = win.document;

  if (!_highlightsContainer) {
    if (!bodyEventListenersSet) {
      bodyEventListenersSet = true;
      document.body.addEventListener(
        "mousedown",
        (ev) => {
          lastMouseDownX = ev.clientX;
          lastMouseDownY = ev.clientY;
        },
        false
      );
      document.body.addEventListener(
        "mouseup",
        (ev) => {
          if (
            Math.abs(lastMouseDownX - ev.clientX) < 3 &&
            Math.abs(lastMouseDownY - ev.clientY) < 3
          ) {
            processMouseEvent(win, ev);
          }
        },
        false
      );
      document.body.addEventListener(
        "mousemove",
        (ev) => {
          processMouseEvent(win, ev);
        },
        false
      );

      document.body.addEventListener(
        "touchend",
        function touchEnd(e) {
          processTouchEvent(win, e);
        },
        false
      );
    }
    _highlightsContainer = document.createElement("div");
    _highlightsContainer.setAttribute("id", ID_HIGHLIGHTS_CONTAINER);

    _highlightsContainer.style.setProperty("pointer-events", "none");
    document.body.append(_highlightsContainer);
  }

  return _highlightsContainer;
}

function hideAllhighlights() {
  if (_highlightsContainer) {
    _highlightsContainer.remove();
    _highlightsContainer = null;
  }
}

function destroyAllhighlights() {
  hideAllhighlights();
  _highlights.splice(0, _highlights.length);
}

export function destroyHighlight(id) {
  let i = -1;
  let _document = window.document;
  const highlight = _highlights.find((h, j) => {
    i = j;
    return h.id === id;
  });
  if (highlight && i >= 0 && i < _highlights.length) {
    _highlights.splice(i, 1);
  }
  const highlightContainer = _document.getElementById(id);
  if (highlightContainer) {
    highlightContainer.remove();
  }
}

function isCfiTextNode(node) {
  return node.nodeType !== Node.ELEMENT_NODE;
}

function getChildTextNodeCfiIndex(element, child) {
  let found = -1;
  let textNodeIndex = -1;
  let previousWasElement = false;
  for (let i = 0; i < element.childNodes.length; i++) {
    const childNode = element.childNodes[i];
    const isText = isCfiTextNode(childNode);
    if (isText || previousWasElement) {
      textNodeIndex += 2;
    }
    if (isText) {
      if (childNode === child) {
        found = textNodeIndex;
        break;
      }
    }
    previousWasElement = childNode.nodeType === Node.ELEMENT_NODE;
  }
  return found;
}

function getCommonAncestorElement(node1, node2) {
  if (node1.nodeType === Node.ELEMENT_NODE && node1 === node2) {
    return node1;
  }
  if (node1.nodeType === Node.ELEMENT_NODE && node1.contains(node2)) {
    return node1;
  }
  if (node2.nodeType === Node.ELEMENT_NODE && node2.contains(node1)) {
    return node2;
  }
  const node1ElementAncestorChain = [];
  let parent = node1.parentNode;
  while (parent && parent.nodeType === Node.ELEMENT_NODE) {
    node1ElementAncestorChain.push(parent);
    parent = parent.parentNode;
  }
  const node2ElementAncestorChain = [];
  parent = node2.parentNode;
  while (parent && parent.nodeType === Node.ELEMENT_NODE) {
    node2ElementAncestorChain.push(parent);
    parent = parent.parentNode;
  }
  let commonAncestor = node1ElementAncestorChain.find(
    (node1ElementAncestor) => {
      return node2ElementAncestorChain.indexOf(node1ElementAncestor) >= 0;
    }
  );
  if (!commonAncestor) {
    commonAncestor = node2ElementAncestorChain.find((node2ElementAncestor) => {
      return node1ElementAncestorChain.indexOf(node2ElementAncestor) >= 0;
    });
  }
  return commonAncestor;
}

function fullQualifiedSelector(node) {
  if (node.nodeType !== Node.ELEMENT_NODE) {
    const lowerCaseName =
      (node.localName && node.localName.toLowerCase()) ||
      node.nodeName.toLowerCase();
    return lowerCaseName;
  }
  //return cssPath(node, justSelector);
  return cssPath(node, true);
}

export function getCurrentSelectionInfo() {
  const selection = window.getSelection();
  if (!selection) {
    return undefined;
  }
  if (selection.isCollapsed) {
    console.log("^^^ SELECTION COLLAPSED.");
    return undefined;
  }
  const rawText = selection.toString();
  const cleanText = rawText.trim().replace(/\n/g, " ").replace(/\s\s+/g, " ");
  if (cleanText.length === 0) {
    console.log("^^^ SELECTION TEXT EMPTY.");
    return undefined;
  }
  if (!selection.anchorNode || !selection.focusNode) {
    return undefined;
  }
  const range =
    selection.rangeCount === 1
      ? selection.getRangeAt(0)
      : createOrderedRange(
          selection.anchorNode,
          selection.anchorOffset,
          selection.focusNode,
          selection.focusOffset
        );
  if (!range || range.collapsed) {
    console.log("$$$$$$$$$$$$$$$$$ CANNOT GET NON-COLLAPSED SELECTION RANGE?!");
    return undefined;
  }
  const rangeInfo = convertRange(range, fullQualifiedSelector, computeCFI);
  if (!rangeInfo) {
    console.log("^^^ SELECTION RANGE INFO FAIL?!");
    return undefined;
  }

  if (IS_DEV && DEBUG_VISUALS) {
    const restoredRange = convertRangeInfo(win.document, rangeInfo);
    if (restoredRange) {
      if (
        restoredRange.startOffset === range.startOffset &&
        restoredRange.endOffset === range.endOffset &&
        restoredRange.startContainer === range.startContainer &&
        restoredRange.endContainer === range.endContainer
      ) {
        console.log("SELECTION RANGE RESTORED OKAY (dev check).");
      } else {
        console.log("SELECTION RANGE RESTORE FAIL (dev check).");
        dumpDebug(
          "SELECTION",
          selection.anchorNode,
          selection.anchorOffset,
          selection.focusNode,
          selection.focusOffset,
          getCssSelector
        );
        dumpDebug(
          "ORDERED RANGE FROM SELECTION",
          range.startContainer,
          range.startOffset,
          range.endContainer,
          range.endOffset,
          getCssSelector
        );
        dumpDebug(
          "RESTORED RANGE",
          restoredRange.startContainer,
          restoredRange.startOffset,
          restoredRange.endContainer,
          restoredRange.endOffset,
          getCssSelector
        );
      }
    } else {
      console.log("CANNOT RESTORE SELECTION RANGE ??!");
    }
  } else {
  }

  return {
    locations: rangeInfo2Location(rangeInfo),
    text: {
      highlight: rawText,
    },
  };
}

function checkBlacklisted(el) {
  let blacklistedId;
  const id = el.getAttribute("id");
  if (id && _blacklistIdClassForCFI.indexOf(id) >= 0) {
    console.log("checkBlacklisted ID: " + id);
    blacklistedId = id;
  }
  let blacklistedClass;
  for (const item of _blacklistIdClassForCFI) {
    if (el.classList.contains(item)) {
      console.log("checkBlacklisted CLASS: " + item);
      blacklistedClass = item;
      break;
    }
  }
  if (blacklistedId || blacklistedClass) {
    return true;
  }

  return false;
}

function cssPath(node, optimized) {
  if (node.nodeType !== Node.ELEMENT_NODE) {
    return "";
  }

  const steps = [];
  let contextNode = node;
  while (contextNode) {
    const step = _cssPathStep(contextNode, !!optimized, contextNode === node);
    if (!step) {
      break; // Error - bail out early.
    }
    steps.push(step.value);
    if (step.optimized) {
      break;
    }
    contextNode = contextNode.parentNode;
  }
  steps.reverse();
  return steps.join(" > ");
}
// tslint:disable-next-line:max-line-length
// https://chromium.googlesource.com/chromium/blink/+/master/Source/devtools/front_end/components/DOMPresentationUtils.js#316
function _cssPathStep(node, optimized, isTargetNode) {
  function prefixedElementClassNames(nd) {
    const classAttribute = nd.getAttribute("class");
    if (!classAttribute) {
      return [];
    }

    return classAttribute
      .split(/\s+/g)
      .filter(Boolean)
      .map((nm) => {
        // The prefix is required to store "__proto__" in a object-based map.
        return "$" + nm;
      });
  }

  function idSelector(idd) {
    return "#" + escapeIdentifierIfNeeded(idd);
  }

  function escapeIdentifierIfNeeded(ident) {
    if (isCSSIdentifier(ident)) {
      return ident;
    }

    const shouldEscapeFirst = /^(?:[0-9]|-[0-9-]?)/.test(ident);
    const lastIndex = ident.length - 1;
    return ident.replace(/./g, function (c, ii) {
      return (shouldEscapeFirst && ii === 0) || !isCSSIdentChar(c)
        ? escapeAsciiChar(c, ii === lastIndex)
        : c;
    });
  }

  function escapeAsciiChar(c, isLast) {
    return "\\" + toHexByte(c) + (isLast ? "" : " ");
  }

  function toHexByte(c) {
    let hexByte = c.charCodeAt(0).toString(16);
    if (hexByte.length === 1) {
      hexByte = "0" + hexByte;
    }
    return hexByte;
  }

  function isCSSIdentChar(c) {
    if (/[a-zA-Z0-9_-]/.test(c)) {
      return true;
    }
    return c.charCodeAt(0) >= 0xa0;
  }

  function isCSSIdentifier(value) {
    return /^-?[a-zA-Z_][a-zA-Z0-9_-]*$/.test(value);
  }

  if (node.nodeType !== Node.ELEMENT_NODE) {
    return undefined;
  }
  const lowerCaseName =
    (node.localName && node.localName.toLowerCase()) ||
    node.nodeName.toLowerCase();

  const element = node;

  const id = element.getAttribute("id");

  if (optimized) {
    if (id) {
      return {
        optimized: true,
        value: idSelector(id),
      };
    }
    if (
      lowerCaseName === "body" ||
      lowerCaseName === "head" ||
      lowerCaseName === "html"
    ) {
      return {
        optimized: true,
        value: lowerCaseName, // node.nodeNameInCorrectCase(),
      };
    }
  }

  const nodeName = lowerCaseName; // node.nodeNameInCorrectCase();
  if (id) {
    return {
      optimized: true,
      value: nodeName + idSelector(id),
    };
  }

  const parent = node.parentNode;

  if (!parent || parent.nodeType === Node.DOCUMENT_NODE) {
    return {
      optimized: true,
      value: nodeName,
    };
  }

  const prefixedOwnClassNamesArray_ = prefixedElementClassNames(element);

  const prefixedOwnClassNamesArray = []; // .keySet()
  prefixedOwnClassNamesArray_.forEach((arrItem) => {
    if (prefixedOwnClassNamesArray.indexOf(arrItem) < 0) {
      prefixedOwnClassNamesArray.push(arrItem);
    }
  });

  let needsClassNames = false;
  let needsNthChild = false;
  let ownIndex = -1;
  let elementIndex = -1;
  const siblings = parent.children;

  for (
    let i = 0;
    (ownIndex === -1 || !needsNthChild) && i < siblings.length;
    ++i
  ) {
    const sibling = siblings[i];
    if (sibling.nodeType !== Node.ELEMENT_NODE) {
      continue;
    }
    elementIndex += 1;
    if (sibling === node) {
      ownIndex = elementIndex;
      continue;
    }
    if (needsNthChild) {
      continue;
    }

    // sibling.nodeNameInCorrectCase()
    const siblingName =
      (sibling.localName && sibling.localName.toLowerCase()) ||
      sibling.nodeName.toLowerCase();
    if (siblingName !== nodeName) {
      continue;
    }
    needsClassNames = true;

    const ownClassNames = [];
    prefixedOwnClassNamesArray.forEach((arrItem) => {
      ownClassNames.push(arrItem);
    });
    let ownClassNameCount = ownClassNames.length;

    if (ownClassNameCount === 0) {
      needsNthChild = true;
      continue;
    }
    const siblingClassNamesArray_ = prefixedElementClassNames(sibling);
    const siblingClassNamesArray = []; // .keySet()
    siblingClassNamesArray_.forEach((arrItem) => {
      if (siblingClassNamesArray.indexOf(arrItem) < 0) {
        siblingClassNamesArray.push(arrItem);
      }
    });

    for (const siblingClass of siblingClassNamesArray) {
      const ind = ownClassNames.indexOf(siblingClass);
      if (ind < 0) {
        continue;
      }

      ownClassNames.splice(ind, 1); // delete ownClassNames[siblingClass];

      if (!--ownClassNameCount) {
        needsNthChild = true;
        break;
      }
    }
  }

  let result = nodeName;
  if (
    isTargetNode &&
    nodeName === "input" &&
    element.getAttribute("type") &&
    !element.getAttribute("id") &&
    !element.getAttribute("class")
  ) {
    result += '[type="' + element.getAttribute("type") + '"]';
  }
  if (needsNthChild) {
    result += ":nth-child(" + (ownIndex + 1) + ")";
  } else if (needsClassNames) {
    for (const prefixedName of prefixedOwnClassNamesArray) {
      result += "." + escapeIdentifierIfNeeded(prefixedName.substr(1));
    }
  }

  return {
    optimized: false,
    value: result,
  };
}

function computeCFI(node) {
  // TODO: handle character position inside text node
  if (node.nodeType !== Node.ELEMENT_NODE) {
    return undefined;
  }

  let cfi = "";

  let currentElement = node;
  while (
    currentElement.parentNode &&
    currentElement.parentNode.nodeType === Node.ELEMENT_NODE
  ) {
    const blacklisted = checkBlacklisted(currentElement);
    if (!blacklisted) {
      const currentElementParentChildren = currentElement.parentNode.children;
      let currentElementIndex = -1;
      for (let i = 0; i < currentElementParentChildren.length; i++) {
        if (currentElement === currentElementParentChildren[i]) {
          currentElementIndex = i;
          break;
        }
      }
      if (currentElementIndex >= 0) {
        const cfiIndex = (currentElementIndex + 1) * 2;
        cfi =
          cfiIndex +
          (currentElement.id ? "[" + currentElement.id + "]" : "") +
          (cfi.length ? "/" + cfi : "");
      }
    }
    currentElement = currentElement.parentNode;
  }

  return "/" + cfi;
}

function _createHighlight(locations, color, pointerInteraction, type) {
  const rangeInfo = location2RangeInfo(locations);
  const uniqueStr = `${rangeInfo.cfi}${rangeInfo.startContainerElementCssSelector}${rangeInfo.startContainerChildTextNodeIndex}${rangeInfo.startOffset}${rangeInfo.endContainerElementCssSelector}${rangeInfo.endContainerChildTextNodeIndex}${rangeInfo.endOffset}`;

  const hash = require("hash.js");
  const sha256Hex = hash.sha256().update(uniqueStr).digest("hex");

  var id;
  if (type == ID_HIGHLIGHTS_CONTAINER) {
    id = "R2_HIGHLIGHT_" + sha256Hex;
  } else {
    id = "R2_ANNOTATION_" + sha256Hex;
  }

  destroyHighlight(id);

  const highlight = {
    color: color ? color : DEFAULT_BACKGROUND_COLOR,
    id,
    pointerInteraction,
    rangeInfo,
  };
  _highlights.push(highlight);
  createHighlightDom(
    window,
    highlight,
    type == ID_ANNOTATION_CONTAINER ? true : false
  );

  return highlight;
}

export function createHighlight(selectionInfo, color, pointerInteraction) {
  return _createHighlight(
    selectionInfo,
    color,
    pointerInteraction,
    ID_HIGHLIGHTS_CONTAINER
  );
}

export function createAnnotation(id) {
  let i = -1;

  const highlight = _highlights.find((h, j) => {
    i = j;
    return h.id === id;
  });
  if (i == _highlights.length) return;

  var locations = {
    locations: rangeInfo2Location(highlight.rangeInfo),
  };

  return _createHighlight(
    locations,
    highlight.color,
    true,
    ID_ANNOTATION_CONTAINER
  );
}

function createHighlightDom(win, highlight, annotationFlag) {
  const document = win.document;

  const scale =
    1 /
    (win.READIUM2 && win.READIUM2.isFixedLayout
      ? win.READIUM2.fxlViewportScale
      : 1);

  const scrollElement = getScrollingElement(document);

  const range = convertRangeInfo(document, highlight.rangeInfo);
  if (!range) {
    return undefined;
  }

  const paginated = isPaginated(document);
  const highlightsContainer = ensureContainer(win, annotationFlag);
  const highlightParent = document.createElement("div");

  highlightParent.setAttribute("id", highlight.id);
  highlightParent.setAttribute("class", CLASS_HIGHLIGHT_CONTAINER);

  document.body.style.position = "relative";
  highlightParent.style.setProperty("pointer-events", "none");
  if (highlight.pointerInteraction) {
    highlightParent.setAttribute("data-click", "1");
  }

  const bodyRect = document.body.getBoundingClientRect();
  const useSVG = !DEBUG_VISUALS && USE_SVG;
  //const useSVG = USE_SVG;
  const drawUnderline = false;
  const drawStrikeThrough = false;
  const doNotMergeHorizontallyAlignedRects = drawUnderline || drawStrikeThrough;
  //const clientRects = DEBUG_VISUALS ? range.getClientRects() :
  const clientRects = getClientRectsNoOverlap(
    range,
    doNotMergeHorizontallyAlignedRects
  );
  let highlightAreaSVGDocFrag;
  const roundedCorner = 3;
  const underlineThickness = 2;
  const strikeThroughLineThickness = 3;
  const opacity = DEFAULT_BACKGROUND_COLOR_OPACITY;
  let extra = "";
  const rangeAnnotationBoundingClientRect =
    frameForHighlightAnnotationMarkWithID(win, highlight.id);

  let xOffset;
  let yOffset;
  let annotationOffset;

  if (navigator.userAgent.match(/Android/i)) {
    xOffset = paginated ? -scrollElement.scrollLeft : bodyRect.left;
    yOffset = paginated ? -scrollElement.scrollTop : bodyRect.top;
    annotationOffset =
      parseInt(
        (rangeAnnotationBoundingClientRect.right - xOffset) / window.innerWidth
      ) + 1;
  } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
    xOffset = paginated ? 0 : -scrollElement.scrollLeft;
    yOffset = paginated ? 0 : bodyRect.top;
    annotationOffset = parseInt(
      rangeAnnotationBoundingClientRect.right / window.innerWidth + 1
    );
  }

  for (const clientRect of clientRects) {
    if (useSVG) {
      const borderThickness = 0;
      if (!highlightAreaSVGDocFrag) {
        highlightAreaSVGDocFrag = document.createDocumentFragment();
      }
      const highlightAreaSVGRect = document.createElementNS(
        SVG_XML_NAMESPACE,
        "rect"
      );

      highlightAreaSVGRect.setAttribute("class", CLASS_HIGHLIGHT_AREA);
      highlightAreaSVGRect.setAttribute(
        "style",
        `fill: rgb(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue}) !important; fill-opacity: ${opacity} !important; stroke-width: 0;`
      );
      highlightAreaSVGRect.scale = scale;

      /*
             highlightAreaSVGRect.rect = {
             height: clientRect.height,
             left: clientRect.left - xOffset,
             top: clientRect.top - yOffset,
             width: clientRect.width,
             };
             */

      if (annotationFlag) {
        highlightAreaSVGRect.rect = {
          height: ANNOTATION_WIDTH, //rangeAnnotationBoundingClientRect.height - rangeAnnotationBoundingClientRect.height/4,
          left: window.innerWidth * annotationOffset - ANNOTATION_WIDTH,
          top: rangeAnnotationBoundingClientRect.top - yOffset,
          width: ANNOTATION_WIDTH,
        };
      } else {
        highlightAreaSVGRect.rect = {
          height: clientRect.height,
          left: clientRect.left - xOffset,
          top: clientRect.top - yOffset,
          width: clientRect.width,
        };
      }

      highlightAreaSVGRect.setAttribute("rx", `${roundedCorner * scale}`);
      highlightAreaSVGRect.setAttribute("ry", `${roundedCorner * scale}`);
      highlightAreaSVGRect.setAttribute(
        "x",
        `${(highlightAreaSVGRect.rect.left - borderThickness) * scale}`
      );
      highlightAreaSVGRect.setAttribute(
        "y",
        `${(highlightAreaSVGRect.rect.top - borderThickness) * scale}`
      );
      highlightAreaSVGRect.setAttribute(
        "height",
        `${(highlightAreaSVGRect.rect.height + borderThickness * 2) * scale}`
      );
      highlightAreaSVGRect.setAttribute(
        "width",
        `${(highlightAreaSVGRect.rect.width + borderThickness * 2) * scale}`
      );
      highlightAreaSVGDocFrag.appendChild(highlightAreaSVGRect);
      if (drawUnderline) {
        const highlightAreaSVGLine = document.createElementNS(
          SVG_XML_NAMESPACE,
          "line"
        );
        highlightAreaSVGRect.setAttribute("class", CLASS_HIGHLIGHT_AREA);
        highlightAreaSVGLine.setAttribute(
          "style",
          `stroke-linecap: round; stroke-width: ${
            underlineThickness * scale
          }; stroke: rgb(${highlight.color.red}, ${highlight.color.green}, ${
            highlight.color.blue
          }) !important; stroke-opacity: ${opacity} !important`
        );
        highlightAreaSVGLine.scale = scale;
        /*
                 highlightAreaSVGLine.rect = {
                 height: clientRect.height,
                 left: clientRect.left - xOffset,
                 top: clientRect.top - yOffset,
                 width: clientRect.width,
                 };
                 */
        if (annotationFlag) {
          highlightAreaSVGLine.rect = {
            height: ANNOTATION_WIDTH, //rangeAnnotationBoundingClientRect.height - rangeAnnotationBoundingClientRect.height/4,
            left: window.innerWidth * annotationOffset - ANNOTATION_WIDTH,
            top: rangeAnnotationBoundingClientRect.top - yOffset,
            width: ANNOTATION_WIDTH,
          };
        } else {
          highlightAreaSVGLine.rect = {
            height: clientRect.height,
            left: clientRect.left - xOffset,
            top: clientRect.top - yOffset,
            width: clientRect.width,
          };
        }

        const lineOffset =
          highlightAreaSVGLine.rect.width > roundedCorner ? roundedCorner : 0;
        highlightAreaSVGLine.setAttribute(
          "x1",
          `${(highlightAreaSVGLine.rect.left + lineOffset) * scale}`
        );
        highlightAreaSVGLine.setAttribute(
          "x2",
          `${
            (highlightAreaSVGLine.rect.left +
              highlightAreaSVGLine.rect.width -
              lineOffset) *
            scale
          }`
        );
        const y =
          (highlightAreaSVGLine.rect.top +
            highlightAreaSVGLine.rect.height -
            underlineThickness / 2) *
          scale;
        highlightAreaSVGLine.setAttribute("y1", `${y}`);
        highlightAreaSVGLine.setAttribute("y2", `${y}`);
        highlightAreaSVGLine.setAttribute(
          "height",
          `${highlightAreaSVGLine.rect.height * scale}`
        );
        highlightAreaSVGLine.setAttribute(
          "width",
          `${highlightAreaSVGLine.rect.width * scale}`
        );
        highlightAreaSVGDocFrag.appendChild(highlightAreaSVGLine);
      }
      if (drawStrikeThrough) {
        const highlightAreaSVGLine = document.createElementNS(
          SVG_XML_NAMESPACE,
          "line"
        );

        highlightAreaSVGRect.setAttribute("class", CLASS_HIGHLIGHT_AREA);
        highlightAreaSVGLine.setAttribute(
          "style",
          `stroke-linecap: butt; stroke-width: ${
            strikeThroughLineThickness * scale
          }; stroke: rgb(${highlight.color.red}, ${highlight.color.green}, ${
            highlight.color.blue
          }) !important; stroke-opacity: ${opacity} !important`
        );
        highlightAreaSVGLine.scale = scale;

        /*
                 highlightAreaSVGLine.rect = {
                 height: clientRect.height,
                 left: clientRect.left - xOffset,
                 top: clientRect.top - yOffset,
                 width: clientRect.width,
                 };
                 */

        if (annotationFlag) {
          highlightAreaSVGLine.rect = {
            height: ANNOTATION_WIDTH, //rangeAnnotationBoundingClientRect.height - rangeAnnotationBoundingClientRect.height/4,
            left: window.innerWidth * annotationOffset - ANNOTATION_WIDTH,
            top: rangeAnnotationBoundingClientRect.top - yOffset,
            width: ANNOTATION_WIDTH,
          };
        } else {
          highlightAreaSVGLine.rect = {
            height: clientRect.height,
            left: clientRect.left - xOffset,
            top: clientRect.top - yOffset,
            width: clientRect.width,
          };
        }

        highlightAreaSVGLine.setAttribute(
          "x1",
          `${highlightAreaSVGLine.rect.left * scale}`
        );
        highlightAreaSVGLine.setAttribute(
          "x2",
          `${
            (highlightAreaSVGLine.rect.left + highlightAreaSVGLine.rect.width) *
            scale
          }`
        );
        const lineOffset = highlightAreaSVGLine.rect.height / 2;
        const y = (highlightAreaSVGLine.rect.top + lineOffset) * scale;
        highlightAreaSVGLine.setAttribute("y1", `${y}`);
        highlightAreaSVGLine.setAttribute("y2", `${y}`);
        highlightAreaSVGLine.setAttribute(
          "height",
          `${highlightAreaSVGLine.rect.height * scale}`
        );
        highlightAreaSVGLine.setAttribute(
          "width",
          `${highlightAreaSVGLine.rect.width * scale}`
        );
        highlightAreaSVGDocFrag.appendChild(highlightAreaSVGLine);
      }
    } else {
      const highlightArea = document.createElement("div");

      highlightArea.setAttribute("class", CLASS_HIGHLIGHT_AREA);

      if (DEBUG_VISUALS) {
        const rgb = Math.round(0xffffff * Math.random());
        const r = rgb >> 16;
        const g = (rgb >> 8) & 255;
        const b = rgb & 255;
        extra = `outline-color: rgb(${r}, ${g}, ${b}); outline-style: solid; outline-width: 1px; outline-offset: -1px;`;
      } else {
        if (drawUnderline) {
          extra += `border-bottom: ${underlineThickness * scale}px solid rgba(${
            highlight.color.red
          }, ${highlight.color.green}, ${
            highlight.color.blue
          }, ${opacity}) !important`;
        }
      }
      highlightArea.setAttribute(
        "style",
        `border-radius: ${roundedCorner}px !important; background-color: rgba(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue}, ${opacity}) !important; ${extra}`
      );
      highlightArea.style.setProperty("pointer-events", "none");
      highlightArea.style.position = paginated ? "fixed" : "absolute";
      highlightArea.scale = scale;
      /*
             highlightArea.rect = {
             height: clientRect.height,
             left: clientRect.left - xOffset,
             top: clientRect.top - yOffset,
             width: clientRect.width,
             };
             */
      if (annotationFlag) {
        highlightArea.rect = {
          height: ANNOTATION_WIDTH, //rangeAnnotationBoundingClientRect.height - rangeAnnotationBoundingClientRect.height/4,
          left: window.innerWidth * annotationOffset - ANNOTATION_WIDTH,
          top: rangeAnnotationBoundingClientRect.top - yOffset,
          width: ANNOTATION_WIDTH,
        };
      } else {
        highlightArea.rect = {
          height: clientRect.height,
          left: clientRect.left - xOffset,
          top: clientRect.top - yOffset,
          width: clientRect.width,
        };
      }

      highlightArea.style.width = `${highlightArea.rect.width * scale}px`;
      highlightArea.style.height = `${highlightArea.rect.height * scale}px`;
      highlightArea.style.left = `${highlightArea.rect.left * scale}px`;
      highlightArea.style.top = `${highlightArea.rect.top * scale}px`;
      highlightParent.append(highlightArea);
      if (!DEBUG_VISUALS && drawStrikeThrough) {
        //if (drawStrikeThrough) {
        const highlightAreaLine = document.createElement("div");
        highlightAreaLine.setAttribute("class", CLASS_HIGHLIGHT_AREA);

        highlightAreaLine.setAttribute(
          "style",
          `background-color: rgba(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue}, ${opacity}) !important;`
        );
        highlightAreaLine.style.setProperty("pointer-events", "none");
        highlightAreaLine.style.position = paginated ? "fixed" : "absolute";
        highlightAreaLine.scale = scale;
        /*
                 highlightAreaLine.rect = {
                 height: clientRect.height,
                 left: clientRect.left - xOffset,
                 top: clientRect.top - yOffset,
                 width: clientRect.width,
                 };
                 */

        if (annotationFlag) {
          highlightAreaLine.rect = {
            height: ANNOTATION_WIDTH, //rangeAnnotationBoundingClientRect.height - rangeAnnotationBoundingClientRect.height/4,
            left: window.innerWidth * annotationOffset - ANNOTATION_WIDTH,
            top: rangeAnnotationBoundingClientRect.top - yOffset,
            width: ANNOTATION_WIDTH,
          };
        } else {
          highlightAreaLine.rect = {
            height: clientRect.height,
            left: clientRect.left - xOffset,
            top: clientRect.top - yOffset,
            width: clientRect.width,
          };
        }

        highlightAreaLine.style.width = `${
          highlightAreaLine.rect.width * scale
        }px`;
        highlightAreaLine.style.height = `${
          strikeThroughLineThickness * scale
        }px`;
        highlightAreaLine.style.left = `${
          highlightAreaLine.rect.left * scale
        }px`;
        highlightAreaLine.style.top = `${
          (highlightAreaLine.rect.top +
            highlightAreaLine.rect.height / 2 -
            strikeThroughLineThickness / 2) *
          scale
        }px`;
        highlightParent.append(highlightAreaLine);
      }
    }

    if (annotationFlag) {
      break;
    }
  }

  if (useSVG && highlightAreaSVGDocFrag) {
    const highlightAreaSVG = document.createElementNS(SVG_XML_NAMESPACE, "svg");
    highlightAreaSVG.setAttribute("pointer-events", "none");
    highlightAreaSVG.style.position = paginated ? "fixed" : "absolute";
    highlightAreaSVG.style.overflow = "visible";
    highlightAreaSVG.style.left = "0";
    highlightAreaSVG.style.top = "0";
    highlightAreaSVG.append(highlightAreaSVGDocFrag);
    highlightParent.append(highlightAreaSVG);
  }

  const highlightBounding = document.createElement("div");

  if (annotationFlag) {
    highlightBounding.setAttribute("class", CLASS_ANNOTATION_BOUNDING_AREA);
    highlightBounding.setAttribute(
      "style",
      `border-radius: ${roundedCorner}px !important; background-color: rgba(${highlight.color.red}, ${highlight.color.green}, ${highlight.color.blue}, ${opacity}) !important; ${extra}`
    );
  } else {
    highlightBounding.setAttribute("class", CLASS_HIGHLIGHT_BOUNDING_AREA);
  }

  highlightBounding.style.setProperty("pointer-events", "none");
  highlightBounding.style.position = paginated ? "fixed" : "absolute";
  highlightBounding.scale = scale;

  if (DEBUG_VISUALS) {
    highlightBounding.setAttribute(
      "style",
      `outline-color: magenta; outline-style: solid; outline-width: 1px; outline-offset: -1px;`
    );
  }

  if (annotationFlag) {
    highlightBounding.rect = {
      height: ANNOTATION_WIDTH, //rangeAnnotationBoundingClientRect.height - rangeAnnotationBoundingClientRect.height/4,
      left: window.innerWidth * annotationOffset - ANNOTATION_WIDTH,
      top: rangeAnnotationBoundingClientRect.top - yOffset,
      width: ANNOTATION_WIDTH,
    };
  } else {
    const rangeBoundingClientRect = range.getBoundingClientRect();
    highlightBounding.rect = {
      height: rangeBoundingClientRect.height,
      left: rangeBoundingClientRect.left - xOffset,
      top: rangeBoundingClientRect.top - yOffset,
      width: rangeBoundingClientRect.width,
    };
  }

  highlightBounding.style.width = `${highlightBounding.rect.width * scale}px`;
  highlightBounding.style.height = `${highlightBounding.rect.height * scale}px`;
  highlightBounding.style.left = `${highlightBounding.rect.left * scale}px`;
  highlightBounding.style.top = `${highlightBounding.rect.top * scale}px`;

  highlightParent.append(highlightBounding);
  highlightsContainer.append(highlightParent);

  return highlightParent;
}

function createOrderedRange(startNode, startOffset, endNode, endOffset) {
  const range = new Range();
  range.setStart(startNode, startOffset);
  range.setEnd(endNode, endOffset);
  if (!range.collapsed) {
    return range;
  }
  console.log(">>> createOrderedRange COLLAPSED ... RANGE REVERSE?");
  const rangeReverse = new Range();
  rangeReverse.setStart(endNode, endOffset);
  rangeReverse.setEnd(startNode, startOffset);
  if (!rangeReverse.collapsed) {
    console.log(">>> createOrderedRange RANGE REVERSE OK.");
    return range;
  }
  console.log(">>> createOrderedRange RANGE REVERSE ALSO COLLAPSED?!");
  return undefined;
}

function convertRange(range, getCssSelector, computeElementCFI) {
  const startIsElement = range.startContainer.nodeType === Node.ELEMENT_NODE;
  const startContainerElement = startIsElement
    ? range.startContainer
    : range.startContainer.parentNode &&
      range.startContainer.parentNode.nodeType === Node.ELEMENT_NODE
    ? range.startContainer.parentNode
    : undefined;
  if (!startContainerElement) {
    return undefined;
  }
  const startContainerChildTextNodeIndex = startIsElement
    ? -1
    : Array.from(startContainerElement.childNodes).indexOf(
        range.startContainer
      );
  if (startContainerChildTextNodeIndex < -1) {
    return undefined;
  }
  const startContainerElementCssSelector = getCssSelector(
    startContainerElement
  );
  const endIsElement = range.endContainer.nodeType === Node.ELEMENT_NODE;
  const endContainerElement = endIsElement
    ? range.endContainer
    : range.endContainer.parentNode &&
      range.endContainer.parentNode.nodeType === Node.ELEMENT_NODE
    ? range.endContainer.parentNode
    : undefined;
  if (!endContainerElement) {
    return undefined;
  }
  const endContainerChildTextNodeIndex = endIsElement
    ? -1
    : Array.from(endContainerElement.childNodes).indexOf(range.endContainer);
  if (endContainerChildTextNodeIndex < -1) {
    return undefined;
  }
  const endContainerElementCssSelector = getCssSelector(endContainerElement);
  const commonElementAncestor = getCommonAncestorElement(
    range.startContainer,
    range.endContainer
  );
  if (!commonElementAncestor) {
    console.log("^^^ NO RANGE COMMON ANCESTOR?!");
    return undefined;
  }
  if (range.commonAncestorContainer) {
    const rangeCommonAncestorElement =
      range.commonAncestorContainer.nodeType === Node.ELEMENT_NODE
        ? range.commonAncestorContainer
        : range.commonAncestorContainer.parentNode;
    if (
      rangeCommonAncestorElement &&
      rangeCommonAncestorElement.nodeType === Node.ELEMENT_NODE
    ) {
      if (commonElementAncestor !== rangeCommonAncestorElement) {
        console.log(">>>>>> COMMON ANCESTOR CONTAINER DIFF??!");
        console.log(getCssSelector(commonElementAncestor));
        console.log(getCssSelector(rangeCommonAncestorElement));
      }
    }
  }
  const rootElementCfi = computeElementCFI(commonElementAncestor);
  const startElementCfi = computeElementCFI(startContainerElement);
  const endElementCfi = computeElementCFI(endContainerElement);
  let cfi;
  if (rootElementCfi && startElementCfi && endElementCfi) {
    let startElementOrTextCfi = startElementCfi;
    if (!startIsElement) {
      const startContainerChildTextNodeIndexForCfi = getChildTextNodeCfiIndex(
        startContainerElement,
        range.startContainer
      );
      startElementOrTextCfi =
        startElementCfi +
        "/" +
        startContainerChildTextNodeIndexForCfi +
        ":" +
        range.startOffset;
    } else {
      if (
        range.startOffset >= 0 &&
        range.startOffset < startContainerElement.childNodes.length
      ) {
        const childNode = startContainerElement.childNodes[range.startOffset];
        if (childNode.nodeType === Node.ELEMENT_NODE) {
          startElementOrTextCfi =
            startElementCfi + "/" + (range.startOffset + 1) * 2;
        } else {
          const cfiTextNodeIndex = getChildTextNodeCfiIndex(
            startContainerElement,
            childNode
          );
          startElementOrTextCfi = startElementCfi + "/" + cfiTextNodeIndex;
        }
      } else {
        const cfiIndexOfLastElement =
          startContainerElement.childElementCount * 2;
        const lastChildNode =
          startContainerElement.childNodes[
            startContainerElement.childNodes.length - 1
          ];
        if (lastChildNode.nodeType === Node.ELEMENT_NODE) {
          startElementOrTextCfi =
            startElementCfi + "/" + (cfiIndexOfLastElement + 1);
        } else {
          startElementOrTextCfi =
            startElementCfi + "/" + (cfiIndexOfLastElement + 2);
        }
      }
    }
    let endElementOrTextCfi = endElementCfi;
    if (!endIsElement) {
      const endContainerChildTextNodeIndexForCfi = getChildTextNodeCfiIndex(
        endContainerElement,
        range.endContainer
      );
      endElementOrTextCfi =
        endElementCfi +
        "/" +
        endContainerChildTextNodeIndexForCfi +
        ":" +
        range.endOffset;
    } else {
      if (
        range.endOffset >= 0 &&
        range.endOffset < endContainerElement.childNodes.length
      ) {
        const childNode = endContainerElement.childNodes[range.endOffset];
        if (childNode.nodeType === Node.ELEMENT_NODE) {
          endElementOrTextCfi = endElementCfi + "/" + (range.endOffset + 1) * 2;
        } else {
          const cfiTextNodeIndex = getChildTextNodeCfiIndex(
            endContainerElement,
            childNode
          );
          endElementOrTextCfi = endElementCfi + "/" + cfiTextNodeIndex;
        }
      } else {
        const cfiIndexOfLastElement = endContainerElement.childElementCount * 2;
        const lastChildNode =
          endContainerElement.childNodes[
            endContainerElement.childNodes.length - 1
          ];
        if (lastChildNode.nodeType === Node.ELEMENT_NODE) {
          endElementOrTextCfi =
            endElementCfi + "/" + (cfiIndexOfLastElement + 1);
        } else {
          endElementOrTextCfi =
            endElementCfi + "/" + (cfiIndexOfLastElement + 2);
        }
      }
    }
    cfi =
      rootElementCfi +
      "," +
      startElementOrTextCfi.replace(rootElementCfi, "") +
      "," +
      endElementOrTextCfi.replace(rootElementCfi, "");
  }
  return {
    cfi,
    endContainerChildTextNodeIndex,
    endContainerElementCssSelector,
    endOffset: range.endOffset,
    startContainerChildTextNodeIndex,
    startContainerElementCssSelector,
    startOffset: range.startOffset,
  };
}

function convertRangeInfo(document, rangeInfo) {
  const startElement = document.querySelector(
    rangeInfo.startContainerElementCssSelector
  );
  if (!startElement) {
    console.log("^^^ convertRangeInfo NO START ELEMENT CSS SELECTOR?!");
    return undefined;
  }
  let startContainer = startElement;
  if (rangeInfo.startContainerChildTextNodeIndex >= 0) {
    if (
      rangeInfo.startContainerChildTextNodeIndex >=
      startElement.childNodes.length
    ) {
      console.log(
        "^^^ convertRangeInfo rangeInfo.startContainerChildTextNodeIndex >= startElement.childNodes.length?!"
      );
      return undefined;
    }
    startContainer =
      startElement.childNodes[rangeInfo.startContainerChildTextNodeIndex];
    if (startContainer.nodeType !== Node.TEXT_NODE) {
      console.log(
        "^^^ convertRangeInfo startContainer.nodeType !== Node.TEXT_NODE?!"
      );
      return undefined;
    }
  }
  const endElement = document.querySelector(
    rangeInfo.endContainerElementCssSelector
  );
  if (!endElement) {
    console.log("^^^ convertRangeInfo NO END ELEMENT CSS SELECTOR?!");
    return undefined;
  }
  let endContainer = endElement;
  if (rangeInfo.endContainerChildTextNodeIndex >= 0) {
    if (
      rangeInfo.endContainerChildTextNodeIndex >= endElement.childNodes.length
    ) {
      console.log(
        "^^^ convertRangeInfo rangeInfo.endContainerChildTextNodeIndex >= endElement.childNodes.length?!"
      );
      return undefined;
    }
    endContainer =
      endElement.childNodes[rangeInfo.endContainerChildTextNodeIndex];
    if (endContainer.nodeType !== Node.TEXT_NODE) {
      console.log(
        "^^^ convertRangeInfo endContainer.nodeType !== Node.TEXT_NODE?!"
      );
      return undefined;
    }
  }
  return createOrderedRange(
    startContainer,
    rangeInfo.startOffset,
    endContainer,
    rangeInfo.endOffset
  );
}

function frameForHighlightAnnotationMarkWithID(win, id) {
  let clientRects = frameForHighlightWithID(id);
  if (!clientRects) return;

  var topClientRect = clientRects[0];
  var maxHeight = topClientRect.height;
  for (const clientRect of clientRects) {
    if (clientRect.top < topClientRect.top) topClientRect = clientRect;
    if (clientRect.height > maxHeight) maxHeight = clientRect.height;
  }

  const document = win.document;

  const scrollElement = getScrollingElement(document);
  const paginated = isPaginated(document);
  const bodyRect = document.body.getBoundingClientRect();
  let yOffset;
  if (navigator.userAgent.match(/Android/i)) {
    yOffset = paginated ? -scrollElement.scrollTop : bodyRect.top;
  } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
    yOffset = paginated ? 0 : bodyRect.top;
  }
  var newTop = topClientRect.top;

  if (_highlightsContainer) {
    do {
      var boundingAreas = document.getElementsByClassName(
        CLASS_ANNOTATION_BOUNDING_AREA
      );
      var found = false;
      //for (let i = 0, length = boundingAreas.snapshotLength; i < length; ++i) {
      for (
        var i = 0, len = boundingAreas.length | 0;
        i < len;
        i = (i + 1) | 0
      ) {
        var boundingArea = boundingAreas[i];
        if (Math.abs(boundingArea.rect.top - (newTop - yOffset)) < 3) {
          newTop += boundingArea.rect.height;
          found = true;
          break;
        }
      }
    } while (found);
  }

  topClientRect.top = newTop;
  topClientRect.height = maxHeight;

  return topClientRect;
}

function highlightWithID(id) {
  let i = -1;
  const highlight = _highlights.find((h, j) => {
    i = j;
    return h.id === id;
  });
  return highlight;
}

function frameForHighlightWithID(id) {
  const highlight = highlightWithID(id);
  if (!highlight) return;

  const document = window.document;
  const scrollElement = getScrollingElement(document);
  const range = convertRangeInfo(document, highlight.rangeInfo);
  if (!range) {
    return undefined;
  }

  const drawUnderline = false;
  const drawStrikeThrough = false;
  const doNotMergeHorizontallyAlignedRects = drawUnderline || drawStrikeThrough;
  //const clientRects = DEBUG_VISUALS ? range.getClientRects() :
  const clientRects = getClientRectsNoOverlap(
    range,
    doNotMergeHorizontallyAlignedRects
  );

  return clientRects;
}

function rangeInfo2Location(rangeInfo) {
  return {
    cssSelector: rangeInfo.startContainerElementCssSelector,
    partialCfi: rangeInfo.cfi,
    domRange: {
      start: {
        cssSelector: rangeInfo.startContainerElementCssSelector,
        textNodeIndex: rangeInfo.startContainerChildTextNodeIndex,
        offset: rangeInfo.startOffset,
      },
      end: {
        cssSelector: rangeInfo.endContainerElementCssSelector,
        textNodeIndex: rangeInfo.endContainerChildTextNodeIndex,
        offset: rangeInfo.endOffset,
      },
    },
  };
}

function location2RangeInfo(location) {
  const locations = location.locations;
  const domRange = locations.domRange;
  const start = domRange.start;
  const end = domRange.end;

  return {
    cfi: location.partialCfi,
    endContainerChildTextNodeIndex: end.textNodeIndex,
    endContainerElementCssSelector: end.cssSelector,
    endOffset: end.offset,
    startContainerChildTextNodeIndex: start.textNodeIndex,
    startContainerElementCssSelector: start.cssSelector,
    startOffset: start.offset,
  };
}

export function rectangleForHighlightWithID(id) {
  const highlight = highlightWithID(id);
  if (!highlight) return;

  const document = window.document;
  const scrollElement = getScrollingElement(document);
  const range = convertRangeInfo(document, highlight.rangeInfo);
  if (!range) {
    return undefined;
  }

  const drawUnderline = false;
  const drawStrikeThrough = false;
  const doNotMergeHorizontallyAlignedRects = drawUnderline || drawStrikeThrough;
  //const clientRects = DEBUG_VISUALS ? range.getClientRects() :
  const clientRects = getClientRectsNoOverlap(
    range,
    doNotMergeHorizontallyAlignedRects
  );
  var size = {
    screenWidth: window.outerWidth,
    screenHeight: window.outerHeight,
    left: clientRects[0].left,
    width: clientRects[0].width,
    top: clientRects[0].top,
    height: clientRects[0].height,
  };

  return size;
}

export function getSelectionRect() {
  try {
    var sel = window.getSelection();
    if (!sel) {
      return;
    }
    var range = sel.getRangeAt(0);

    const clientRect = range.getBoundingClientRect();

    var handleBounds = {
      screenWidth: window.outerWidth,
      screenHeight: window.outerHeight,
      left: clientRect.left,
      width: clientRect.width,
      top: clientRect.top,
      height: clientRect.height,
    };
    return handleBounds;
  } catch (e) {
    return null;
  }
}

export function setScrollMode(flag) {
  if (!flag) {
    document.documentElement.classList.add(CLASS_PAGINATED);
  } else {
    document.documentElement.classList.remove(CLASS_PAGINATED);
  }
}

/*
 if (document.addEventListener) { // IE >= 9; other browsers
        document.addEventListener('contextmenu', function(e) {
            //alert("You've tried to open context menu"); //here you draw your own menu
            //e.preventDefault();
            //let getCssSelector = fullQualifiedSelector;
            
			let str = window.getSelection();
			let selectionInfo = getCurrentSelectionInfo();
			let pos = createHighlight(selectionInfo,{red:10,green:50,blue:230},true);
			let ret2 = createAnnotation(pos.id);
			
  }, false);
    } else { // IE < 9
        document.attachEvent('oncontextmenu', function() {
            alert("You've tried to open context menu");
            window.event.returnValue = false;
        });
    }
*/
