import {
  createPlaceholder,
  hasPlaceholder,
  isInPlaceholder,
  removePlaceholder,
} from '../placeholder';

describe('annotator/anchoring/placeholder', () => {
  describe('createPlaceholder', () => {
    it('adds a placeholder element to the container', () => {
      const container = document.createElement('div');
      const placeholder = createPlaceholder(container);

      assert.ok(placeholder);
      assert.equal(
        container.querySelector('.annotator-placeholder'),
        placeholder
      );
    });

    it('returns the existing placeholder if present', () => {
      const container = document.createElement('div');
      const placeholderA = createPlaceholder(container);
      const placeholderB = createPlaceholder(container);

      assert.equal(placeholderA, placeholderB);
    });
  });

  describe('removePlaceholder', () => {
    it('removes the placeholder if present', () => {
      const container = document.createElement('div');
      createPlaceholder(container);

      assert.isTrue(hasPlaceholder(container));
      removePlaceholder(container);
      assert.isFalse(hasPlaceholder(container));
    });

    it('does nothing if placeholder is not present', () => {
      const container = document.createElement('div');
      removePlaceholder(container);
      removePlaceholder(container);
    });
  });

  describe('isInPlaceholder', () => {
    it('returns true if node is inside a placeholder', () => {
      const container = document.createElement('div');
      const placeholder = createPlaceholder(container);
      const child = document.createElement('div');
      placeholder.append(child);

      assert.isTrue(isInPlaceholder(child));
    });

    it('returns false if node is not inside a placeholder', () => {
      assert.isFalse(isInPlaceholder(document.body));
    });

    it('returns false if node has no parent', () => {
      const el = document.createElement('div');
      assert.isFalse(isInPlaceholder(el));
    });
  });
});
