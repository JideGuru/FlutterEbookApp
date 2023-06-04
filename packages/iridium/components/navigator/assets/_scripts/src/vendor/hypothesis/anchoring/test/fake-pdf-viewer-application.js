/**
 * Fake implementation of the parts of PDF.js that the Hypothesis client's
 * anchoring interacts with.
 *
 * This is used to create PDF anchoring tests which can execute quickly and be
 * easier to debug than the full PDF.js viewer application.
 *
 * The general structure is to have `Fake{OriginalClassName}` classes for
 * each of the relevant classes in PDF.js. The APIs of the fakes should conform
 * to the corresponding interfaces defined in `src/types/pdfjs.js`.
 */

import { TinyEmitter as EventEmitter } from 'tiny-emitter';

import { RenderingStates } from '../pdf';

/**
 * Create the DOM structure for a page which matches the structure produced by
 * PDF.js
 *
 * @param {string} content - The text content for the page
 * @param {boolean} rendered - True if the page should be "rendered" or false if
 *        it should be an empty placeholder for a not-yet-rendered page
 * @return {Element} - The root Element for the page
 */
function createPage(content, rendered) {
  const pageEl = document.createElement('div');
  pageEl.classList.add('page');

  if (!rendered) {
    return pageEl;
  }

  const textLayer = document.createElement('div');
  textLayer.classList.add('textLayer');

  content.split(/\n/).forEach(item => {
    const itemEl = document.createElement('div');
    itemEl.textContent = item;
    textLayer.appendChild(itemEl);
  });

  pageEl.appendChild(textLayer);
  return pageEl;
}

/**
 * Fake implementation of `PDFPageProxy` class.
 *
 * The original is defined at https://github.com/mozilla/pdf.js/blob/master/src/display/api.js
 */
class FakePDFPageProxy {
  constructor(pageText) {
    this.pageText = pageText;
  }

  getTextContent(params = {}) {
    if (!params.normalizeWhitespace) {
      return Promise.reject(
        new Error('Expected `normalizeWhitespace` to be true')
      );
    }

    const textContent = {
      // The way that the page text is split into items will depend on
      // the PDF and the version of PDF.js - individual text items might be
      // just symbols, words, phrases or whole lines.
      //
      // Here we split items by line which matches the typical output for a
      // born-digital PDF.
      items: this.pageText.split(/\n/).map(line => ({ str: line })),
    };

    return Promise.resolve(textContent);
  }
}

/**
 * @typedef FakePDFPageViewOptions
 * @prop [boolean] rendered - Whether this page is "rendered", as if it were
 *   near the viewport, or not.
 */

/**
 * Fake implementation of PDF.js `PDFPageView` class.
 *
 * The original is defined at https://github.com/mozilla/pdf.js/blob/master/web/pdf_page_view.js
 */
class FakePDFPageView {
  /**
   * @param {string} text - Text of the page
   * @param {FakePDFPageViewOptions} options
   */
  constructor(text, options) {
    const pageEl = createPage(text, options.rendered);
    const textLayerEl = pageEl.querySelector('.textLayer');

    this.div = pageEl;
    this.textLayer = textLayerEl
      ? { textLayerDiv: textLayerEl, renderingDone: true }
      : null;
    this.renderingState = textLayerEl
      ? RenderingStates.FINISHED
      : RenderingStates.INITIAL;
    this.pdfPage = new FakePDFPageProxy(text);
  }

  dispose() {
    this.div.remove();
  }
}

/**
 * Fake implementation of PDF.js' `PDFViewer` class.
 *
 * The original is defined at https://github.com/mozilla/pdf.js/blob/master/web/pdf_viewer.js
 */
class FakePDFViewer {
  /**
   * @param {Options} options
   */
  constructor(options) {
    this._container = options.container;
    this._content = options.content;

    /** @type {FakePDFPageView} */
    this._pages = [];

    this.viewer = this._container;

    this.eventBus = new EventEmitter();

    /** @type {'auto'|'page-fit'|'page-width'} */
    this.currentScaleValue = 'auto';

    this.update = sinon.stub();
  }

  get pagesCount() {
    return this._content.length;
  }

  /**
   * Return the `FakePDFPageView` object representing a rendered page or a
   * placeholder for one.
   *
   * During PDF.js startup when the document is still being loaded, this may
   * return a nullish value even when the PDF page index is valid.
   */
  getPageView(index) {
    this._checkBounds(index);
    return this._pages[index];
  }

  /**
   * Set the index of the page which is currently visible in the viewport.
   *
   * Pages from `index` up to and including `lastRenderedPage` will be
   * "rendered" and have a text layer available. Other pages will be "un-rendered"
   * with no text layer available, but only a placeholder element for the whole
   * page.
   */
  setCurrentPage(index, lastRenderedPage = index) {
    this._checkBounds(index);

    const pages = this._content.map(
      (text, idx) =>
        new FakePDFPageView(text, {
          rendered: idx >= index && idx <= lastRenderedPage,
        })
    );

    this._container.innerHTML = '';
    this._pages = pages;
    this._pages.forEach(page => this._container.appendChild(page.div));
  }

  dispose() {
    this._pages.forEach(page => page.dispose());
  }

  /**
   * Dispatch an event to notify observers that some event has occurred
   * in the PDF viewer.
   */
  notify(eventName, { eventDispatch = 'eventBus' } = {}) {
    if (eventDispatch === 'eventBus') {
      this.eventBus.emit(eventName);
    } else if (eventDispatch === 'dom') {
      this._container.dispatchEvent(
        new CustomEvent(eventName, { bubbles: true })
      );
    }
  }

  _checkBounds(index) {
    if (index < 0 || index >= this._content.length) {
      throw new Error('Invalid page index ' + index.toString());
    }
  }
}

/**
 * @typedef {Object} Options
 * @property {Element} container - The container into which the fake PDF viewer
 *           should render the content
 * @property {string[]} content - Array of strings containing the text for each
 *           page
 */

/**
 * A minimal fake implementation of PDF.js' PDFViewerApplication interface.
 *
 * This emulates the parts of PDF.js that are relevant to anchoring tests.
 *
 * The original is defined at https://github.com/mozilla/pdf.js/blob/master/web/app.js
 */
export default class FakePDFViewerApplication {
  /**
   * @param {Options} options
   */
  constructor(options) {
    this.appConfig = {
      // The root element which contains all of the PDF.js UI. In the real PDF.js
      // viewer this is generally `document.body`.
      appContainer: document.createElement('div'),
    };
    this.pdfViewer = new FakePDFViewer({
      content: options.content,
      container: options.container,
    });
  }

  /**
   * Remove any DOM elements, timers etc. created by the fake PDF viewer.
   */
  dispose() {
    this.pdfViewer.dispose();
  }
}
