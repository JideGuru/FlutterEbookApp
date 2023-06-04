/*
 * Copyright 2021 Readium Foundation. All rights reserved.
 * Use of this source code is governed by the BSD-style license
 * available in the top-level LICENSE file of the project.
 */

import { handleDecorationClickEvent } from "./decorator";
import flutter from "./flutter";

window.addEventListener("DOMContentLoaded", function () {
  document.addEventListener("click", onClick, false);
});

async function onClick(event) {
  if (!window.getSelection().isCollapsed) {
    // There's an on-going selection, the tap will dismiss it so we don't forward it.
    return;
  }

  var pixelRatio = window.devicePixelRatio;
  let clickEvent = {
    defaultPrevented: event.defaultPrevented,
    x: event.clientX * pixelRatio,
    y: event.clientY * pixelRatio,
    targetElement: event.target.outerHTML,
    interactiveElement: nearestInteractiveElement(event.target),
  };

  if (await handleDecorationClickEvent(event, clickEvent)) {
    return;
  }

  // Send the tap data over the JS bridge even if it's been handled within the web view, so that
  // it can be preserved and used by the toolkit if needed.
  flutter.onTap(JSON.stringify(clickEvent)).then((shouldPreventDefault) => {
    flutter.log("shouldPreventDefault: " + shouldPreventDefault);
    if (shouldPreventDefault) {
      event.stopPropagation();
      event.preventDefault();
    }
  });
}

// See. https://github.com/JayPanoz/architecture/tree/touch-handling/misc/touch-handling
function nearestInteractiveElement(element) {
  var interactiveTags = [
    "a",
    "audio",
    "button",
    "canvas",
    "details",
    "input",
    "label",
    "option",
    "select",
    "submit",
    "textarea",
    "video",
  ];
  if (interactiveTags.indexOf(element.nodeName.toLowerCase()) != -1) {
    return element.outerHTML;
  }

  // Checks whether the element is editable by the user.
  if (
    element.hasAttribute("contenteditable") &&
    element.getAttribute("contenteditable").toLowerCase() != "false"
  ) {
    return element.outerHTML;
  }

  // Checks parents recursively because the touch might be for example on an <em> inside a <a>.
  if (element.parentElement) {
    return nearestInteractiveElement(element.parentElement);
  }

  return null;
}
