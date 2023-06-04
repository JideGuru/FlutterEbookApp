import * as html from '../html';

import fixture from './html-anchoring-fixture.html';
import htmlBaselines from './html-baselines';

/** Return all text node children of `container`. */
function textNodes(container) {
  const nodes = [];
  const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT);
  while (walker.nextNode()) {
    nodes.push(walker.currentNode);
  }
  return nodes;
}

/**
 * Return the single Node which matches an XPath `query`
 *
 * @param {Node} context
 * @param {string} query
 */
function findNode(context, query) {
  if (query.slice(0, 1) === '/') {
    query = query.slice(1);
  }
  const result = document.evaluate(
    query,
    context,
    null,
    XPathResult.FIRST_ORDERED_NODE_TYPE,
    null
  );
  return result.singleNodeValue;
}

/**
 * Resolve a serialized description of a range into a Range object.
 *
 * @param {Element} root
 * @param {Object} descriptor
 */
function toRange(root, descriptor) {
  let startNode;
  let endNode;

  if (typeof descriptor.startContainer === 'string') {
    startNode = findNode(root, descriptor.startContainer);
  } else {
    startNode = textNodes(root)[descriptor.startContainer];
  }

  if (typeof descriptor.endContainer === 'string') {
    endNode = findNode(root, descriptor.endContainer);
  } else {
    endNode = textNodes(root)[descriptor.endContainer];
  }

  const range = document.createRange();
  range.setStart(startNode, descriptor.startOffset);
  range.setEnd(endNode, descriptor.endOffset);
  return range;
}

function findByType(selectors, type) {
  return selectors.find(function (s) {
    return s.type === type;
  });
}

/**
 * Return a copy of a list of selectors sorted by type.
 */
function sortByType(selectors) {
  return selectors.slice().sort(function (a, b) {
    return a.type.localeCompare(b.type);
  });
}

/**
 * Test cases for mapping ranges to selectors.
 *
 * Originally taken from https://github.com/openannotation/annotator/blob/v1.2.x/test/spec/range_spec.coffee
 */
const rangeSpecs = [
  // Format:
  //   [startContainer, startOffset, endContainer, endOffset, quote, description]
  // Where the *Container nodes are expressed as either an XPath relative to
  // the container or the index into the list of text nodes within the container
  // node

  // Test cases from Annotator v1.2.x's range_spec.coffee
  [0, 13, 0, 27, 'habitant morbi', 'Partial node contents.'],
  [
    0,
    0,
    0,
    37,
    'Pellentesque habitant morbi tristique',
    'Full node contents, textNode refs.',
  ],
  [
    '/p/strong',
    0,
    '/p/strong',
    1,
    'Pellentesque habitant morbi tristique',
    'Full node contents, elementNode refs.',
  ],
  [0, 22, 1, 12, 'morbi tristique senectus et', 'Spanning 2 nodes.'],
  [
    '/p/strong',
    0,
    1,
    12,
    'Pellentesque habitant morbi tristique senectus et',
    'Spanning 2 nodes, elementNode start ref.',
  ],
  [
    1,
    165,
    '/p/em',
    1,
    'egestas semper. Aenean ultricies mi vitae est.',
    'Spanning 2 nodes, elementNode end ref.',
  ],
  [
    9,
    7,
    12,
    11,
    'Level 2\n\n\n  Lorem ipsum',
    'Spanning multiple nodes, textNode refs.',
  ],
  [
    '/p',
    0,
    '/p',
    8,
    'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis.',
    'Spanning multiple nodes, elementNode refs.',
  ],
  [
    '/p[2]',
    0,
    '/p[2]',
    1,
    'Lorem sed do eiusmod tempor.',
    'Full node contents with empty node at end.',
  ],
  [
    '/div/text()[2]',
    0,
    '/div/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, textNode refs',
  ],
  [
    '/div/text()[2]',
    0,
    '/div',
    4,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, elementNode ref at end',
  ],
  [
    '/div/text()[2]',
    0,
    '/div',
    5,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/> at end',
  ],
  [
    '/div/text()[2]',
    0,
    '/div',
    6,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/><br/> at end',
  ],
  [
    '/div/text()[2]',
    0,
    '/div',
    7,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/><br/><br/> at end',
  ],
  [
    '/div',
    3,
    '/div/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, elementNode ref at start',
  ],
  [
    '/div',
    2,
    '/div/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/> at start',
  ],
  [
    '/div',
    1,
    '/div/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/><br/> at start',
  ],
  [
    '/div[2]/text()[2]',
    0,
    '/div[2]/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, textNode refs',
  ],
  [
    '/div[2]/text()[2]',
    0,
    '/div[2]',
    4,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, elementNode ref at end',
  ],
  [
    '/div[2]/text()[2]',
    0,
    '/div[2]',
    5,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/> at end',
  ],
  [
    '/div[2]/text()[2]',
    0,
    '/div[2]',
    6,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/><p><br/></p> at end',
  ],
  [
    '/div[2]/text()[2]',
    0,
    '/div[2]',
    7,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/><p><br/></p><br/> at end',
  ],
  [
    '/div[2]',
    3,
    '/div[2]/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, elementNode ref at start',
  ],
  [
    '/div[2]',
    2,
    '/div[2]/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <p><br/></p> at the start',
  ],
  [
    '/div[2]',
    1,
    '/div[2]/text()[2]',
    28,
    'Lorem sed do eiusmod tempor.',
    'Text between br tags, with <br/><p><br/></p> at the start',
  ],
  [
    '/h2[2]',
    0,
    '/p[4]',
    0,
    'Header Level 2\n\n\n  Mauris lacinia ipsum nulla, id iaculis quam egestas quis.\n\n\n',
    'No text node at the end and offset 0',
  ],

  // Additional test cases
  [
    '/gh-73/div',
    0,
    '/gh-73/span/text()',
    4,
    'Test',
    'Range starting at an element node with no children',
  ],
];

