//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

// Base script used by both reflowable and fixed layout resources.

import "core-js";
import "regenerator-runtime/runtime.js";
import flutter from "./flutter";
window.flutter = flutter;
import "./gestures";
import {
  removeProperty,
  scrollLeft,
  scrollRight,
  scrollToEnd,
  scrollToId,
  scrollToPosition,
  scrollToStart,
  scrollToText,
  setProperty,
} from "./utils";
import {
  createAnnotation,
  createHighlight,
  destroyHighlight,
  getCurrentSelectionInfo,
  getSelectionRect,
  rectangleForHighlightWithID,
  setScrollMode,
} from "./highlight";
import { getCurrentSelection } from "./selection";
import { getDecorations, registerTemplates } from "./decorator";

// Public API used by the navigator.
window.readium = {
  // utils
  scrollToId: scrollToId,
  scrollToPosition: scrollToPosition,
  scrollToText: scrollToText,
  scrollLeft: scrollLeft,
  scrollRight: scrollRight,
  scrollToStart: scrollToStart,
  scrollToEnd: scrollToEnd,
  setProperty: setProperty,
  removeProperty: removeProperty,

  // selection
  getCurrentSelection: getCurrentSelection,

  // decoration
  registerDecorationTemplates: registerTemplates,
  getDecorations: getDecorations,
};

// Legacy highlights API.
window.createAnnotation = createAnnotation;
window.createHighlight = createHighlight;
window.destroyHighlight = destroyHighlight;
window.getCurrentSelectionInfo = getCurrentSelectionInfo;
window.getSelectionRect = getSelectionRect;
window.rectangleForHighlightWithID = rectangleForHighlightWithID;
window.setScrollMode = setScrollMode;
