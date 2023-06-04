var singleTouchGesture = false;
var startX = 0;
var startY = 0;
var availWidth = window.screen.availWidth;
var availHeight = window.screen.availHeight;


window.addEventListener("load", function(){ // on page load
                        // Get screen X and Y sizes.
                        // Events listeners for the touches.
                        window.document.addEventListener("touchstart", handleTouchStart, false);
                        window.document.addEventListener("touchend", handleTouchEnd, false);
                        // When device orientation changes, screen X and Y sizes are recalculated.
                        }, false);



// When a touch is detected records its starting coordinates and if it's a singleTouchGesture.
var handleTouchStart = function(event) {
    var node = event.target.nodeName.toUpperCase()
    if (node === 'A' || node === 'VIDEO') {
        console.log("Touched a link or video.");
        // singleTouchGesture = false;
        return;
    }
    console.log("Touch sent to native code.");
    singleTouchGesture = event.touches.length == 1;

    var touch = event.changedTouches[0];

    startX = touch.screenX % availWidth;
    startY = touch.screenY % availHeight;

};

// When a touch ends, check if any action has to be made, and contact native code.
var handleTouchEnd = function(event) {
    if(!singleTouchGesture) {
        return;
    }

    var touch = event.changedTouches[0];

    var relativeDistanceX = Math.abs(((touch.screenX % availWidth) - startX) / availWidth);
    var relativeDistanceY = Math.abs(((touch.screenY % availHeight) - startY) / availHeight);
    var touchDistance = Math.max(relativeDistanceX, relativeDistanceY);

    var scrollWidth = document.scrollWidth;
    var screenWidth = availWidth;
    var tapAreaWidth = availWidth * 0.2;

    if(touchDistance < 0.01) {
        var position = (touch.screenX % availWidth) / availWidth;
        if (position <= 0.2) {
            console.log("LeftTapped");
        } else if(position >= 0.8) {
            console.log("RightTapped");
        } else {
            console.log("CenterTapped");
            Android.centerTapped();
        }
        event.stopPropagation();
        event.preventDefault();
        return;
    }
};