/**
 * Test cases for which describing the range is known to fail for certain
 * selectors.
 */
const expectedFailures = [
  // [description, expectedFailureTypes]
  // Currently empty.
];

describe('HTML anchoring', function () {
  let container;

  beforeEach(function () {
    container = document.createElement('section');
    container.innerHTML = fixture;
    document.body.appendChild(container);
  });

  afterEach(function () {
    container.remove();
  });

  const testCases = rangeSpecs.map(data => {
    return {
      range: {
        startContainer: data[0],
        startOffset: data[1],
        endContainer: data[2],
        endOffset: data[3],
      },
      quote: data[4],
      description: data[5],
    };
  });

  testCases.forEach(testCase => {
    it(`describes and anchors ${testCase.description}`, () => {
      // Resolve the range descriptor to a DOM Range, verify that the expected
      // text was selected.
      const range = toRange(container, testCase.range);
      assert.equal(range.toString(), testCase.quote);

      // Capture a set of selectors describing the range and perform basic sanity
      // checks on them.
      const selectors = html.describe(container, range);

      const rangeSel = findByType(selectors, 'RangeSelector');
      const positionSel = findByType(selectors, 'TextPositionSelector');
      const quoteSel = findByType(selectors, 'TextQuoteSelector');

      const failInfo = expectedFailures.find(function (f) {
        return f[0] === testCase.description;
      });
      let failTypes = {};
      if (failInfo) {
        failTypes = failInfo[1];
      }

      const assertRange = failTypes.range ? assert.notOk : assert.ok;
      const assertQuote = failTypes.quote ? assert.notOk : assert.ok;
      const assertPosition = failTypes.position ? assert.notOk : assert.ok;

      assertRange(rangeSel, 'range selector');
      assertPosition(positionSel, 'position selector');
      assertQuote(quoteSel, 'quote selector');

      // Map each selector back to a Range and check that it refers to the same
      // text. We test each selector in turn to make sure they are all valid.
      const anchored = selectors.map(function (sel) {
        return html.anchor(container, [sel]).then(function (anchoredRange) {
          assert.equal(range.toString(), anchoredRange.toString());
        });
      });
      return Promise.all(anchored);
    });
  });

  describe('When anchoring fails', function () {
    const validQuoteSelector = {
      type: 'TextQuoteSelector',
      exact: 'Lorem ipsum',
    };

    it('throws an error if anchoring using a quote fails', async function () {
      const quoteSelector = {
        type: 'TextQuoteSelector',
        exact: 'This text does not appear in the web page',
      };
      await assert.rejects(
        html.anchor(container, [quoteSelector]),
        'Quote not found'
      );
    });

    it('does not throw an error if anchoring using a position fails', function () {
      const positionSelector = {
        type: 'TextPositionSelector',
        start: 1000,
        end: 1010,
      };

      // Providing an annotation has quote selector that anchors, a position
      // selector which fails to anchor should be ignored.
      return html.anchor(container, [positionSelector, validQuoteSelector]);
    });

    it('does not throw an error if anchoring using a range fails', function () {
      const rangeSelector = {
        type: 'RangeSelector',
        startContainer: '/main',
        startOffset: 1,
        endContainer: '/main',
        endOffset: 5,
      };

      // Providing an annotation has quote selector that anchors, a range
      // selector which fails to anchor should be ignored.
      return html.anchor(container, [rangeSelector, validQuoteSelector]);
    });
  });

  describe('Web page baselines', function () {
    let frame;

    before(function () {
      frame = document.createElement('iframe');
      document.body.appendChild(frame);
    });

    after(function () {
      frame.remove();
    });

    htmlBaselines.forEach(fixture => {
      it(`generates selectors which match the baseline ${fixture.name}`, () => {
        let fixtureHtml = fixture.html;
        const annotations = fixture.annotations.rows;

        // Break references to external stylesheets and images so that the test
        // runner does not try to load them.
        //
        // This method is crude but Good Enough™ for our test fixtures and does
        // not modify the offset of any substrings within the text content of the
        // document for matches that occur in a text-content context (eg.
        // <pre>, <noscript>).
        fixtureHtml = fixtureHtml
          .replace(/src=/g, 'sr_=')
          .replace(/href=/g, 'hre_=');

        frame.contentWindow.document.documentElement.innerHTML = fixtureHtml;

        const annotationsChecked = annotations.map(async ann => {
          const root = frame.contentWindow.document.body;
          const selectors = ann.target[0].selector;
          const range = await html.anchor(root, selectors);
          const newSelectors = await html.describe(root, range);
          assert.deepEqual(sortByType(selectors), sortByType(newSelectors));
        });

        return Promise.all(annotationsChecked);
      });
    });
  });
});
