(function() {
    function shouldAcceptTap(target) {
        const tagsToIgnore = ['a', 'button', 'audio', 'video'];
        if (tagsToIgnore.includes(target.tagName)) {
            return false;
        }
        if (preventTap($(target))) {
            return false;
        }
        let parents = $(target).parents();
        for (i = 0; i < parents.length; i++) {
            if (preventTap($(parents[i]))) {
                return false;
            }
        }
        return true;
    }

    function preventTap($target) {
        return typeof $target.data('preventTap') !== 'undefined';
    }

    xpub.events = {

        initEvents: function() {

            function onTap(value) {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('GestureCallbacksOnTap', value);
                } else {
                    GestureCallbacksOnTap.postMessage(value);
                }
            }

            function onSwipeUp(value) {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('GestureCallbacksOnSwipeUp', value);
                } else {
                    GestureCallbacksOnSwipeUp.postMessage(value);
                }
            }

            function onSwipeDown(value) {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('GestureCallbacksOnSwipeDown', value);
                } else {
                    GestureCallbacksOnSwipeDown.postMessage(value);
                }
            }

            function imageZoomed(value) {
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('LauncherUIImageZoomed', value);
                } else {
                    LauncherUIImageZoomed.postMessage(value);
                }
            }

            xpub.$epubHtml.on("tap", function(event) {
//                console.log("tap", event);
                if (shouldAcceptTap(event.target)) {
                    var position = Helpers.getPositionFromEvent(event);
                    onTap(JSON.stringify(position));
                }
            });
            // image zooming is only available on reflowable pages
            if (!xpub.currentSpineItem.isReflowable()) {
                return;
            }
            xpub.$epubHtml.on('swipeup swipedown', "body", function(event) {
                event.stopPropagation();
//                console.log("swipe", event);
                if (event.type == "swipeup") {
                    onSwipeUp("");
                } else if (event.type == "swipedown") {
                    onSwipeDown("");
                }
            });
            xpub.$epubHtml.on(xpub.Gestures.ZoomImage, "img", function(event) {
//                console.log("doubleTap", event);
                event.stopPropagation();

                var img = $(this)[0];
                var url = img.src;
                var rect = img.getBoundingClientRect();

                imageZoomed(url);
            });
        }
    };
})();
