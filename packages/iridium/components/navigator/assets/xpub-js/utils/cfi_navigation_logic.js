
var CfiNavigationLogic = function($viewport, options){

    var $document = $(document);

    this.options = options || {};

    var visibilityCheckerFunc = options.rectangleBased
        ? checkVisibilityByRectangles
        : checkVisibilityByVerticalOffsets;

    /**
     * @private
     * Checks whether or not pages are rendered right-to-left
     *
     * @returns {boolean}
     */
    function isPageProgressionRightToLeft() {
        return options.paginationInfo && !!options.paginationInfo.rightToLeft;
    }

    /**
     * @private
     * Checks whether or not pages are rendered with vertical writing mode
     *
     * @returns {boolean}
     */
    function isVerticalWritingMode() {
        return options.paginationInfo && !!options.paginationInfo.isVerticalWritingMode;
    }


    /**
     * @private
     * Checks whether or not a (fully adjusted) rectangle is at least partly visible
     *
     * @param {Object} rect
     * @param {Object} frameDimensions
     * @param {boolean} [isVwm]           isVerticalWritingMode
     * @returns {boolean}
     */
    function isRectVisible(rect, frameDimensions, isVwm) {
        if (isVwm) {
            return rect.top >= 0 && rect.top < frameDimensions.height;
        }
        return rect.left >= 0 && rect.left < frameDimensions.width;
    }

    this.getRootElement = function(){

        return (window.document != null) ? window.document.documentElement : null;
    };


    // Old (offsetTop-based) algorithm, useful in top-to-bottom layouts
    function checkVisibilityByVerticalOffsets(
            $element, visibleContentOffsets, shouldCalculateVisibilityOffset) {

        var elementRect = Helpers.Rect.fromElement($element);
        var viewportHeight = $viewport.height() - 2 * xpub.theme.verticalMargin;
        var page = elementRect.top / viewportHeight;
        elementRect.top = elementRect.top + 2 * page * xpub.theme.verticalMargin;
        if (_.isNaN(elementRect.left)) {
            // this is actually a point element, doesnt have a bounding rectangle
            elementRect = new Helpers.Rect(
                    $element.position().top, $element.position().left, 0, 0);
        }
        var topOffset = visibleContentOffsets.top || 0;
        var isBelowVisibleTop = elementRect.bottom() > topOffset;
        var isAboveVisibleBottom = visibleContentOffsets.bottom !== undefined
            ? elementRect.top < visibleContentOffsets.bottom
            : true; //this check always passed, if corresponding offset isn't set

        var percentOfElementHeight = 0;
        if (isBelowVisibleTop && isAboveVisibleBottom) { // element is visible
            if (!shouldCalculateVisibilityOffset) {
                return 100;
            }
            else if (elementRect.top <= topOffset) {
                percentOfElementHeight = Math.ceil(
                    100 * (topOffset - elementRect.top) / elementRect.height
                );

                // below goes another algorithm, which has been used in getVisibleElements pattern,
                // but it seems to be a bit incorrect
                // (as spatial offset should be measured at the first visible point of the element):
                //
                // var visibleTop = Math.max(elementRect.top, visibleContentOffsets.top);
                // var visibleBottom = Math.min(elementRect.bottom(), visibleContentOffsets.bottom);
                // var visibleHeight = visibleBottom - visibleTop;
                // var percentVisible = Math.round((visibleHeight / elementRect.height) * 100);
            }
            return 100 - percentOfElementHeight;
        }
        return 0; // element isn't visible
    }

    /**
     * @private
     *
     * Retrieves _current_ offset of a viewport
     * (related to the beginning of the chapter)
     *
     * @returns {Object}
     */
    function getVisibleContentOffsets() {
        if(isVerticalWritingMode()){
            return {
                top: (options.paginationInfo ? options.paginationInfo.pageOffset : 0)
            };
        }
        return {
            left: (options.paginationInfo ? options.paginationInfo.pageOffset : 0)
                * (isPageProgressionRightToLeft() ? -1 : 1)
        };
    }

    /**
     * New (rectangle-based) algorithm, useful in multi-column layouts
     *
     * Note: the second param (props) is ignored intentionally
     * (no need to use those in normalization)
     *
     * @param {jQuery} $element
     * @param {Object} _props
     * @param {boolean} shouldCalculateVisibilityPercentage
     * @returns {number|null}
     *      0 for non-visible elements,
     *      0 < n <= 100 for visible elements
     *      (will just give 100, if `shouldCalculateVisibilityPercentage` => false)
     *      null for elements with display:none
     */
    function checkVisibilityByRectangles(
            $element, _props, shouldCalculateVisibilityPercentage) {

        var elementRectangles = getNormalizedRectangles($element);
        var clientRectangles = elementRectangles.clientRectangles;
        if (clientRectangles.length === 0) { // elements with display:none, etc.
            return null;
        }

        var isRtl = isPageProgressionRightToLeft();
        var isVwm = isVerticalWritingMode();
        var columnFullWidth = getColumnFullWidth();
        var frameDimensions = {
            width: $document.width(),
            height: $document.height()
        };

        if (clientRectangles.length === 1) {
            // because of webkit inconsistency, that single rectangle should be adjusted
            // until it hits the end OR will be based on the FIRST column that is visible
            adjustRectangle(clientRectangles[0], frameDimensions, columnFullWidth,
                    isRtl, isVwm, true);
        }

        // for an element split between several CSS columns,
        // both Firefox and IE produce as many client rectangles;
        // each of those should be checked
        var visibilityPercentage = 0;
        for (var i = 0, l = clientRectangles.length; i < l; ++i) {
            if (isRectVisible(clientRectangles[i], frameDimensions, isVwm)) {
                visibilityPercentage = shouldCalculateVisibilityPercentage
                    ? measureVisibilityPercentageByRectangles(clientRectangles, i)
                    : 100;
                break;
            }
        }
        return visibilityPercentage;
    }

    /**
     * @private
     * Calculates the visibility offset percentage based on ClientRect dimensions
     *
     * @param {Array} clientRectangles (should already be normalized)
     * @param {number} firstVisibleRectIndex
     * @returns {number} - visibility percentage (0 < n <= 100)
     */
    function measureVisibilityPercentageByRectangles(
            clientRectangles, firstVisibleRectIndex) {

        var heightTotal = 0;
        var heightVisible = 0;

        if (clientRectangles.length > 1) {
            _.each(clientRectangles, function(rect, index) {
                heightTotal += rect.height;
                if (index >= firstVisibleRectIndex) {
                    // in this case, all the rectangles after the first visible
                    // should be counted as visible
                    heightVisible += rect.height;
                }
            });
        }
        else {
            // should already be normalized and adjusted
            heightTotal   = clientRectangles[0].height;
            heightVisible = clientRectangles[0].height - Math.max(
                    0, -clientRectangles[0].top);
        }
        return heightVisible === heightTotal
            ? 100 // trivial case: element is 100% visible
            : Math.floor(100 * heightVisible / heightTotal);
    }

    /**
     * Finds a page index (0-based) for a specific element.
     * Calculations are based on rectangles retrieved with getClientRects() method.
     *
     * @param {jQuery} $element
     * @param {number} spatialVerticalOffset
     * @returns {number|null}
     */
    function findPageByRectangles($element, spatialVerticalOffset) {
        var visibleContentOffsets = getVisibleContentOffsets();
        var elementRectangles = getNormalizedRectangles($element, visibleContentOffsets);
        var clientRectangles  = elementRectangles.clientRectangles;
        if (clientRectangles.length === 0) { // elements with display:none, etc.
            return null;
        }

        var isRtl = isPageProgressionRightToLeft();
        var isVwm = isVerticalWritingMode();
        var columnFullWidth = getColumnFullWidth();

        var frameHeight = $document.height();
        var frameWidth  = $document.width();

        if (spatialVerticalOffset) {
            trimRectanglesByVertOffset(clientRectangles, spatialVerticalOffset,
                frameHeight, columnFullWidth, isRtl, isVwm);
        }

        var firstRectangle = clientRectangles[0];
        if (clientRectangles.length === 1) {
            adjustRectangle(firstRectangle, {
                height: frameHeight, width: frameWidth
            }, columnFullWidth, isRtl, isVwm);
        }

        var pageIndex;

        if (isVwm) {
            var topOffset = firstRectangle.top;
            pageIndex = Math.floor(topOffset / frameHeight);
        } else {
            var leftOffset = firstRectangle.left;
            if (isRtl) {
                leftOffset = (columnFullWidth * (options.paginationInfo ? options.paginationInfo.visibleColumnCount : 1)) - leftOffset;
            }
            pageIndex = Math.floor(leftOffset / columnFullWidth);
        }

        if (pageIndex < 0) {
            pageIndex = 0;
        }
        else if (pageIndex >= (options.paginationInfo ? options.paginationInfo.columnCount : 1)) {
            pageIndex = (options.paginationInfo ? (options.paginationInfo.columnCount - 1) : 0);
        }

        return pageIndex;
    }

    /**
     * @private
     * Retrieves the position of $element in multi-column layout
     *
     * @param {jQuery} $el
     * @param {Object} [visibleContentOffsets]
     * @returns {Object}
     */
    function getNormalizedRectangles($el, visibleContentOffsets) {

        visibleContentOffsets = visibleContentOffsets || {};
        var leftOffset = visibleContentOffsets.left || 0;
        var topOffset  = visibleContentOffsets.top  || 0;

        // union of all rectangles wrapping the element
        var wrapperRectangle = normalizeRectangle(
                $el[0].getBoundingClientRect(), leftOffset, topOffset);

        // all the separate rectangles (for detecting position of the element
        // split between several columns)
        var clientRectangles = [];
        var clientRectList = $el[0].getClientRects();
        for (var i = 0, l = clientRectList.length; i < l; ++i) {
            if (clientRectList[i].height > 0) {
                // Firefox sometimes gets it wrong,
                // adding literally empty (height = 0) client rectangle preceding the real one,
                // that empty client rectanle shouldn't be retrieved
                clientRectangles.push(
                    normalizeRectangle(clientRectList[i], leftOffset, topOffset));
            }
        }

        if (clientRectangles.length === 0) {
            // sometimes an element is either hidden or empty, and that means
            // Webkit-based browsers fail to assign proper clientRects to it
            // in this case we need to go for its sibling (if it exists)
            $el = $el.next();
            if ($el.length) {
                return getNormalizedRectangles($el, visibleContentOffsets);
            }
        }

        return {
            wrapperRectangle: wrapperRectangle,
            clientRectangles: clientRectangles
        };
    }

    /**
     * @private
     * Converts TextRectangle object into a plain object,
     * taking content offsets (=scrolls, position shifts etc.) into account
     *
     * @param {TextRectangle} textRect
     * @param {number} leftOffset
     * @param {number} topOffset
     * @returns {Object}
     */
    function normalizeRectangle(textRect, leftOffset, topOffset) {

        var plainRectObject = {
            left: textRect.left,
            right: textRect.right,
            top: textRect.top,
            bottom: textRect.bottom,
            width: textRect.right - textRect.left,
            height: textRect.bottom - textRect.top
        };
        offsetRectangle(plainRectObject, leftOffset, topOffset);
        return plainRectObject;
    }

    /**
     * @private
     * Offsets plain object (which represents a TextRectangle).
     *
     * @param {Object} rect
     * @param {number} leftOffset
     * @param {number} topOffset
     */
    function offsetRectangle(rect, leftOffset, topOffset) {

        rect.left   += leftOffset;
        rect.right  += leftOffset;
        rect.top    += topOffset;
        rect.bottom += topOffset;
    }

    /**
     * @private
     * Retrieves _current_ full width of a column (including its gap)
     *
     * @returns {number} Full width of a column in pixels
     */
    function getColumnFullWidth() {
        
        if (!options.paginationInfo || isVerticalWritingMode())
        {
            return $document.width();
        }
        
        return options.paginationInfo.columnWidth + options.paginationInfo.columnGap;
    }

    /**
     * @private
     *
     * When element is spilled over two or more columns,
     * most of the time Webkit-based browsers
     * still assign a single clientRectangle to it, setting its `top` property to negative value
     * (so it looks like it's rendered based on the second column)
     * Alas, sometimes they decide to continue the leftmost column - from _below_ its real height.
     * In this case, `bottom` property is actually greater than element's height and had to be adjusted accordingly.
     *
     * Ugh.
     *
     * @param {Object} rect
     * @param {Object} frameDimensions
     * @param {number} columnFullWidth
     * @param {boolean} isRtl
     * @param {boolean} isVwm               isVerticalWritingMode
     * @param {boolean} shouldLookForFirstVisibleColumn
     *      If set, there'll be two-phase adjustment
     *      (to align a rectangle with a viewport)

     */
    function adjustRectangle(rect, frameDimensions, columnFullWidth, isRtl, isVwm,
            shouldLookForFirstVisibleColumn) {

        // Rectangle adjustment is not needed in VWM since it does not deal with columns
        if (isVwm) {
            return;
        }

        if (isRtl) {
            columnFullWidth *= -1; // horizontal shifts are reverted in RTL mode
        }

        // first we go left/right (rebasing onto the very first column available)
        while (rect.top < 0) {
            offsetRectangle(rect, -columnFullWidth, frameDimensions.height);
        }

        // ... then, if necessary (for visibility offset checks),
        // each column is tried again (now in reverse order)
        // the loop will be stopped when the column is aligned with a viewport
        // (i.e., is the first visible one).
        if (shouldLookForFirstVisibleColumn) {
            while (rect.bottom >= frameDimensions.height) {
                if (isRectVisible(rect, frameDimensions, isVwm)) {
                    break;
                }
                offsetRectangle(rect, columnFullWidth, -frameDimensions.height);
            }
        }
    }

    /**
     * @private
     * Trims the rectangle(s) representing the given element.
     *
     * @param {Array} rects
     * @param {number} verticalOffset
     * @param {number} frameHeight
     * @param {number} columnFullWidth
     * @param {boolean} isRtl
     * @param {boolean} isVwm               isVerticalWritingMode
     */
    function trimRectanglesByVertOffset(
            rects, verticalOffset, frameHeight, columnFullWidth, isRtl, isVwm) {

        //TODO: Support vertical writing mode
        if (isVwm) {
            return;
        }
        
        var totalHeight = _.reduce(rects, function(prev, cur) {
            return prev + cur.height;
        }, 0);

        var heightToHide = totalHeight * verticalOffset / 100;
        if (rects.length > 1) {
            var heightAccum = 0;
            do {
                heightAccum += rects[0].height;
                if (heightAccum > heightToHide) {
                    break;
                }
                rects.shift();
            } while (rects.length > 1);
        }
        else {
            // rebase to the last possible column
            // (so that adding to top will be properly processed later)
            if (isRtl) {
                columnFullWidth *= -1;
            }
            while (rects[0].bottom >= frameHeight) {
                offsetRectangle(rects[0], columnFullWidth, -frameHeight);
            }

            rects[0].top += heightToHide;
            rects[0].height -= heightToHide;
        }
    }

    this.getPageForElementCfi = function(cfi, classBlacklist, elementBlacklist, idBlacklist) {
        // START Mantano (Yonathan, Mickaël)
        var cfiObject = MNOCFI.fromElementCFI(cfi);
        if (cfiObject) {
            var bounds = cfiObject.getBoundingClientRectInDocument();
            if (bounds) {
                var viewport = xpub.paginationInfo;
                var page = Math.floor((bounds.left + viewport.pageOffset) / (viewport.columnWidth + viewport.columnGap));
                return page;
            }
        }
        // END Mantano

        var cfiParts = splitCfi(cfi);

        var $element = getElementByPartialCfi(cfiParts.cfi, classBlacklist, elementBlacklist, idBlacklist);

        if(!$element) {
            return -1;
        }

        return this.getPageForPointOnElement($element, cfiParts.x, cfiParts.y);
    };

    function getElementByPartialCfi(cfi, classBlacklist, elementBlacklist, idBlacklist) {

        var contentDoc = window.document;

        var wrappedCfi = "epubcfi(" + cfi + ")";
        //noinspection JSUnresolvedVariable
        var $element = EPUBcfi.getTargetElementWithPartialCFI(wrappedCfi, contentDoc, classBlacklist, elementBlacklist, idBlacklist);

        // START Mantano (Mickaël)
        // Sometimes (if the CFI's last step is actually a text node with a character offset), the $element will not be an Element node. But RJS relies on it being one, so we have to get the parent node.
        while ($element && $element.get(0).nodeType != Node.ELEMENT_NODE) {
            $element = $element.parent();
        }
        // END Mantano

        if(!$element || $element.length == 0) {
            console.log("Can't find element for CFI: " + cfi);
            return undefined;
        }

        return $element;
    }

    this.getElementByCfi = function(cfi, classBlacklist, elementBlacklist, idBlacklist) {

        var cfiParts = splitCfi(cfi);
        return getElementByPartialCfi(cfiParts.cfi, classBlacklist, elementBlacklist, idBlacklist);
    };

    this.getPageForElement = function($element) {

        return this.getPageForPointOnElement($element, 0, 0);
    };

    this.getPageForPointOnElement = function($element, x, y) {

        var pageIndex;
        if (options.rectangleBased) {
            pageIndex = findPageByRectangles($element, y);
            if (pageIndex === null) {
                console.warn('Impossible to locate a hidden element: ', $element);
                return 0;
            }
            return pageIndex;
        }

        var posInElement = this.getVerticalOffsetForPointOnElement($element, x, y);
        var viewportHeight = $viewport.height() - 2 * xpub.theme.verticalMargin;
        return Math.floor(posInElement / viewportHeight);
    };

    this.getVerticalOffsetForElement = function($element) {

        return this.getVerticalOffsetForPointOnElement($element, 0, 0);
    };

    this.getVerticalOffsetForPointOnElement = function($element, x, y) {

        var elementRect = Helpers.Rect.fromElement($element);
        return Math.ceil(elementRect.top + y * elementRect.height / 100);
    };

    this.getElementById = function(id) {

        var contentDoc = window.document;

        var $element = $(contentDoc.getElementById(id));
        //$("#" + Helpers.escapeJQuerySelector(id), contentDoc);
        
        if($element.length == 0) {
            return undefined;
        }

        return $element;
    };

    this.getPageForElementId = function(id) {

        var $element = this.getElementById(id);
        if(!$element) {
            return -1;
        }

        return this.getPageForElement($element);
    };

    // Returns both a Element node (+spatial offset) CFI and a Text node (+character offset) CFI, eg. {elementCfi:, textCfi:}.
    this.getFirstVisibleElementAndTextCfis = function(topOffset) {
        var foundElement = this.findFirstVisibleElement(topOffset);

        var elementCfi = null;
        var textCfi = null;

        // generate a Text node (+character offset) CFI from a TEXT node
        if (foundElement.textNode) {
            var offset = foundElement.textOffset ? foundElement.textOffset : 0;
            textCfi = EPUBcfi.Generator.generateCharacterOffsetCFIComponent(foundElement.textNode, offset);

            if (textCfi[0] == "!") {
                textCfi = textCfi.substring(1);
            }
        }

        // generate an Element node (+spatial offset) CFI
        if (foundElement.$element && foundElement.$element.length > 0) {
            var elementCfi = EPUBcfi.Generator.generateElementCFIComponent(foundElement.$element[0]);
            if (elementCfi[0] == "!") {
                elementCfi = elementCfi.substring(1);
            }
            elementCfi = elementCfi + "@0:" + foundElement.percentY;
        }

        if (!elementCfi && !textCfi) {
            console.log("Could not generate CFI no visible element on page");
            return null;
        }

        return {
            elementCfi: elementCfi,
            textCfi: textCfi
        }
    };

    this.getFirstVisibleElementCfi = function(topOffset) {

        var foundElement = this.findFirstVisibleElement(topOffset);

        if(!foundElement.$element) {
            console.log("Could not generate CFI no visible element on page");
            return undefined;
        }

        //noinspection JSUnresolvedVariable
        var cfi = EPUBcfi.Generator.generateElementCFIComponent(foundElement.$element[0]);

        if(cfi[0] == "!") {
            cfi = cfi.substring(1);
        }

        return cfi + "@0:" + foundElement.percentY;
    };

    this.findFirstVisibleElement = function (props) {
        return this.findFirstOrLastVisibleElement(false, props);
    };

    this.findLastVisibleElement = function (props) {
        return this.findFirstOrLastVisibleElement(true, props);
    };

    //we look for text and images
    this.findFirstOrLastVisibleElement = function (lastElement, props) {
        if (typeof props !== 'object') {
            // compatibility with legacy code, `props` is `topOffset` actually
            props = { top: props };
        }

        var $elements;
        var $firstVisibleTextNode = null;
        var percentOfElementHeight = 0;

        // START Mantano (Mickaël)
        var textNode = null;
        var textOffset = 0;

        var firstRange = (lastElement) ? MNOGetLastVisibleRange(): MNOGetFirstVisibleRange();
        if (firstRange) {
            var element = firstRange.startContainer;

            // we keep the Text node to be able to generate a Text node CFI (with character offset instead of the silly spatial offset)
            if (element.nodeType == Node.TEXT_NODE) {
                textNode = element;
                textOffset = firstRange.startOffset;
            }

            // climb up the DOM tree to generate an Element node CFI
            while (element && element.nodeType != Node.ELEMENT_NODE) {
                element = element.parentNode;
            }

            if (element) {
                var $element = $(element);
                // var $element = $element.closest("body >");
                visibilityResult = visibilityCheckerFunc($element, props, true);
                if (visibilityResult) {
                    $firstVisibleTextNode = $element;
                    percentOfElementHeight = 100 - visibilityResult;
                }
            }
        }

        // Try with readium way to locate the first visible element
        if (!$firstVisibleTextNode) {

        // END Mantano (Mickaël)

        $elements = $("body", this.getRootElement()).find(":not(iframe)").contents().filter(function () {
            return isValidTextNode(this) || this.nodeName.toLowerCase() === 'img';
        });

        // Find the first visible text node
        $.each($elements, function() {

            var $element;

            if(this.nodeType === Node.TEXT_NODE)  { //text node
                $element = $(this).parent();
            }
            else {
                $element = $(this); //image
            }

            var visibilityResult = visibilityCheckerFunc($element, props, true);
            if (visibilityResult) {
                $firstVisibleTextNode = $element;
                percentOfElementHeight = 100 - visibilityResult;
                return false;
            }
            return true;
        });

        // START Mantano (Mickaël)
        }

        // return {$element: $firstVisibleTextNode, percentY: percentOfElementHeight};
        return {$element: $firstVisibleTextNode, percentY: percentOfElementHeight, textNode: textNode, textOffset: textOffset};
        // END Mantano
    };

    /**
     * Returns the range at the top of the visible page.
     */
    function MNOGetFirstVisibleRange() {
        var range;

        if ($document && $document.find("body").length) {
            var $window = $(window);
            var step = 10;
            var x = -1;
            var y = -1;
            var width = $window.width();
            var height = $window.height();

            while (!range && y <= height) {
                y += step;
                x = -1;

                while (!range && x < width) {
                    x += step;

                    range = document.caretRangeFromPoint(x, y);
                    if (range) {
                        var rect = range.getClientRects()[0];
                        if (!(rect && rect.left > 0 && rect.left < width && rect.top > 0 && rect.top < height))
                            range = undefined;
                    }
                }
            }
        }

        return range;
    }

    /**
     * Returns the range at the top of the visible page.
     */
    function MNOGetLastVisibleRange() {
        var range;

        if ($document && $document.find("body").length) {
            var $window = $(window);
            var step = 10;
            var width = $window.width();
            var height = $window.height();
            var x = width;
            var y = height;

            while (!range && y >= 0) {
                y -= step;
                x = width;

                while (!range && x >= 0) {
                    x -= step;

                    range = document.caretRangeFromPoint(x, y);
                    if (range) {
                        var rect = range.getClientRects()[0];
                        if (!(rect && rect.left > 0 && rect.left < width && rect.top > 0 && rect.top < height))
                            range = undefined;
                    }
                }
            }
        }

        return range;
    }

    function splitCfi(cfi) {

        var ret = {
            cfi: "",
            x: 0,
            y: 0
        };

        var ix = cfi.indexOf("@");

        if(ix != -1) {
            var terminus = cfi.substring(ix + 1);

            var colIx = terminus.indexOf(":");
            if(colIx != -1) {
                ret.x = parseInt(terminus.substr(0, colIx));
                ret.y = parseInt(terminus.substr(colIx + 1));
            }
            else {
                console.log("Unexpected terminating step format");
            }

            ret.cfi = cfi.substring(0, ix);
        }
        else {

            ret.cfi = cfi;
        }

        return ret;
    }

    // returns raw DOM element (not $ jQuery-wrapped)
    this.getFirstVisibleMediaOverlayElement = function(visibleContentOffsets)
    {
        var docElement = this.getRootElement();
        if (!docElement) return undefined;

        var $root = $("body", docElement);
        if (!$root || !$root.length || !$root[0]) return undefined;

        var that = this;

        var firstPartial = undefined;

        function traverseArray(arr)
        {
            if (!arr || !arr.length) return undefined;

            for (var i = 0, count = arr.length; i < count; i++)
            {
                var item = arr[i];
                if (!item) continue;

                var $item = $(item);

                if($item.data("mediaOverlayData"))
                {
                    var visible = that.getElementVisibility($item, visibleContentOffsets);
                    if (visible)
                    {
                        if (!firstPartial) firstPartial = item;

                        if (visible == 100) return item;
                    }
                }
                else
                {
                    var elem = traverseArray(item.children);
                    if (elem) return elem;
                }
            }

            return undefined;
        }

        var el = traverseArray([$root[0]]);
        if (!el) el = firstPartial;
        return el;

        // var $elements = this.getMediaOverlayElements($root);
        // return this.getVisibleElements($elements, visibleContentOffsets);
    };

    this.getElementVisibility = function($element, visibleContentOffsets) {
        return visibilityCheckerFunc($element, visibleContentOffsets, true);
    };

    function isValidTextNode(node) {

        if(node.nodeType === Node.TEXT_NODE) {

            // Heuristic to find a text node with actual text
            var nodeText = node.nodeValue.replace(/\n/g, "");
            nodeText = nodeText.replace(/ /g, "");

             return nodeText.length > 0;
        }

        return false;

    }

    this.isElementVisible = visibilityCheckerFunc;

    this.isElementCfiVisible = function (partialCfi) {
        var pageIndex = this.getPageForElementCfi(partialCfi,
            ["cfi-marker", "mo-cfi-highlight"],
            [],
            ["MathJax_Message"]);
        var paginationInfo = options.paginationInfo || null;
        if (paginationInfo) {
            var openPages = [paginationInfo.currentSpreadIndex * paginationInfo.visibleColumnCount];
            if (paginationInfo.visibleColumnCount == 2) {
                openPages.push(openPages[0] + 1);
            }
            return _.contains(openPages, pageIndex);
        }
        return undefined;
    };

    this.getElement = function(selector) {

        var $element = $(selector, this.getRootElement());

        if($element.length > 0) {
            return $element;
        }

        return undefined;
    };

};
