import { matchQuote } from '../match-quote';

const fixtures = {
  solitude: `Many years later, as he faced the firing squad,
    Colonel Aureliano Buendía was to remember that distant afternoon
    when his father took him to discover ice`,

  twoCities: `It was the best of times, it was the worst of times,
    it was the age of wisdom, it was the age of foolishness, it was the epoch of belief,
    it was the epoch of incredulity, it was the season of Light, it was the
    season of Darkness, it was the spring of hope, it was the winter of despair, we had
    everything before us, we had nothing before us, we were all going direct to Heaven,
    we were all going direct the other way.`,
};

function normalize(str) {
  // Normalize whitespace.
  return str.replace(/\s+/g, ' ');
}

Object.keys(fixtures).forEach(k => (fixtures[k] = normalize(fixtures[k])));

describe('matchQuote', () => {
  it('finds exact match', () => {
    const match = matchQuote(fixtures.solitude, 'discover ice');
    assert.equal(match.score, 1.0);
    assert.equal(
      fixtures.solitude.slice(match.start, match.end),
      'discover ice'
    );
  });

  it('finds best approximate match if there is no exact match', () => {
    const match = matchQuote(fixtures.solitude, 'some years later');
    assert.isTrue(match.score > 0);
    assert.isTrue(match.score < 1);
    assert.equal(
      fixtures.solitude.slice(match.start, match.end),
      'Many years later'
    );
  });

  it('scores matches based on quote similarity', () => {
    // List of quotes in descending order of similarity to the text.
    const quotes = [
      'Many years later',
      'Many yers later',
      'Some years later',
      'Some years after',
    ];

    const scores = quotes.map(q => matchQuote(fixtures.solitude, q).score);

    for (let i = 1; i < scores.length; i++) {
      assert.isBelow(scores[i], scores[i - 1]);
    }
  });

  it('scores matches based on prefix similarity', () => {
    // List of prefixes in descending order of similarity to the actual prefix
    // of the quote.
    const prefixes = [
      'Many years later',
      'Many yers later',
      'Some years later',
      'Some years after',
    ];

    const quote = ', as he faced the firing squad';
    const scores = prefixes.map(
      p => matchQuote(fixtures.solitude, quote, { prefix: p }).score
    );

    for (let i = 1; i < scores.length; i++) {
      assert.isBelow(scores[i], scores[i - 1]);
    }
  });

  it('scores matches based on suffix similarity', () => {
    // List of suffixes in descending order of similarity to the actual suffix
    // of the quote.
    const suffixes = [
      ', as he faced the firing squad',
      ', as she faced the firing squad',
      ', as he awaited the firing squad',
      ', as he awaited his death',
    ];

    const quote = 'Many years later';
    const scores = suffixes.map(
      s => matchQuote(fixtures.solitude, quote, { suffix: s }).score
    );

    for (let i = 1; i < scores.length; i++) {
      assert.isBelow(scores[i], scores[i - 1]);
    }
  });

  it('returns `null` if there is no acceptable approximate match', () => {
    const match = matchQuote(fixtures.twoCities, fixtures.solitude);
    assert.equal(match, null);
  });

  it('returns `null` if quote is empty', () => {
    assert.equal(matchQuote('foobar', ''), null);
  });

  it('returns `null` if text is empty', () => {
    assert.equal(matchQuote('', 'foobar'), null);
  });

  [
    // Exact prefix matches.
    {
      quote: 'before us',
      prefix: 'we had everything',
      expected: 'before us, we had nothing',
    },
    {
      quote: 'before us',
      prefix: 'we had nothing',
      expected: 'before us, we were all going',
    },

    // Approximate prefix matches.
    {
      quote: 'before us',
      prefix: 'we had every-thing',
      expected: 'before us, we had nothing',
    },
    {
      quote: 'before us',
      prefix: 'we had nout',
      expected: 'before us, we were all going',
    },

    // Exact suffix matches.
    {
      quote: 'we had',
      suffix: 'everything',
      expected: 'we had everything',
    },
    {
      quote: 'we had',
      suffix: 'nothing',
      expected: 'we had nothing',
    },

    // Approximate suffix matches.
    {
      quote: 'we had',
      suffix: 'ever ting',
      expected: 'we had everything',
    },
    {
      quote: 'we had',
      suffix: 'nutting',
      expected: 'we had nothing',
    },
  ].forEach(({ quote, prefix, suffix, expected }, i) => {
    it(`finds match with best context match (${i})`, () => {
      const text = fixtures.twoCities;
      const match = matchQuote(text, quote, {
        prefix,
        suffix,
      });
      assert.ok(match);
      assert.equal(text.slice(match.start, match.end), quote);
      assert.equal(match.start, text.indexOf(expected));
    });
  });

  it('uses `hint` as a tie-breaker to choose between matches with close scores', () => {
    const text = fixtures.twoCities;
    const posA = text.indexOf('everything before us') + 'everything '.length;
    const posB = text.indexOf('nothing before us') + 'nothing '.length;

    // Search for a quote that appears multiple times in the text. Since no
    // context is provided, there will be several matches with equal scores to
    // choose between.
    const matchHintA = matchQuote(text, 'befor us', { hint: posA });
    const matchHintB = matchQuote(text, 'befor us', { hint: posB });
    const matchNoHint = matchQuote(text, 'befor us');

    // When a hint is provided, `matchQuote` should choose between otherwise
    // equal matches based on how close the match start is to `hint`.
    assert.ok(matchHintA);
    assert.equal(matchHintA.start, posA, 'Wrong match for hint `posA`');

    assert.ok(matchHintB);
    assert.equal(matchHintB.start, posB, 'Wrong match for hint `posB`');

    // When no hint is provided, the first match (ie. lowest `match.start`)
    // should be chosen.
    assert.ok(matchNoHint);
    assert.equal(matchNoHint.start, posA, 'Wrong match with no hint');
  });
});
