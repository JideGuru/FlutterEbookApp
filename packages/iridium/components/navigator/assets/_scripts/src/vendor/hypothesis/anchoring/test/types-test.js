import {
  RangeAnchor,
  TextPositionAnchor,
  TextQuoteAnchor,
  $imports,
} from '../types';

import { TextRange } from '../text-range';

// These are primarily basic API tests for the anchoring classes. Tests for
// anchoring a variety of HTML and PDF content exist in `html-test` and
// `pdf-test`.
describe('annotator/anchoring/types', () => {
  let container;

  beforeEach(() => {
    container = document.createElement('div');
    container.innerHTML = [
      'Four score and seven years ago our fathers brought forth on this continent,',
      'a new nation, conceived in Liberty, and dedicated to the proposition that',
      'all men are created equal.',
    ].join(' ');
    document.body.appendChild(container);
  });

  afterEach(() => {
    container.remove();
  });

  describe('RangeAnchor', () => {
    let container;

    beforeEach(() => {
      container = document.createElement('div');
      container.innerHTML = `<main><article><empty></empty><p>This is </p><p>a test article</p></article><empty-b></empty-b></main>`;
    });

    afterEach(() => {
      $imports.$restore();
    });

    describe('#fromRange', () => {
      it('returns a RangeAnchor instance', () => {
        const range = new Range();
        range.selectNodeContents(container);

        const anchor = RangeAnchor.fromRange(container, range);

        assert.instanceOf(anchor, RangeAnchor);
        assert.equal(anchor.root, container);
        assert.equal(anchor.range, range);
      });
    });

    describe('#fromSelector', () => {
      it('returns a RangeAnchor instance', () => {
        const anchor = RangeAnchor.fromSelector(container, {
          type: 'RangeSelector',
          startContainer: '/main[1]/article[1]',
          startOffset: 0,
          endContainer: '/main[1]/article[1]/p[2]',
          endOffset: 1,
        });
        assert.instanceOf(anchor, RangeAnchor);
        assert.equal(anchor.range.toString(), 'This is a');
      });

      [
        // Invalid `startContainer`
        [
          {
            type: 'RangeSelector',
            startContainer: '/main[1]/invalid[1]',
            startOffset: 0,
            endContainer: '/main[1]/article[1]',
            endOffset: 1,
          },
          'Failed to resolve startContainer XPath',
        ],

        // Invalid `endContainer`
        [
          {
            type: 'RangeSelector',
            startContainer: '/main[1]/article[1]',
            startOffset: 0,
            endContainer: '/main[1]/invalid[1]',
            endOffset: 1,
          },
          'Failed to resolve endContainer XPath',
        ],

        // Invalid `startOffset`
        [
          {
            type: 'RangeSelector',
            startContainer: '/main[1]/article[1]',
            startOffset: 50,
            endContainer: '/main[1]/article[1]',
            endOffset: 1,
          },
          'Offset exceeds text length',
        ],

        // Invalid `endOffset`
        [
          {
            type: 'RangeSelector',
            startContainer: '/main[1]/article[1]',
            startOffset: 0,
            endContainer: '/main[1]/article[1]',
            endOffset: 50,
          },
          'Offset exceeds text length',
        ],
      ].forEach(([selector, expectedError], i) => {
        it(`throws if selector fails to resolve (${i})`, () => {
          assert.throws(() => {
            RangeAnchor.fromSelector(container, selector);
          }, expectedError);
        });
      });
    });

    describe('#toRange', () => {
      it('returns the range', () => {
        const range = new Range();
        const anchor = new RangeAnchor(container, range);
        assert.equal(anchor.toRange(), range);
      });
    });

    describe('#toSelector', () => {
      it('returns a valid `RangeSelector` selector', () => {
        const range = new Range();
        range.setStart(container.querySelector('p'), 0);
        range.setEnd(container.querySelector('p:nth-of-type(2)').firstChild, 1);

        const anchor = new RangeAnchor(container, range);

        assert.deepEqual(anchor.toSelector(), {
          type: 'RangeSelector',
          startContainer: '/main[1]/article[1]/p[1]',
          startOffset: 0,
          endContainer: '/main[1]/article[1]/p[2]',
          endOffset: 1,
        });
      });

      it('returns a selector which references the closest elements to the text', () => {
        const range = new Range();
        range.setStart(container.querySelector('empty'), 0);
        range.setEnd(container.querySelector('empty-b'), 0);

        const anchor = new RangeAnchor(container, range);

        // Even though the range starts and ends in `empty*` elements, the
        // returned selector should reference the elements which most closely
        // wrap the text.
        assert.deepEqual(anchor.toSelector(), {
          type: 'RangeSelector',
          startContainer: '/main[1]/article[1]/p[1]',
          startOffset: 0,
          endContainer: '/main[1]/article[1]/p[2]',
          endOffset: 14,
        });
      });
    });
  });

  describe('TextPositionAnchor', () => {
    let FakeTextRange;

    beforeEach(() => {
      const textRange = {
        start: { element: container, offset: 0 },
        end: { element: container, offset: 1 },

        relativeTo: sinon.stub(),
        toRange: sinon.stub(),
      };

      FakeTextRange = {
        fromOffsets: sinon.stub().returns(textRange),
        fromRange: sinon.stub().returns(textRange),
        instance: textRange,
      };

      $imports.$mock({
        './text-range': {
          TextRange: FakeTextRange,
        },
      });
    });

    afterEach(() => {
      $imports.$restore();
    });

    function createTextPositionAnchor() {
      return new TextPositionAnchor(container, 0, 0);
    }

    describe('#fromRange', () => {
      it('returns a TextPositionAnchor instance', () => {
        FakeTextRange.instance.relativeTo.returns(FakeTextRange.instance);
        const range = new Range();

        const anchor = TextPositionAnchor.fromRange(container, range);

        assert.calledWith(FakeTextRange.fromRange, range);
        assert.calledWith(FakeTextRange.instance.relativeTo, container);
        assert.equal(anchor.start, FakeTextRange.instance.start.offset);
        assert.equal(anchor.end, FakeTextRange.instance.end.offset);
      });
    });

    describe('#fromSelector', () => {
      it('returns a TextPositionAnchor instance', () => {
        const anchor = TextPositionAnchor.fromSelector(container, {
          start: 0,
          end: 1,
        });
        assert.equal(anchor.start, 0);
        assert.equal(anchor.end, 1);
      });
    });

    describe('#toSelector', () => {
      it('returns a TextPositionSelector', () => {
        const anchor = createTextPositionAnchor();
        assert.deepEqual(anchor.toSelector(), {
          type: 'TextPositionSelector',
          start: 0,
          end: 0,
        });
      });
    });

    describe('#toRange', () => {
      it('returns a range object', () => {
        FakeTextRange.instance.toRange.returns('fake range');
        const anchor = createTextPositionAnchor();
        assert.equal(anchor.toRange(), 'fake range');
        assert.calledWith(
          FakeTextRange.fromOffsets,
          container,
          anchor.start,
          anchor.end
        );
      });
    });

    describe('integration tests', () => {
      beforeEach(() => {
        $imports.$restore({
          './text-range': true,
        });
      });

      it('can convert a Range to TextPositionSelector and back to a Range', () => {
        const range = document.createRange();
        range.setStart(container.firstChild, 0);
        range.setEnd(container.firstChild, 4);
        const anchor = TextPositionAnchor.fromRange(container, range);
        assert.deepEqual(anchor.toSelector(), {
          type: 'TextPositionSelector',
          start: 0,
          end: 4,
        });
        const newRange = anchor.toRange();
        assert.deepEqual(newRange, range);
        assert.equal(newRange.toString(), 'Four');
      });
    });
  });

  describe('TextQuoteAnchor', () => {
    let fakeMatchQuote;

    beforeEach(() => {
      fakeMatchQuote = sinon.stub();
      $imports.$mock({
        './match-quote': {
          matchQuote: fakeMatchQuote,
        },
      });
    });

    afterEach(() => {
      $imports.$restore();
    });

    function createTextQuoteAnchor() {
      return new TextQuoteAnchor(container, 'Liberty', {
        prefix: 'a new nation, conceived in ',
        suffix: ', and dedicated to the proposition that',
      });
    }

    describe('#fromRange', () => {
      it('returns expected TextQuoteAnchor', () => {
        const quote = 'our fathers';
        const text = container.textContent;
        const pos = text.indexOf(quote);
        const range = TextRange.fromOffsets(
          container,
          pos,
          pos + quote.length
        ).toRange();

        const anchor = TextQuoteAnchor.fromRange(container, range);

        assert.instanceOf(anchor, TextQuoteAnchor);
        assert.equal(anchor.exact, quote);
        assert.deepEqual(anchor.context, {
          prefix: text.slice(Math.max(0, pos - 32), pos),
          suffix: text.slice(pos + quote.length, pos + quote.length + 32),
        });
      });
    });

    describe('#fromSelector', () => {
      it('returns expected TextQuoteAnchor', () => {
        const selector = {
          type: 'TextQuoteSelector',
          exact: 'Liberty',
          prefix: 'a new nation, conceived in ',
          suffix: ', and dedicated to the proposition that',
        };

        const anchor = TextQuoteAnchor.fromSelector(container, selector);

        assert.instanceOf(anchor, TextQuoteAnchor);
        assert.equal(anchor.exact, selector.exact);
        assert.deepEqual(anchor.context, {
          prefix: selector.prefix,
          suffix: selector.suffix,
        });
      });
    });

    describe('#toSelector', () => {
      it('returns a TextQuoteSelector', () => {
        const anchor = createTextQuoteAnchor();
        assert.deepEqual(anchor.toSelector(), {
          type: 'TextQuoteSelector',
          exact: 'Liberty',
          prefix: 'a new nation, conceived in ',
          suffix: ', and dedicated to the proposition that',
        });
      });
    });

    describe('#toRange', () => {
      it('calls `matchQuote` with expected arguments', () => {
        fakeMatchQuote.returns({
          start: 10,
          end: 20,
          score: 1.0,
        });
        const quoteAnchor = new TextQuoteAnchor(container, 'Liberty', {
          prefix: 'expected-prefix',
          suffix: 'expected-suffix',
        });

        quoteAnchor.toRange({ hint: 42 });

        assert.calledWith(fakeMatchQuote, container.textContent, 'Liberty', {
          hint: 42,
          prefix: 'expected-prefix',
          suffix: 'expected-suffix',
        });
      });

      it('returns `Range` representing match found by `matchQuote`', () => {
        fakeMatchQuote.returns({
          start: 10,
          end: 20,
          score: 1.0,
        });
        const quoteAnchor = new TextQuoteAnchor(container, 'Liberty');

        const range = quoteAnchor.toRange();

        assert.instanceOf(range, Range);
        assert.equal(range.toString(), container.textContent.slice(10, 20));
      });

      it('throws if the quote is not found', () => {
        fakeMatchQuote.returns(null);
        const quoteAnchor = new TextQuoteAnchor(
          container,
          'five score and nine years ago'
        );
        assert.throws(() => {
          quoteAnchor.toRange();
        }, 'Quote not found');
      });
    });

    describe('#toPositionAnchor', () => {
      it('returns expected TextPositionAnchor', () => {
        fakeMatchQuote.returns({
          start: 10,
          end: 100,
          score: 1.0,
        });
        const quoteAnchor = new TextQuoteAnchor(container, 'Liberty');

        const pos = quoteAnchor.toPositionAnchor();

        assert.deepEqual(pos, new TextPositionAnchor(container, 10, 100));
      });

      it('throws if the quote is not found', () => {
        fakeMatchQuote.returns(null);
        const quoteAnchor = new TextQuoteAnchor(
          container,
          'five score and nine years ago'
        );
        assert.throws(() => {
          quoteAnchor.toPositionAnchor();
        }, 'Quote not found');
      });
    });

    describe('integration tests', () => {
      beforeEach(() => {
        $imports.$restore({
          './match-quote': true,
        });
      });

      it('can convert a Range to TextQuoteSelector and back to a Range', () => {
        const range = document.createRange();
        range.setStart(container.firstChild, 0);
        range.setEnd(container.firstChild, 4);

        const anchor = TextQuoteAnchor.fromRange(container, range);
        assert.deepEqual(anchor.toSelector(), {
          type: 'TextQuoteSelector',
          prefix: '',
          suffix: ' score and seven years ago our f',
          exact: 'Four',
        });

        const newRange = anchor.toRange();
        assert.equal(newRange.toString(), 'Four');
      });
    });
  });
});
