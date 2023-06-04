(function () {

    function onPaginationChanged(value) {
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('LauncherUIOnPaginationChanged', value);
        } else {
            LauncherUIOnPaginationChanged.postMessage(value);
        }
    }

    function onToggleBookmark(value) {
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('LauncherUIOnToggleBookmark', value);
        } else {
            LauncherUIOnToggleBookmark.postMessage(value);
        }
    }

    function contentRefUrlsPageComputed(value) {
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('LauncherUIContentRefUrlsPageComputed', value);
        } else {
            LauncherUIContentRefUrlsPageComputed.postMessage(value);
        }
    }

    function onLeftOverlayVisibilityChanged(value) {
        console.log("====== onLeftOverlayVisibilityChanged, URL: " + window.location.href + ", value: " + value);
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('GestureCallbacksOnLeftOverlayVisibilityChanged', value);
        } else {
            GestureCallbacksOnLeftOverlayVisibilityChanged.postMessage(value);
        }
    }

    function onRightOverlayVisibilityChanged(value) {
        console.log("====== onRightOverlayVisibilityChanged, URL: " + window.location.href + ", value: " + value);
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('GestureCallbacksOnRightOverlayVisibilityChanged', value);
        } else {
            GestureCallbacksOnRightOverlayVisibilityChanged.postMessage(value);
        }
    }

    xpub.navigation.openPage = function (pageRequest) {
        let pageIndex = undefined;
        let paginationInfo = xpub.paginationInfo;

        if (pageRequest.contentRefUrl !== undefined && pageRequest.elementId === undefined) {
            let fragmentIndex = pageRequest.contentRefUrl.indexOf("#");
            if (fragmentIndex > -1) {
                pageRequest.elementId = pageRequest.contentRefUrl.substring(fragmentIndex + 1);
            }
        }

        if (pageRequest.spineItemPageIndex !== undefined) {
            pageIndex = pageRequest.spineItemPageIndex;
        } else if (pageRequest.elementId) {
            pageIndex = cfiNavigationLogic.getPageForElementId(pageRequest.elementId);
        } else if (pageRequest.elementCfi) {
            try {
                let elementCfi = pageRequest.elementCfi;
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
                if (isNaN(pageIndex)) {
                    pageIndex = 0;
                }
            } catch (e) {
                pageIndex = 0;
                console.error(e);
            }
        } else if (pageRequest.firstPage) {
            pageIndex = 0;
        } else if (pageRequest.lastPage) {
            pageIndex = xpub.paginationInfo.columnCount - 1;
        } else if (pageRequest.spineItemPercentage > 0 && paginationInfo.columnCount > 1) {
            pageIndex = Math.floor(pageRequest.spineItemPercentage * (paginationInfo.columnCount - 1));
        } else {
            console.debug("No criteria in pageRequest");
            pageIndex = 0;
        }

        // START Mantano
        // This is to avoid blank page when giving a column that is out of the
        // bounds of the spine item.
        pageIndex = Math.min(pageIndex, paginationInfo.columnCount - 1);
        // END Mantano

        if (pageIndex >= 0 && pageIndex < paginationInfo.columnCount) {
            paginationInfo.currentSpreadIndex = Math.floor(pageIndex / paginationInfo.visibleColumnCount);
            let scrollLeft = paginationInfo.currentSpreadIndex * xpub.paginationInfo.columnWidth;
            $('.xpub_container').eq(0).scrollLeft(scrollLeft);
            this.onPaginationChanged(pageRequest.elementId, true);
            if (pageRequest.startTts) {
                xpub.tts.start(pageRequest.lastPage);
            }
        } else {
            console.log('Illegal pageIndex value: ', pageIndex, 'column count is ', paginationInfo.columnCount);
        }
    };

    function getPaginationInfo(refreshAnnotations) {
        let paginationInfo = new CurrentPagesInfo(xpub.package, xpub.currentSpineItem, false,
            xpub.paginationInfo.pageOffset, xpub.paginationInfo.columnWidth);

        if (!xpub.currentSpineItem) {
            return paginationInfo;
        }
        let location = xpub.location.currentLocation();
        if (location) {
            paginationInfo.location = location;
        }
        if (refreshAnnotations) {
            paginationInfo.refreshAnnotations = refreshAnnotations;
        }

        paginationInfo.pageBookmarks.length = 0;
        let pageIndexes = getOpenPageIndexes();
        for (let i = 0, count = pageIndexes.length; i < count; i++) {
            paginationInfo.addOpenPage(pageIndexes[i], xpub.paginationInfo.columnCount,
                xpub.paginationInfo.nbThumbnailsCount, xpub.currentSpineItem.idref,
                xpub.currentSpineItem.index);
            xpub.bookmarks.pages.forEach(function (pageIndex, bookmarkId, pages) {
                if (pageIndex === pageIndexes[i]) {
                    paginationInfo.pageBookmarks.push(bookmarkId);
                }
            });
        }

        paginationInfo.elementIdsWithPageIndex = mapToObj(xpub.elementIdsWithPageIndex);

        return paginationInfo;
    }

    function getOpenPageIndexes() {
        let indexes = [];
        let _paginationInfo = xpub.paginationInfo;
//        console.log("_paginationInfo", _paginationInfo);
        let currentPage = _paginationInfo.currentSpreadIndex * _paginationInfo.visibleColumnCount;
//        console.log("currentPage", currentPage, "currentSpreadIndex", _paginationInfo.currentSpreadIndex,
//                    "visibleColumnCount", _paginationInfo.visibleColumnCount, new Error());
        for (let i = 0; i < _paginationInfo.visibleColumnCount && (currentPage + i) < _paginationInfo.columnCount; i++) {
            indexes.push(currentPage + i);
        }
        return indexes;
    }

    function getVisibleContentOffsets() {
        let _paginationInfo = xpub.paginationInfo;
        let _$contentFrame = xpub.$epubHtml;
        let columnsLeftOfViewport = Math.round(_paginationInfo.pageOffset / (_paginationInfo.columnWidth + _paginationInfo.columnGap));

        let topOffset = columnsLeftOfViewport * _$contentFrame.height();
        let bottomOffset = topOffset + _paginationInfo.visibleColumnCount * _$contentFrame.height();

        return {top: topOffset, bottom: bottomOffset};
    }

    // START Mantano (Mickaël)
    xpub.navigation.onPaginationChanged = function (paginationRequest_elementId, refreshAnnotations) {
        xpub.navigation.refreshPaginationInfo();
        onPaginationChanged(JSON.stringify(getPaginationInfo(refreshAnnotations)));
    };

    xpub.navigation.refreshPaginationInfo = function () {
        let paginationInfo = xpub.paginationInfo;
        paginationInfo.pageOffset = (paginationInfo.columnWidth + paginationInfo.columnGap) * paginationInfo.visibleColumnCount * paginationInfo.currentSpreadIndex;

        // START Mantano (Mickaël)
        this.redraw();
        cfiNavigationLogic.options.paginationInfo = paginationInfo;
        // END Mantano
    };

    xpub.navigation.redraw = function () {
        // START Mantano (Mickaël)
//        this.offsetPage(xpub.paginationInfo.pageOffset);
        // END Mantano
    };

    xpub.navigation.toggleBookmark = function () {
        xpub.navigation.refreshPaginationInfo();
        let paginationInfo = getPaginationInfo();
        let pageIndex = paginationInfo.openPages[0].spineItemPageIndex;
        $('.xpub_page_bookmark[data-page=' + pageIndex + '] img').toggle(paginationInfo.pageBookmarks.length === 0);
        paginationInfo.location.text.highlight = xpub.bookmarks.getTextSnippet();
        onToggleBookmark(JSON.stringify(paginationInfo));
    };

    xpub.navigation.getNavigationInfo = function () {
        return {
            idref: xpub.currentSpineItem.idref,
            navigation: window.cfiNavigationLogic,
            offset: getVisibleContentOffsets()
        }
    };

    xpub.navigation.computePagesForElementId = function (contentRefUrls, sourceFileHref) {
        let result = {};
        $.each(contentRefUrls, function (i, contentRefUrl) {
            let combinedPath = Helpers.ResolveContentRef(contentRefUrl, sourceFileHref);
            let hashIndex = combinedPath.indexOf("#");
            let elementId;
            if (hashIndex >= 0) {
                elementId = combinedPath.substr(hashIndex + 1);
                result[contentRefUrl] = cfiNavigationLogic.getPageForElementId(elementId);
            } else {
                result[contentRefUrl] = 0;
            }
        });
        contentRefUrlsPageComputed(JSON.stringify(result));
    };

    xpub.navigation.getFirstVisibleElement = function () {
        let contentOffsets = getVisibleContentOffsets();
        return cfiNavigationLogic.findFirstVisibleElement(contentOffsets);
    };

    xpub.navigation.getLastVisibleElement = function () {
        let contentOffsets = getVisibleContentOffsets();
        return cfiNavigationLogic.findLastVisibleElement(contentOffsets);
    };

    xpub.navigation.insureElementVisibility = function (spineItemId, element, initiator) {
        let $element = $(element);
        if (cfiNavigationLogic.isElementVisible($element, getVisibleContentOffsets())) {
            return;
        }

        let page = cfiNavigationLogic.getPageForElement($element);

        if (page === -1) {
            return;
        }

        let openPageRequest = new PageOpenRequest(xpub.currentSpineItem, initiator);
        openPageRequest.setPageIndex(page);

        let id = element.id;
        if (!id) {
            id = element.getAttribute("id");
        }

        if (id) {
            openPageRequest.setElementId(id);
        }
        xpub.navigation.openPage(openPageRequest);
    };

    xpub.navigateToStart = function() {
        xpub.initPagination();
        $('.xpub_container').eq(0).scrollLeft(0);
    };

    xpub.navigateToEnd = function() {
        xpub.initPagination();
        let xpubContainer = $('.xpub_container');
        let nbCols = $('#xpub_spineItemContents').css('column-count');

        const reverseOrder = $('#xpub_spineItemContents').css('direction') === "rtl";
        const nbColsToScroll = (reverseOrder ? nbCols : nbCols - 1);
        let scrollLeft = nbColsToScroll * xpubContainer[0].clientWidth;
        if (reverseOrder)
            scrollLeft *= -1;
        xpubContainer.eq(0).scrollLeft(scrollLeft);
    };

    xpub.updatePagination = function () {
        // At 100% font-size = 16px (on HTML, not body or descendant markup!)
        // START Mantano (Yonathan)
        if (!xpub.package) {
            return;
        }
        let _paginationInfo = xpub.paginationInfo;
        let isDoublePageSyntheticSpread = Helpers.deduceSyntheticSpread(xpub.$epubHtml, xpub.currentSpineItem, xpub.viewerSettings);
        _paginationInfo.visibleColumnCount = isDoublePageSyntheticSpread ? 2 : 1;
        _paginationInfo.columnGap = xpub.getPropertyValue('--RS__colGap');
        _paginationInfo.columnWidth = $(window).width();
        xpub.setProperty('--RS__colWidth', _paginationInfo.columnWidth + 'px');
        xpub.initPagination();
    };

    /**
     * Opens the next page.
     */
    xpub.openPageNext = function () {
        let paginationInfo = getPaginationInfo();
        if (paginationInfo.openPages.length === 0) {
            return;
        }
        let lastOpenPage = paginationInfo.openPages[paginationInfo.openPages.length - 1];
        if (lastOpenPage.spineItemPageIndex < lastOpenPage.spineItemPageCount - 1) {
            xpub.paginationInfo.currentSpreadIndex++;
            xpub.updateNavigationToCurrentSpreadIndex();
            return;
        }
        // TODO callback to inform that another spine item must be loaded
    };

    /**
     * Opens the previous page.
     */
    xpub.openPagePrev = function () {
        let paginationInfo = getPaginationInfo();
        if (paginationInfo.openPages.length === 0) {
            return;
        }
        let firstOpenPage = paginationInfo.openPages[0];
        if (firstOpenPage.spineItemPageIndex > 0) {
            xpub.paginationInfo.currentSpreadIndex--;
            xpub.updateNavigationToCurrentSpreadIndex();
            return;
        }
        // TODO callback to inform that another spine item must be loaded
    };

    xpub.updateNavigationToCurrentSpreadIndex = function () {
        let xpubContainer = $('.xpub_container');
        let nbCols = $('#xpub_contenuSpineItem').howMuchCols();
        let scrollLeft = (xpub.paginationInfo.currentSpreadIndex) * xpubContainer[0].clientWidth;
        xpubContainer.eq(0).scrollLeft(scrollLeft);
    };

    xpub.triggerOnPaginationChanged = function () {
        xpub.navigation.onPaginationChanged();
    }

    xpub.initPagination = function () {
        document.fonts.ready.then(function () {
            if (xpub.observers !== undefined) {
                for (i = 0; i < xpub.observers.length; i++) {
                    xpub.observers[i].disconnect();
                }
            }
            xpub.observers = [];

            let paginator = $('#xpub_paginator');
            paginator.empty();
            const spineItemContentsDiv = $('#xpub_spineItemContents');
            // console.log("=========== DIRECTION: " + spineItemContentsDiv.css('direction'));
            const isRtl = spineItemContentsDiv.css('direction') === "rtl";

            let nbCols = spineItemContentsDiv.howMuchCols();
            // console.log("=========== " + window.location.href + ", nbCols: " + nbCols);

            xpub.paginationInfo.columnCount = nbCols;
            spineItemContentsDiv.css('column-count', nbCols);
            let paginatorWidth = (nbCols * 100) + '%';
            paginator.css('width', paginatorWidth);
            paginator.css('max-width', paginatorWidth);

            if (xpub.screenshotConfig) {
                let spineItemPageThumbnailsCount = $('#xpub_contenuSpineItem').howMuchCols(xpub.screenshotConfig.nbThumbnails);
                xpub.paginationInfo.nbThumbnailsCount = spineItemPageThumbnailsCount;
            }

            for (let i = 0; i < nbCols; i++) {
                let divText = "<div id=\"xpub_page_" + i + "\" data-page=\"" + i + "\" class=\"xpub_page_overlay\">" +
                    "   <div class=\"xpub_page_bookmark\" data-page=\"" + i + "\" data-prevent-tap=\"true\">" +
                    "      <img src=\"/xpub-assets/bookmark.svg\" />" +
                    "   </div>" +
                    "</div>";
                paginator.eq(0).append(divText);
            }
            paginator.show();

            let lowestPageNumberDivSelector = '#xpub_page_0';
            let highestPageNumberDivSelector = '#xpub_page_' + (nbCols - 1);
            let leftDivSelector = isRtl ? highestPageNumberDivSelector : lowestPageNumberDivSelector;
            let rightDivSelector = isRtl ? lowestPageNumberDivSelector : highestPageNumberDivSelector;

            for (let i = 0; i < nbCols; i++) {
                let observer = new IntersectionObserver(function (entries) {
                    if (entries[0].isIntersecting) {
                        let index = $(entries[0].target).data("page");
                        xpub.paginationInfo.currentSpreadIndex = index;
                        xpub.triggerOnPaginationChanged();
                    }
                }, {threshold: [0.99]});
                let querySelector = document.querySelector('#xpub_page_' + i);
                if (querySelector != null) {
                    observer.observe(querySelector);
                    xpub.observers.push(observer);
                }
            }

            $('.xpub_page_bookmark').click(function (event) {
                xpub.navigation.toggleBookmark();
            });

            let observerLeft = new IntersectionObserver(function (entries) {
                // isIntersecting is true when element and viewport are overlapping
                // isIntersecting is false when element and viewport don't overlap
//                 console.log("=========== observerLeft, entry dimensions: " + entries[0].boundingClientRect.width + "x" + + entries[0].boundingClientRect.height + ", intersectionRatio: " + entries[0].intersectionRatio + ", isIntersecting? " + entries[0].isIntersecting);
                onLeftOverlayVisibilityChanged(entries[0].intersectionRatio  === 1.0);
            }, {threshold: [0.0, 0.1, 0.2, 0.90, 0.95, 0.99, 1.0]});
            let observerRight = new IntersectionObserver(function (entries) {
                // isIntersecting is true when element and viewport are overlapping
                // isIntersecting is false when element and viewport don't overlap
//                console.log("=========== observerRight, entry dimensions: " + entries[0].boundingClientRect.width + "x" + + entries[0].boundingClientRect.height + ", intersectionRatio: " + entries[0].intersectionRatio + ", isIntersecting? " + entries[0].isIntersecting);
                onRightOverlayVisibilityChanged(entries[0].intersectionRatio === 1.0);
            }, {threshold: [0.0, 0.1, 0.2, 0.90, 0.95, 0.99, 1.0]});
            xpub.observers.push(observerLeft);
            xpub.observers.push(observerRight);
            let firstDivQuerySelector = document.querySelector(leftDivSelector);
//             console.log("=========== firstDivQuerySelector: " + firstDivQuerySelector);
            if (firstDivQuerySelector != null) {
                observerLeft.observe(firstDivQuerySelector);
            }
            let lastDivQuerySelector = document.querySelector(rightDivSelector);
//             console.log("=========== lastDivQuerySelector: " + lastDivQuerySelector);
            if (lastDivQuerySelector != null) {
                observerRight.observe(lastDivQuerySelector);
            }
            xpub.bookmarks.generatePageNumberForCfi();
            xpub.elementIdsWithPageIndex = new Map();
            for (let i in xpub.elementIds) {
                let elementId = xpub.elementIds[i];
                let pageIndex = cfiNavigationLogic.getPageForElementId(elementId);
                xpub.elementIdsWithPageIndex.set(elementId, pageIndex);
            }

            if (xpub.screenshotConfig) {
                document.fonts.ready.then(function () {
                    let nbThumbnails = xpub.screenshotConfig.nbThumbnails;
                    let xpubContainer = $('.xpub_container');
                    let containerHeight = xpubContainer[0].clientHeight;
                    let containerWidth = xpubContainer[0].clientWidth;
                    let translateLeft = -(containerWidth / nbThumbnails * ((nbThumbnails - 1) / 2));
                    let translateTop = -(containerHeight / nbThumbnails * ((nbThumbnails - 1) / 2));
                    let scale = 1 / nbThumbnails;
                    $('#xpub_spineItemContents')[0].style.transform = "translate(" + translateLeft + "px, " + translateTop + "px) scale(" + scale + ")";
                    if (paginator.length === 0) {
                        document.fonts.ready.then(function () {
                            xpub.triggerOnPaginationChanged();
                        });
                    }
                });
            }
            // $('#xpub_spineItemContents')[0].style.transform = "scale(" + 0.1 + ")";
        });
    };
})();
