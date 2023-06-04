(function() {
    xpub.navigation = {
        /**
         * Opens the content document specified by the url
         *
         * @param {string} contentRefUrl Url of the content document
         * @param {string | undefined} sourceFileHref Url to the file that contentRefUrl is relative to. If contentRefUrl is
         * relative ot the source file that contains it instead of the package file (ex. TOC file) We have to know the
         * sourceFileHref to resolve contentUrl relative to the package file.
         * @param {object} initiator optional
         */
        openContentUrl: function (contentRefUrl, sourceFileHref, initiator) {
            var combinedPath = Helpers.ResolveContentRef(contentRefUrl, sourceFileHref);

            var hashIndex = combinedPath.indexOf("#");
            var hrefPart;
            var elementId;
            if (hashIndex >= 0) {
                hrefPart = combinedPath.substr(0, hashIndex);
                elementId = combinedPath.substr(hashIndex + 1);
            }
            else {
                hrefPart = combinedPath;
                elementId = undefined;
            }

            return this.openSpineItemElementId(xpub.currentSpineItem.idref, elementId, initiator);
        },

        /**
         * Opens page index of the spine item with idref provided
         *
         * @param {string} idref Id of the spine item
         * @param {number} pageIndex Zero based index of the page in the spine item
         * @param {object} initiator optional
         */
        openSpineItemPage: function (idref, pageIndex, initiator) {
            var pageData = new PageOpenRequest(xpub.currentSpineItem);
            if (pageIndex) {
                pageData.setPageIndex(pageIndex);
            }
            this.openPage(pageData);
            return true;
        },

        /**
         * Opens the page of the spine item with element with provided cfi
         *
         * @param {string} idref Id of the spine item
         * @param {string} elementCfi CFI of the element to be shown
         * @param {object} initiator optional
         */
        openSpineItemElementCfi: function (idref, elementCfi, initiator) {
            var pageData = new PageOpenRequest(xpub.currentSpineItem, initiator);
            if (elementCfi) {
                pageData.setElementCfi(elementCfi);
            }
            this.openPage(pageData, 0);
            return true;
        },

        /**
         * Opens the page of the spine item with element with provided cfi
         *
         * @param {string} idref Id of the spine item
         * @param {string} elementId id of the element to be shown
         * @param {object} initiator optional
         */
        openSpineItemElementId: function (idref, elementId, initiator) {
            var pageData = new PageOpenRequest(xpub.currentSpineItem, initiator);
            if (elementId) {
                pageData.setElementId(elementId);
            }
            this.openPage(pageData, 0);
            return true;
        },

        openPageNumber: function(pageNumber) {
            if (pageNumber < 0 || pageNumber >= xpub.package.pageCount) {
                return false;
            }

            var item = xpub.currentSpineItem;

            if (item) {
                var pageData = new PageOpenRequest(item);
                if (item.pagesCount > 1) {
                    pageData.setPercentage((pageNumber - item.firstPageNumber) / (item.pagesCount - 1));
                }
                this.openPage(pageData);
            }

            return item;
        },
    }
})();