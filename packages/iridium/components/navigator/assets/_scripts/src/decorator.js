//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import {
  getClientRectsNoOverlap,
  rectContainsPoint,
  toNativeRect,
} from "./rect";
import flutter from "./flutter";
import { log, logError, rangeFromLocator } from "./utils";

let styles = new Map();
let groups = new Map();
var lastGroupId = 0;

/**
 * Registers a list of additional supported Decoration Templates.
 *
 * Each template object is indexed by the style ID.
 */
export function registerTemplates(newStyles) {
  var stylesheet = "";

  for (const [id, style] of Object.entries(newStyles)) {
    styles.set(id, style);
    if (style.stylesheet) {
      stylesheet += style.stylesheet + "\n";
    }
  }

  if (stylesheet) {
    let styleElement = document.createElement("style");
    styleElement.innerHTML = stylesheet;
    document.getElementsByTagName("head")[0].appendChild(styleElement);
  }
}

/**
 * Returns an instance of DecorationGroup for the given group name.
 */
export function getDecorations(groupName) {
  var group = groups.get(groupName);
  if (!group) {
    let id = "r2-decoration-" + lastGroupId++;
    group = DecorationGroup(id, groupName);
    groups.set(groupName, group);
  }
  return group;
}

/**
 * Handles click events on a Decoration.
 * Returns whether a decoration matched this event.
 */
export async function handleDecorationClickEvent(event, clickEvent) {
  if (groups.size === 0) {
    return false;
  }

  function findTarget() {
    for (const [group, groupContent] of groups) {
      for (const item of groupContent.items.reverse()) {
        if (!item.clickableElements) {
          continue;
        }
        for (const element of item.clickableElements) {
          let rect = element.getBoundingClientRect().toJSON();
          if (rectContainsPoint(rect, event.clientX, event.clientY, 1)) {
            return { group, item, element, rect };
          }
        }
      }
    }
  }

  let target = findTarget();
  if (!target) {
    return false;
  }

  return await flutter.onDecorationActivated(
    JSON.stringify({
      id: target.item.decoration.id,
      group: target.group,
      rect: toNativeRect(target.item.range.getBoundingClientRect()),
      click: clickEvent,
    })
  );
}

/**
 * Creates a DecorationGroup object from a unique HTML ID and its name.
 */
