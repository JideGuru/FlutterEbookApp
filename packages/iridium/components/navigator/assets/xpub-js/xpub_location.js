(function() {
    xpub.location = {
        getFirstVisibleElementCfi: function() {
            var contentOffsets = this.getVisibleContentOffsets();
            return cfiNavigationLogic.getFirstVisibleElementCfi(contentOffsets);
        },

        getVisibleContentOffsets: function() {
            var paginationInfo = xpub.paginationInfo;
            var columnsLeftOfViewport = Math.round(paginationInfo.pageOffset / (paginationInfo.columnWidth + paginationInfo.columnGap));

            var topOffset =  columnsLeftOfViewport * $(document.body).height();
            var bottomOffset = topOffset + paginationInfo.visibleColumnCount * $(document.body).height();

            return {top: topOffset, bottom: bottomOffset};
        },

        bookmarkCurrentPage: function() {
            if(!xpub.currentSpineItem) {
                return new BookmarkData("", "");
            }
            if(!xpub.currentSpineItem.isFixedLayout()) {
                return new BookmarkData(xpub.currentSpineItem.idref, "");
            }

            return new BookmarkData(xpub.currentSpineItem.idref, this.getFirstVisibleElementCfi());
        },

        /**
         * Returns the location to the current page.
         */
        currentLocation: function() {
            var location = null;
            var nav = xpub.navigation.getNavigationInfo();
            if (nav && nav.navigation && nav.idref) {
                var cfis = nav.navigation.getFirstVisibleElementAndTextCfis(nav.offset ? nav.offset : 0);
                if (cfis) {
                    var elementCfi = cfis.textCfi ? cfis.textCfi : cfis.elementCfi;
                    if (elementCfi) {
                        var cfi = MNOCFI.fromElementCFI(elementCfi, nav.idref);
                        location = new MNOLocation(cfi);
                        location.idref = nav.idref;
                        location.textCfi = cfis.textCfi ? cfis.textCfi : cfis.elementCfi.split("@")[0];
                        location.elementCfi = cfis.elementCfi;
                        location.text = {};
                    }
                }
            }

            if (!location) { // fallback using Readium's bookmarks
                location = MNOLocation.fromBookmark(xpub.location.bookmarkCurrentPage());
            }

            return location;
        }
    }
})();