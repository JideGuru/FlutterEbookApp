/**
 * CSS selector that will match the placeholder within a page/tile container.
 */
const placeholderSelector = '.annotator-placeholder';

/**
 * Create or return a placeholder element for anchoring.
 *
 * In document viewers such as PDF.js which only render a subset of long
 * documents at a time, it may not be possible to anchor annotations to the
 * actual text in pages which are off-screen. For these non-rendered pages,
 * a "placeholder" element is created in the approximate X/Y location (eg.
 * middle of the page) where the content will appear. Any highlights for that
 * page are then rendered inside the placeholder.
 *
 * When the viewport is scrolled to the non-rendered page, the placeholder
 * is removed and annotations are re-anchored to the real content.
 *
 * @param {HTMLElement} container - The container element for the page or tile
 *   which is not rendered.
 */
export function createPlaceholder(container) {
  let placeholder = container.querySelector(placeholderSelector);
  if (placeholder) {
    return placeholder;
  }
  placeholder = document.createElement('span');
  placeholder.classList.add('annotator-placeholder');
  placeholder.textContent = 'Loading annotations...';
  container.appendChild(placeholder);
  return placeholder;
}

/**
 * Return true if a page/tile container has a placeholder.
 *
 * @param {HTMLElement} container
 */
export function hasPlaceholder(container) {
  return container.querySelector(placeholderSelector) !== null;
}

/**
 * Remove the placeholder element in `container`, if present.
 *
 * @param {HTMLElement} container
 */
export function removePlaceholder(container) {
  container.querySelector(placeholderSelector)?.remove();
}

/**
 * Return true if `node` is inside a placeholder element created with `createPlaceholder`.
 *
 * This is typically used to test if a highlight element associated with an
 * anchor is inside a placeholder.
 *
 * @param {Node} node
 */
export function isInPlaceholder(node) {
  if (!node.parentElement) {
    return false;
  }
  return node.parentElement.closest(placeholderSelector) !== null;
}
