import { nodeFromXPath, xpathFromNode } from '../xpath';

describe('annotator/anchoring/xpath', () => {
  describe('xpathFromNode', () => {
    let container;
    const html = `
        <h1 id="h1-1">text</h1>
        <p id="p-1">text<br/><br/><a id="a-1">text</a></p>
        <p id="p-2">text<br/><em id="em-1"><br/>text</em>text</p>
        <span>
          <ul>
            <li id="li-1">text1</li>
            <li id="li-2">text</li>
            <li id="li-3">text</li>
          </ul>
        </span>`;

    beforeEach(() => {
      container = document.createElement('div');
      container.innerHTML = html;
      document.body.appendChild(container);
    });

    afterEach(() => {
      container.remove();
    });

    it('throws an error if the provided node is not a descendant of the root node', () => {
      const node = document.createElement('p'); // not attached to DOM
      assert.throws(() => {
        xpathFromNode(node, document.body);
      }, 'Node is not a descendant of root');
    });

    [
      {
        id: 'a-1',
        xpaths: ['/div[1]/p[1]/a[1]', '/div[1]/p[1]/a[1]/text()[1]'],
      },
      {
        id: 'h1-1',
        xpaths: ['/div[1]/h1[1]', '/div[1]/h1[1]/text()[1]'],
      },
      {
        id: 'p-1',
        xpaths: ['/div[1]/p[1]', '/div[1]/p[1]/text()[1]'],
      },
      {
        id: 'a-1',
        xpaths: ['/div[1]/p[1]/a[1]', '/div[1]/p[1]/a[1]/text()[1]'],
      },
      {
        id: 'p-2',
        xpaths: [
          '/div[1]/p[2]',
          '/div[1]/p[2]/text()[1]',
          '/div[1]/p[2]/text()[2]',
        ],
      },
      {
        id: 'em-1',
        xpaths: ['/div[1]/p[2]/em[1]', '/div[1]/p[2]/em[1]/text()[1]'],
      },
      {
        id: 'li-3',
        xpaths: [
          '/div[1]/span[1]/ul[1]/li[3]',
          '/div[1]/span[1]/ul[1]/li[3]/text()[1]',
        ],
      },
    ].forEach(test => {
      it('produces the correct xpath for the provided node', () => {
        let node = document.getElementById(test.id);
        assert.equal(xpathFromNode(node, document.body), test.xpaths[0]);
      });

      it('produces the correct xpath for the provided text node(s)', () => {
        let node = document.getElementById(test.id).firstChild;
        // collect all text nodes after the target queried node.
        const textNodes = [];
        while (node) {
          if (node.nodeType === Node.TEXT_NODE) {
            textNodes.push(node);
          }
          node = node.nextSibling;
        }
        textNodes.forEach((node, index) => {
          assert.equal(
            xpathFromNode(node, document.body),
            test.xpaths[index + 1]
          );
        });
      });
    });
  });

  describe('nodeFromXPath', () => {
    let container;
    const html = `
        <h1 id="h1-1">text</h1>
        <p id="p-1">text<br/><br/><a id="a-1">text</a></p>
        <p id="p-2">text<br/><em id="em-1"><br/>text</em>text</p>
        <span>
          <ul>
            <li id="li-1">text 1</li>
            <li id="li-2">text 2</li>
            <li id="li-3">text 3</li>
            <custom-element>text 4</custom-element>
          </ul>
          <math xmlns="http://www.w3.org/1998/Math/MathML">
            <msqrt><mrow><mi>x</mi><mo>+</mo><mn>1</mn></mrow></msqrt>
          </math>
          <svg viewBox="0 0 240 80" xmlns="http://www.w3.org/2000/svg">
            <text x="20" y="35">Hello</text>
            <text x="40" y="35">world</text>
          </svg>
        </span>`;

    beforeEach(() => {
      container = document.createElement('div');
      container.innerHTML = html;
      document.body.appendChild(container);

      sinon.spy(document, 'evaluate');
    });

    afterEach(() => {
      document.evaluate.restore();

      container.remove();
    });

    [
      // Single element path
      {
        xpath: '/h1[1]',
        nodeName: 'H1',
      },
      // Multi-element path
      {
        xpath: '/p[1]/a[1]',
        nodeName: 'A',
      },
      {
        xpath: '/span[1]/ul[1]/li[2]',
        nodeName: 'LI',
      },
      // Upper-case element names
      {
        xpath: '/SPAN[1]/UL[1]/LI[2]',
        nodeName: 'LI',
      },
      // Element path with implicit `[1]` index
      {
        xpath: '/h1',
        nodeName: 'H1',
      },
      // Custom element
      {
        xpath: '/span/ul/custom-element',
        nodeName: 'CUSTOM-ELEMENT',
      },
      // Embedded MathML
      {
        xpath: '/span/math/msqrt/mrow/mi',
        nodeName: 'mi',
      },
      {
        xpath: '/SPAN/MATH/MSQRT/MROW/MI',
        nodeName: 'mi',
      },
      // Embedded SVG
      {
        xpath: '/span[1]/svg[1]/text[2]',
        nodeName: 'text',
      },
    ].forEach(test => {
      it('evaluates simple XPaths without using `document.evaluate`', () => {
        const result = nodeFromXPath(test.xpath, container);
        assert.notCalled(document.evaluate);
        assert.equal(result?.nodeName, test.nodeName);
      });
    });

    ['/missing/element', '/span[0]'].forEach(xpath => {
      it('returns `null` if simple XPath evaluation fails', () => {
        const result = nodeFromXPath(xpath, container);
        assert.notCalled(document.evaluate);
        assert.strictEqual(result, null);
      });
    });

    [
      ['/*[local-name()="h1"]', 'H1'],
      ['/span[-1]', null],
    ].forEach(([xpath, expectedNodeName]) => {
      it('uses `document.evaluate` for non-simple XPaths', () => {
        const result = nodeFromXPath(xpath, container);
        assert.calledOnce(document.evaluate);
        assert.strictEqual(result?.nodeName ?? result, expectedNodeName);
      });
    });

    ['not-a-valid-xpath'].forEach(xpath => {
      it('throws if XPath is invalid', () => {
        assert.throws(() => {
          nodeFromXPath(xpath, container);
        }, /The string '.*' is not a valid XPath expression/);
      });
    });
  });
});
