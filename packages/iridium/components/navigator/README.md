# mno_navigator_flutter

A Flutter "publication navigator" freely inspired by
the [Readium 2 Navigator](https://readium.org/technical/r2-navigator-architecture/).

## Features

- [x] EPUB 2.x and 3.x support
- [ ] Audiobook support
- [ ] PDF support
- [x] CBZ support
- [x] Custom styles
- [x] Night & sepia modes
- [x] Pagination
- [ ] Scrolling
- [x] Table of contents
- [ ] FXL support
- [x] RTL support
- [ ] Search in EPUB
- [ ] Highlights/annotations
- [ ] TTS
- [ ] EPUB 3 Media Overlays
- [ ] Divina support

## Current technical choices

### Epub reflow pagination strategy

For the current implementation, we have chosen to follow a different route, compared to R2:

- 1 webview per spine item
- webviews embedded in a PreloadPageView
- we simply fix the height of the containing div, which causes the contents to overflow in columns, horizontally
- one a spine item is rendered, we overlay divs on top of each page
- CSS scroll-snap on each of these overlay divs provides straightforward page alignment after swiping
- intersection observers allow tracking the current page and allows routing swipe gestures either to the webview or
  to the PageView

There are pros and cons to this approach. But the main UX advantage is that swiping between spine items is smooth (
both spine items are visible at the same time, exactly like when swiping between pages inside a spine item).

At this point a few visual glitches still remain to be fixed.

### WebViews used to display Epub spine items

For now, we are using [webview_flutter](https://pub.dev/packages/webview_flutter) 3.x, which relies on Android WebView
and iOS WkWebView. 

Note: In the current version, there is a small visual glitch on Android when displaying the navigation panel: the webview briefly 
reappears and flashes on top, before leaving the navigation panel visible. This is a 
[Flutter issue](https://github.com/flutter/flutter/issues/95343), and will be fixed in Flutter SDK 2.10._

At some point we could consider replacing [webview_flutter](https://pub.dev/packages/webview_flutter)
by [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview), that we already use for other purposes.

## Note

While it is inspired by the platform-specific implementations provided by Readium 2, this Flutter implementation makes a
few different choices. One of the main differences is the pagination and page-turn implementation strategies. 
