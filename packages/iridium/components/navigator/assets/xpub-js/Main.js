
(function() {

    $( document ).ready(function() {
        // Add a function in jQuery to compute how many columns are created for a specific element
        $.fn.howMuchCols = function(nbThumbnails){
            nbThumbnails = (nbThumbnails) ? nbThumbnails : 1;
            const windowWidth = $(window).width();
            // See https://www.codegrepper.com/code-examples/javascript/jquery+detect+if+element+has+overflow
            const spineItemDiv = $('#xpub_spineItemContents');
            const contentsWidth = spineItemDiv.prop('scrollWidth');
            const contentsHeight = spineItemDiv.prop('scrollHeight');
            console.log("=============== windowWidth: " + windowWidth + ", contentsWidth: " + contentsWidth + ", contentsHeight: " + contentsHeight);
            const columnWidth = windowWidth / nbThumbnails;
            let result = Math.ceil(contentsWidth / columnWidth);
            const lastElem = $(this).find(':last')[0];
            const clientRects = lastElem.getClientRects();
            if (lastElem.tagName === 'img') {
                const rect = clientRects[0];
                // console.log("=============== IS IMG rect.width: " + rect.width + ", rect.height: " + rect.height);
                if (rect.width > contentsWidth || rect.height > contentsHeight) {
                    result--;
                }
            }
            return result;
        };
        // Needed to hide the "loading" message at the end of every chapter
        $.mobile.loading().hide();
    });

    window.xpub = {
        initialized: false,
        htmlBodyIsVerticalWritingMode: false,
        package: null,
        screenshotConfig: null,
        lastViewPortSize: {
            width: undefined,
            height: undefined
        },
        paginationInfo: {
//            "visibleColumnCount" : 1,
//            "columnGap" : 0,
//            "spreadCount" : 0,
            "currentSpreadIndex" : 0,
//            "columnWidth" : 0,
//            "pageOffset" : 0,
//            "columnCount": 1
        },
        viewerSettings: {
            "syntheticSpread": "auto",
            "scroll": "auto",
            "enableGPUHardwareAccelerationCSS3D": false,
            "columnGap": 0
        },
        currentSpineItem: null,
        previousSpineItem: null,
        nextSpineItem: null,
        elementIds: [],
        elementIdsWithPageIndex: [],
        $epubHtml: $("html", document),
        $epubBody: null,
        highlight: null,
        bookmarks: null,
        theme: null,
        tts: null,
        /**
         * Gestures to used for a given action. May be overridden in platform
         * specific scripts.
         * For a list of multi-touch gestures: https://github.com/EightMedia/hammer.js
         */
        Gestures: {
            ZoomImage: "doubleTap"
        },

        initSpineItem: function (openBookData) {
//            console.log("initSpineItem, cfiNavigationLogic", window.cfiNavigationLogic);
//            console.log("openPage, openBookData.openPageRequest", openBookData.openPageRequest);
            xpub.$epubBody = $("body", document);
            if (!xpub.initialized) {
                xpub.highlight = new MNOHighlightController();
                xpub.bookmarks = new MNOBookmarksController();
                xpub.theme = new ThemeController();
                xpub.tts = new MNOTTSController();
                xpub.package = new Package(openBookData.package);
                xpub.currentSpineItem = new SpineItem(openBookData.spineItem, xpub.package);
                if (openBookData.previousSpineItem) {
                    xpub.previousSpineItem = new SpineItem(openBookData.previousSpineItem, xpub.package);
                }
                if (openBookData.nextSpineItem) {
                    xpub.nextSpineItem = new SpineItem(openBookData.nextSpineItem, xpub.package);
                }
                xpub.screenshotConfig = openBookData.screenshotConfig;
                xpub.viewerSettings = openBookData.settings;
                xpub.elementIds = openBookData.elementIds;
                window.currentPagesInfo = new CurrentPagesInfo(xpub.package, xpub.currentSpineItem, false, undefined);
                window.cfiNavigationLogic = new CfiNavigationLogic(xpub.$epubHtml,
                            {rectangleBased: xpub.currentSpineItem.isReflowable(), paginationInfo: openBookData.paginationInfo});
                xpub.events.initEvents();

                xpub.initialized = true;
            }
            xpub.updatePagination();
            if (openBookData.openPageRequest) {
                setTimeout(function() {
                    xpub.navigation.openPage(openBookData.openPageRequest);
                }, 0);
            }
        },

        getPropertyValue: function(propertyName) {
            return parseInt(getComputedStyle(document.documentElement).getPropertyValue(propertyName).trim());
        },

        setProperty: function(propertyName, propertyValue) {
            return document.documentElement.style.setProperty(propertyName, propertyValue);
        },

        postMessage: function(name, args, callback) {
            try {
                if (!args) {
                    args = {};
                }

                if (callback) {
                    args["callback"] = this.saveCallback(callback);
                }

                webkit.messageHandlers[name].postMessage(args);

            } catch (error) {
                console.error("Failed to post message <" + name + ">");
            }
        }
    };

})();
