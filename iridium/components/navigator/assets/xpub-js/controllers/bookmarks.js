// Copyright (c) 2007 -  2015 Mantano SAS
// All Rights Reserved

function MNOBookmarksController() {
    // map between spine items' IDRefs and their bookmarks as a dictionary
    // identifier -> location, eg.
    // {
    //   "s04": {
    //       "bookmark1": new MNOLocation(..),
    //       "bookmark2": new MNOLocation(..),
    //   }
    // }
	this.bookmarks = [];

    // map between a bookmark ID and its page index on the current spine item
    this.pages = undefined;
}

MNOBookmarksController.prototype.getTextSnippet = function() {
    let location = xpub.location.currentLocation();
    let caretStartPosition = xpub.highlight.computePositionFromCfi(document, location.textCfi);
    let caretEndPosition = caretStartPosition;
    let extendedRange = xpub.highlight.createRangeFromPositions(document, caretStartPosition, caretEndPosition);
    for (let i = 0; i < 20; i++) {
        extendedRange = xpub.highlight.extendRange(document, extendedRange, 'forward', "word");
    }
    xpub.highlight.updateEndContainerIfNotTextNode(extendedRange);
    return extendedRange.toString();
};

MNOBookmarksController.prototype.generatePageNumberForCfi = function() {
    this.pages = new Map();
    $('.xpub_page_bookmark img').hide();
    if (this.bookmarks) {
        for (let identifier in this.bookmarks) {
            this.generatePageNumber(identifier, this.bookmarks[identifier]);
        }
    }
};

MNOBookmarksController.prototype.generatePageNumber = function(identifier, location) {
    if (!this.pages) {
        return;
    }
    let pageIndex = this.getPageIndex(location.elementCfi);
    this.pages.set(identifier, pageIndex);
    $('.xpub_page_bookmark[data-page=' + pageIndex + '] img').show();
};
MNOBookmarksController.prototype.getPageIndex = function (elementCfi) {
    let pageIndex = 0;
    try {
        if (cfiNavigationLogic) {
            if (elementCfi.startsWith("epubcfi(") && elementCfi.endsWith(")")) {
                elementCfi = elementCfi.substring(8, elementCfi.length - 1);
            }
            let bangIndex = elementCfi.indexOf("!");
            if (bangIndex >= 0) {
                elementCfi = elementCfi.substring(bangIndex + 1);
            }
            pageIndex = cfiNavigationLogic.getPageForElementCfi(elementCfi,
                ["cfi-marker", "mo-cfi-highlight"],
                [],
                ["MathJax_Message"]);
        }
    } catch (e) {
        console.error(e);
    }
    return pageIndex;
};

/**
 * Adds the given bookmark to the controller. The location must be a spine item
 * location JSON'ed or not.
 * @Deprecated
 */
MNOBookmarksController.prototype.addBookmark = function(id, location) {
    if (typeof location === 'string') {
        try {
            location = MNOLocation.fromJSON(location);
        } catch (e) {
            console.log(e, location);
            return;
        }
    }

    if ($.isPlainObject(location)) {
        location = MNOLocation.fromDictionary(location);
    }

    MNOCFI.resolveLocation(location);

    if (!id || typeof(id) !== 'string' || !location || !location.elementCfi || !location.idref) {
        console.log("Invalid bookmark <" + id + ", " + location + ">");
        return;
    }

    this.bookmarks[id] = location;

    let spineItem = xpub.currentSpineItem;
    if (spineItem && location.idref == spineItem.idref) {
        this.generatePageNumber(id, location);
    }
};

/**
 * Adds the given list of bookmarks to the controller. The list must be a
 * dictionary of identifier -> location, eg.
 * {
 *   "bookmark1": "location 1"
 *   "bookmark2": "location 2",
 * }
 * The locations must be spine item locations JSON'ed or not.
 * @Deprecated
 */
MNOBookmarksController.prototype.addBookmarks = function(bookmarks) {
    for (identifier in bookmarks) {
        this.addBookmark(identifier, bookmarks[identifier]);
    }
};

/**
 * Deletes the given list of bookmarks to the controller. The list must be an
 * array of identifier
 */
MNOBookmarksController.prototype.removeBookmarks = function(identifiers) {
    for (i in identifiers) {
        this.removeBookmark(identifiers[i]);
    }
};

/**
 * Removes the bookmark with given ID.
 * @Deprecated
 */
MNOBookmarksController.prototype.removeBookmark = function(id) {
    if (this.pages) {
        let pageIndex = this.pages.get(id);
        this.pages.delete(id);
        let showBookmark = false;
        for (let i of this.pages.values()) {
            if (i == pageIndex) {
                showBookmark = true;
                break;
            }
        }
        $('.xpub_page_bookmark[data-page=' + pageIndex + '] img').toggle(showBookmark);
    }

    if (this.bookmarks[id]) {
        delete this.bookmarks[id];
    }
};

/**
 * Returns a map of bookmarks visible on the current page, eg.
 * {
 *     "bookmark1": MNOLocation 1,
 *     "bookmark2": MNOLocation 2
 * }
 * @Deprecated
 */
MNOBookmarksController.prototype.getVisibleBookmarks = function(paginationInfo) {
    var visibleBookmarks = {};
    if (!xpub.currentSpineItem)
        return visibleBookmarks;

    var idref = xpub.currentSpineItem.idref;
    if (!idref)
        return visibleBookmarks;

    var displayedPageNumbers = $.map(paginationInfo.openPages, function(openPage) {
        return openPage.spineItemPageIndex;
    });

    for (identifier in this.pages) {
        let page = this.pages.get(identifier);
        if ($.inArray(page, displayedPageNumbers) != -1 && this.bookmarks[identifier]) {
            visibleBookmarks[identifier] = this.bookmarks[identifier];
        }
    }

    return visibleBookmarks;
};
