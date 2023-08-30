# Dealing with Languages/scripts

You’ll find default stylesheets at the root of this folder, and languages/script-specific ones in their dedicated folder.

This is a temporary solution to a complex issue (i18n), which is aligned with our current implementation so that we can start testing those specific styles as soon as possible. 

## Right to Left

If the publication has:

- a `page-progression-direction` with the value set to `rtl`;
- and language is either Arabic (`ar`), Farsi (`fa`) or Hebrew (`he`).

Then stylesheets in the `rtl` folder should be used.

It is also important the `dir` attribute and `xml:lang` be appended to the `html` element of each document if needed.

Finally, page progression is impacted: 

- previous page is `right`;
- next page is `left`.

### User settings

Disabled user settings: 

- `hyphens`;
- `word-spacing`;
- `letter-spacing`.

Added user settings:

- `font-variant-ligatures` (mapped to `--USER__ligatures` CSS variable).

## CJK

Chinese, Japanese, Korean, and Mongolian can be either written `horizontal-tb` or `vertical-*`. Consequently, there are stylesheets for horizontal and vertical writing modes.

### Horizontal

If the publication has: 

- a `page-progression-direction` with the value set to `ltr` – or no attribute –;
- and (at least one) language item is either Chinese (`zh`), Japanese (`ja`), or Korean (`ko`).

Then stylesheets in the `cjk/horizontal` subfolder should be used.

It is also important the `xml:lang` be appended to the `html` element of each document if needed.

#### User settings

Disabled user settings: 

- `text-align`;
- `hyphens`;
- paragraphs’ indent;
- `word-spacing`;
- `letter-spacing`.

### Vertical

If the publication has: 

- a `page-progression-direction` with the value set to `rtl`;
- and (at least one) language item is either Chinese (`zh`), Japanese (`ja`), or Korean (`ko`).

Then stylesheets in the `cjk/vertical` subfolder should be used.

It is also important the `xml:lang` be appended to the `html` element of each document if needed. You MUST NOT append a `dir` attribute.

Please note the `vertical-rl` writing mode will be enforced in this case.

Finally, page progression is impacted: 

- previous page (`right`) goes up;
- next page (`left`) goes down.

This means that taps/swipes should behave as usual in horizontal writing i.e. `x-axis` but the app programmatically handles the progression on the `y-axis`. You might therefore want to disable page-transition animations in this case.

This is consistent with the Readium 1 implementation so the same logic can apply.

#### User settings

Disabled user settings: 

- `column-count` (number of columns);
- `text-align`;
- `hyphens`;
- paragraphs’ indent;
- `word-spacing`;
- `letter-spacing`.

### EBPAJ Polyfill

The EBPAJ template only references fonts from MS Windows so we must reference fonts from other platforms and override authors’ stylesheets. What we do in this polyfill is keeping their default value and providing fallbacks.

You might want to load this polyfill (at the end, after `ReadiumCSS-after-cjk(-*)?.css`) only if you find one of the following metadata items in the OPF package:

- version 1: `<dc:description id="ebpaj-guide">ebpaj-guide-1.0</dc:description>`
- version 1.1: `<meta property="ebpaj:guide-version">1.1</meta>`

Since we must use `@font-face` to align with their specific implementation (we have to go through 9–11 `local` sources in the worst-case scenario), expect a “rendering debt” though. Do not hesitate to report performance issues for this polyfill.

### Mongolian

This is currently an edge case as we still have to see whether we want to support it and how we can support it. Indeed, the situation is the following:

- Traditional is written `vertical-lr` so we can’t use `page-progression-direction` as an hint, and we must check if the language item (`mn`) is enough:
    - if `mn-Mong` is set, then `vertical-lr` must be used;
    - if `mn-Cyrl` is set, then the publication is in cyrillic and it is `horizontal-tb`.
- We don’t currently support the `mn` language, and we can’t rely on system fonts to do so, we’ll have to embed one.

