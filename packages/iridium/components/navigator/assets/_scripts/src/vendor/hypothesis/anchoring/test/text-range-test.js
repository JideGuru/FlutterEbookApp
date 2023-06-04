import {
  TextPosition,
  TextRange,
  RESOLVE_FORWARDS,
  RESOLVE_BACKWARDS,
} from '../text-range';

import { assertNodesEqual } from '../../../test-util/compare-dom';

const html = `
<main>
  <article>
    <p>This is <b>a</b> <i>test paragraph</i>.</p>
    <!-- Comment in middle of HTML -->
    <pre>Some content</pre>
  </article>
</main>
`;

/**
 * Return all the `Text` descendants of `node`
 *
 * @param {Node} node
 * @return {Text[]}
 */
function textNodes(node) {
  const nodes = [];
  const iter = document.createNodeIterator(node, NodeFilter.SHOW_TEXT);
  let current;
  while ((current = iter.nextNode())) {
    nodes.push(current);
  }
  return nodes;
}

describe('annotator/anchoring/text-range', () => {
  describe('TextPosition', () => {
    let container;
    before(() => {
      container = document.createElement('div');
      container.innerHTML = html;
    });

    describe('#constructor', () => {
      it('throws if offset is negative', () => {
        assert.throws(() => {
          new TextPosition(container, -1);
        }, 'Offset is invalid');
      });
    });

    describe('#resolve', () => {
      it('resolves text position at start of element to correct node and offset', () => {
        const pos = new TextPosition(container, 0);

        const { node, offset } = pos.resolve();

        assertNodesEqual(node, textNodes(container)[0]);
        assert.equal(offset, 0);
      });

      it('resolves text position in middle of element to correct node and offset', () => {
        const pos = new TextPosition(
          container,
          container.textContent.indexOf('is a')
        );

        const { node, offset } = pos.resolve();

        assertNodesEqual(node, container.querySelector('p').firstChild);
        assert.equal(offset, 'This '.length);
      });

      it('resolves text position at end of element to correct node and offset', () => {
        const pos = new TextPosition(container, container.textContent.length);

        const { node, offset } = pos.resolve();

        const lastTextNode = textNodes(container).slice(-1)[0];
        assertNodesEqual(node, lastTextNode);
        assert.equal(offset, lastTextNode.data.length);
      });

      it('ignores text in comments and processing instructions', () => {
        const el = document.createElement('div');
        const text = document.createTextNode('some text');
        const comment = document.createComment('some comment');
        const piNode = document.createProcessingInstruction('foo', 'bar');
        el.append(comment, piNode, text);

        const pos = new TextPosition(el, 3);
        const resolved = pos.resolve();

        assert.equal(resolved.node, text);
        assert.equal(resolved.offset, 3);
      });

      it('throws if offset exceeds current text content length', () => {
        const pos = new TextPosition(
          container,
          container.textContent.length + 1
        );

        assert.throws(() => {
          pos.resolve();
        }, 'Offset exceeds text length');
      });

      it('throws if offset is 0 and `direction` option is not specified', () => {
        const el = document.createElement('div');
        const pos = new TextPosition(el, 0);
        assert.throws(() => {
          pos.resolve();
        });
      });

      describe('when `direction` is `RESOLVE_FORWARDS`', () => {
        it('resolves to next text node if needed', () => {
          const el = document.createElement('div');
          el.innerHTML = '<b></b>bar';

          const pos = new TextPosition(el.querySelector('b'), 0);
          const resolved = pos.resolve({ direction: RESOLVE_FORWARDS });

          assert.equal(resolved.node, el.childNodes[1]);
          assert.equal(resolved.offset, 0);
        });

        it('throws if there is no next text node', () => {
          const el = document.createElement('div');
          const pos = new TextPosition(el, 0);
          assert.throws(() => {
            pos.resolve({ direction: RESOLVE_FORWARDS });
          });
        });
      });

      describe('when `direction` is `RESOLVE_BACKWARDS`', () => {
        it('resolves to previous text node if needed', () => {
          const el = document.createElement('div');
          el.innerHTML = 'bar<b></b>';

          const pos = new TextPosition(el.querySelector('b'), 0);
          const resolved = pos.resolve({ direction: RESOLVE_BACKWARDS });

          assert.equal(resolved.node, el.childNodes[0]);
          assert.equal(resolved.offset, el.childNodes[0].data.length);
        });

        it('throws if there is no previous text node', () => {
          const el = document.createElement('div');
          const pos = new TextPosition(el, 0);
          assert.throws(() => {
            pos.resolve({ direction: RESOLVE_BACKWARDS });
          });
        });
      });
    });

    describe('#relativeTo', () => {
      it("throws an error if argument is not an ancestor of position's element", () => {
        const el = document.createElement('div');
        el.append('One');
        const pos = TextPosition.fromPoint(el.firstChild, 0);

        assert.throws(() => {
          pos.relativeTo(document.body);
        }, 'Parent is not an ancestor of current element');
      });

      it('returns a TextPosition with offset relative to the given parent', () => {
        const grandparent = document.createElement('div');
        const parent = document.createElement('div');
        const child = document.createElement('span');

        grandparent.append('a', parent);
        parent.append('bc', child);
        child.append('def');

        const childPos = TextPosition.fromPoint(child.firstChild, 3);

        const parentPos = childPos.relativeTo(parent);
        assert.equal(parentPos.element, parent);
        assert.equal(parentPos.offset, 5);

        const grandparentPos = childPos.relativeTo(grandparent);
        assert.equal(grandparentPos.element, grandparent);
        assert.equal(grandparentPos.offset, 6);
      });

      it('ignores text in comments and processing instructions', () => {
        const parent = document.createElement('div');
        const child = document.createElement('span');
        const comment = document.createComment('foobar');
        const piNode = document.createProcessingInstruction('one', 'two');
        child.append('def');
        parent.append(comment, piNode, child);

        const childPos = TextPosition.fromPoint(child.firstChild, 3);
        const parentPos = childPos.relativeTo(parent);

        assert.equal(parentPos.element, parent);
        assert.equal(parentPos.offset, 3);
      });
    });

    describe('fromCharOffset', () => {
      let el;
      beforeEach(() => {
        el = document.createElement('div');
        el.append('hello', 'world');
      });

      it('returns TextPosition for offset in Text node', () => {
        assert.deepEqual(
          TextPosition.fromCharOffset(el.firstChild, 1),
          TextPosition.fromPoint(el.firstChild, 1)
        );
      });

      it('returns TextPosition for offset in Element node', () => {
        assert.deepEqual(
          TextPosition.fromCharOffset(el, 5),
          new TextPosition(el, 5)
        );
      });

      it('throws for an offset in a non-Text/Element node', () => {
        const comment = document.createComment('This is a test');
        el.append(comment);

        assert.throws(() => {
          TextPosition.fromCharOffset(comment, 3);
        }, 'Node is not an element or text node');
      });
    });

    describe('fromPoint', () => {
      it('returns TextPosition for offset in Text node', () => {
        const el = document.createElement('div');
        el.append('One', 'two', 'three');

        const pos = TextPosition.fromPoint(el.childNodes[1], 0);

        assertNodesEqual(pos.element, el);
        assert.equal(pos.offset, el.textContent.indexOf('two'));
      });

      it('returns TextPosition for offset in Element node', () => {
        const el = document.createElement('div');
        el.innerHTML = '<b>foo</b><i>bar</i><u>baz</u>';

        const pos = TextPosition.fromPoint(el, 1);

        assertNodesEqual(pos.element, el);
        assert.equal(pos.offset, el.textContent.indexOf('bar'));
      });

      it('ignores text in comments and processing instructions', () => {
        const el = document.createElement('div');
        const comment = document.createComment('ignore me');
        const piNode = document.createProcessingInstruction('one', 'two');
        el.append(comment, piNode, 'foobar');

        const pos = TextPosition.fromPoint(el.childNodes[2], 3);

        assert.equal(pos.element, el);
        assert.equal(pos.offset, 3);
      });

      it('throws if node is not a Text or Element', () => {
        assert.throws(() => {
          TextPosition.fromPoint(document, 0);
        }, 'Point is not in an element or text node');
      });

      it('throws if Text node has no parent', () => {
        assert.throws(() => {
          TextPosition.fromPoint(document.createTextNode('foo'), 0);
        }, 'Text node has no parent');
      });

      it('throws if node is a Text node and offset is invalid', () => {
        const container = document.createElement('div');
        container.textContent = 'This is a test';
        assert.throws(() => {
          TextPosition.fromPoint(container.firstChild, 100);
        }, 'Text node offset is out of range');
      });

      it('throws if Node is an Element node and offset is invalid', () => {
        const container = document.createElement('div');
        const child = document.createElement('span');
        container.appendChild(child);
        assert.throws(() => {
          TextPosition.fromPoint(container, 2);
        }, 'Child node offset is out of range');
      });
    });
  });

  describe('TextRange', () => {
    describe('#toRange', () => {
      it('resolves start and end points in same element', () => {
        const el = document.createElement('div');
        el.textContent = 'one two three';

        const textRange = new TextRange(
          new TextPosition(el, 4),
          new TextPosition(el, 7)
        );
        const range = textRange.toRange();

        assert.equal(range.toString(), 'two');
      });

      it('resolves start and end points in same element but different text nodes', () => {
        const el = document.createElement('div');
        el.append('one', 'two', 'three');

        const textRange = new TextRange(
          new TextPosition(el, 0),
          new TextPosition(el, el.textContent.length)
        );
        const range = textRange.toRange();

        assert.equal(range.toString(), el.textContent);
      });

      it('resolves start and end points in same element with start > end', () => {
        const el = document.createElement('div');
        el.textContent = 'one two three';

        const textRange = new TextRange(
          new TextPosition(el, 7),
          new TextPosition(el, 4)
        );
        const range = textRange.toRange();

        assert.equal(range.startContainer, el.firstChild);
        assert.equal(range.startOffset, 4);
        assert.isTrue(range.collapsed);
      });

      it('resolves start and end points in different elements', () => {
        const parent = document.createElement('div');
        const firstChild = document.createElement('span');
        firstChild.append('foo');
        const secondChild = document.createElement('span');
        secondChild.append('bar');
        parent.append(firstChild, secondChild);

        const textRange = new TextRange(
          new TextPosition(firstChild, 0),
          new TextPosition(secondChild, 3)
        );
        const range = textRange.toRange();

        assert.equal(range.toString(), 'foobar');
      });

      it('throws if start point in same element as end point cannot be resolved', () => {
        const el = document.createElement('div');
        el.textContent = 'one two three';

        const textRange = new TextRange(
          new TextPosition(el, 100),
          new TextPosition(el, 5)
        );

        assert.throws(() => {
          textRange.toRange();
        }, 'Offset exceeds text length');
      });

      it('throws if end point in same element as start point cannot be resolved', () => {
        const el = document.createElement('div');
        el.textContent = 'one two three';

        const textRange = new TextRange(
          new TextPosition(el, 5),
          new TextPosition(el, 100)
        );

        assert.throws(() => {
          textRange.toRange();
        }, 'Offset exceeds text length');
      });

      it('handles start or end point in element with no text', () => {
        const el = document.createElement('div');
        el.innerHTML = '<b></b><i>Foobar</i><u></u>';

        const textRange = new TextRange(
          new TextPosition(el.querySelector('b'), 0),
          new TextPosition(el.querySelector('u'), 0)
        );
        const range = textRange.toRange();

        assert.equal(range.toString(), 'Foobar');

        // Start position is not in `textRange.start.element` but the subsequent
        // text node.
        assert.isTrue(
          range.startContainer === el.querySelector('i').firstChild
        );
        // End position is not in `textRange.end.element` but the preceding
        // text node.
        assert.isTrue(range.endContainer === el.querySelector('i').firstChild);
      });
    });

    describe('#relativeTo', () => {
      it('returns a range with start and end positions relative to the given element', () => {
        const parent = document.createElement('div');
        const firstChild = document.createElement('span');
        firstChild.append('foo');
        const secondChild = document.createElement('span');
        secondChild.append('bar');
        parent.append(firstChild, secondChild);

        const textRange = new TextRange(
          new TextPosition(firstChild, 0),
          new TextPosition(secondChild, 3)
        );
        const parentRange = textRange.relativeTo(parent);

        assert.equal(parentRange.start.element, parent);
        assert.equal(parentRange.start.offset, 0);
        assert.equal(parentRange.end.element, parent);
        assert.equal(parentRange.end.offset, 6);
      });
    });

    describe('fromRange', () => {
      it('sets `start` and `end` points of range', () => {
        const el = document.createElement('div');
        el.textContent = 'one two three';

        const range = new Range();
        range.selectNodeContents(el);

        const textRange = TextRange.fromRange(range);

        assert.equal(textRange.start.element, el);
        assert.equal(textRange.start.offset, 0);
        assert.equal(textRange.end.element, el);
        assert.equal(textRange.end.offset, el.textContent.length);
      });

      it('throws if start or end points cannot be converted to a position', () => {
        const range = new Range();
        assert.throws(() => {
          TextRange.fromRange(range);
        }, 'Point is not in an element or text node');
      });
    });

    describe('fromOffsets', () => {
      it('returns a `TextRange` with correct start and end', () => {
        const root = document.createElement('div');
        root.append('Some text content');

        const textRange = TextRange.fromOffsets(root, 0, 10);

        assert.equal(textRange.start.element, root);
        assert.equal(textRange.start.offset, 0);
        assert.equal(textRange.end.element, root);
        assert.equal(textRange.end.offset, 10);
      });
    });
  });
});