export function DecorationGroup(groupId, groupName) {
  var items = [];
  var lastItemId = 0;
  var container = null;

  /**
   * Adds a new decoration to the group.
   */
  function add(decoration) {
    let id = groupId + "-" + lastItemId++;

    let range = rangeFromLocator(decoration.locator);
    if (!range) {
      log("Can't locate DOM range for decoration", decoration);
      return;
    }

    let item = { id, decoration, range };
    items.push(item);
    layout(item);
  }

  /**
   * Removes the decoration with given ID from the group.
   */
  function remove(decorationId) {
    let index = items.findIndex((i) => i.decoration.id === decorationId);
    if (index === -1) {
      return;
    }

    let item = items[index];
    items.splice(index, 1);
    item.clickableElements = null;
    if (item.container) {
      item.container.remove();
      item.container = null;
    }
  }

  /**
   * Notifies that the given decoration was modified and needs to be updated.
   */
  function update(decoration) {
    remove(decoration.id);
    add(decoration);
  }

  /**
   * Removes all decorations from this group.
   */
  function clear() {
    clearContainer();
    items.length = 0;
  }

  /**
   * Recreates the decoration elements.
   *
   * To be called after reflowing the resource, for example.
   */
  function requestLayout() {
    clearContainer();
    items.forEach((item) => layout(item));
  }

  /**
   * Layouts a single Decoration item.
   */
  function layout(item) {
    let groupContainer = requireContainer();

    let style = styles.get(item.decoration.style);
    if (!style) {
      logError(`Unknown decoration style: ${item.decoration.style}`);
      return;
    }

    let itemContainer = document.createElement("div");
    itemContainer.setAttribute("id", item.id);
    itemContainer.setAttribute("data-style", item.decoration.style);
    itemContainer.style.setProperty("pointer-events", "none");

    let viewportWidth = window.innerWidth;
    let columnCount = parseInt(
      getComputedStyle(document.documentElement).getPropertyValue(
        "column-count"
      )
    );
    let pageWidth = viewportWidth / (columnCount || 1);
    let scrollingElement = document.scrollingElement;
    let xOffset = scrollingElement.scrollLeft;
    let yOffset = scrollingElement.scrollTop;

    function positionElement(element, rect, boundingRect) {
      element.style.position = "absolute";

      if (style.width === "wrap") {
        element.style.width = `${rect.width}px`;
        element.style.height = `${rect.height}px`;
        element.style.left = `${rect.left + xOffset}px`;
        element.style.top = `${rect.top + yOffset}px`;
      } else if (style.width === "viewport") {
        element.style.width = `${viewportWidth}px`;
        element.style.height = `${rect.height}px`;
        let left = Math.floor(rect.left / viewportWidth) * viewportWidth;
        element.style.left = `${left + xOffset}px`;
        element.style.top = `${rect.top + yOffset}px`;
      } else if (style.width === "bounds") {
        element.style.width = `${boundingRect.width}px`;
        element.style.height = `${rect.height}px`;
        element.style.left = `${boundingRect.left + xOffset}px`;
        element.style.top = `${rect.top + yOffset}px`;
      } else if (style.width === "page") {
        element.style.width = `${pageWidth}px`;
        element.style.height = `${rect.height}px`;
        let left = Math.floor(rect.left / pageWidth) * pageWidth;
        element.style.left = `${left + xOffset}px`;
        element.style.top = `${rect.top + yOffset}px`;
      }
    }

    let boundingRect = item.range.getBoundingClientRect();

    let elementTemplate;
    try {
      let template = document.createElement("template");
      template.innerHTML = item.decoration.element.trim();
      elementTemplate = template.content.firstElementChild;
    } catch (error) {
      logError(
        `Invalid decoration element "${item.decoration.element}": ${error.message}`
      );
      return;
    }

    if (style.layout === "boxes") {
      let doNotMergeHorizontallyAlignedRects = true;
      let clientRects = getClientRectsNoOverlap(
        item.range,
        doNotMergeHorizontallyAlignedRects
      );

      clientRects = clientRects.sort((r1, r2) => {
        if (r1.top < r2.top) {
          return -1;
        } else if (r1.top > r2.top) {
          return 1;
        } else {
          return 0;
        }
      });

      for (let clientRect of clientRects) {
        const line = elementTemplate.cloneNode(true);
        line.style.setProperty("pointer-events", "none");
        positionElement(line, clientRect, boundingRect);
        itemContainer.append(line);
      }
    } else if (style.layout === "bounds") {
      const bounds = elementTemplate.cloneNode(true);
      bounds.style.setProperty("pointer-events", "none");
      positionElement(bounds, boundingRect, boundingRect);

      itemContainer.append(bounds);
    }

    groupContainer.append(itemContainer);
    item.container = itemContainer;
    item.clickableElements = Array.from(
      itemContainer.querySelectorAll("[data-activable='1']")
    );
    if (item.clickableElements.length === 0) {
      item.clickableElements = Array.from(itemContainer.children);
    }
  }

  /**
   * Returns the group container element, after making sure it exists.
   */
  function requireContainer() {
    if (!container) {
      container = document.createElement("div");
      container.setAttribute("id", groupId);
      container.setAttribute("data-group", groupName);
      container.style.setProperty("pointer-events", "none");
      document.body.append(container);
    }
    return container;
  }

  /**
   * Removes the group container.
   */
  function clearContainer() {
    if (container) {
      container.remove();
      container = null;
    }
  }

  return { add, remove, update, clear, items, requestLayout };
}

window.addEventListener(
  "load",
  function () {
    // Will relayout all the decorations when the document body is resized.
    const body = document.body;
    var lastSize = { width: 0, height: 0 };
    const observer = new ResizeObserver(() => {
      if (
        lastSize.width === body.clientWidth &&
        lastSize.height === body.clientHeight
      ) {
        return;
      }
      lastSize = {
        width: body.clientWidth,
        height: body.clientHeight,
      };

      groups.forEach(function (group) {
        group.requestLayout();
      });
    });
    observer.observe(body);
  },
  false
);
