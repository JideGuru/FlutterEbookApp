// Taken from http://stackoverflow.com/questions/894860/set-a-default-parameter-value-for-a-javascript-function
function defaultFor(arg, val) {
	return typeof arg !== 'undefined' ? arg : val;
}

function mapToObj(m) {
    return Array.from(m).reduce((obj, [key, value]) => {
        obj[key] = value;
        return obj;
    }, {});
}

/**
 * Returns whether the given range is visible on screen.
 */
function MNOIsRangeVisibleOnScreen(range) {
	// TODO: take all client rects into account
	var rect = range ? range.getClientRects()[0] : undefined;

	if (!rect)
		return false;
	
	var $window = $(MantanoReader.currentWindow);
	var w = $window.width();
	var h = $window.height();

	return rect.left > 0 && rect.left < w && rect.top > 0 && rect.top < h;
}

/**
 * Returns the range at the top of the visible page.
 */
function MNOGetFirstVisibleRange() {
	var range;

    if (MantanoReader.$currentDocument && MantanoReader.$currentDocument.find("body").length) {
        var $window = $(MantanoReader.currentWindow);
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

                range = MantanoReader.currentDocument.caretRangeFromPoint(x, y);
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

function MNOOpenBookOnSpineItemIndex(reader, spineItemIndex) {
    var spineItem = reader.spine().item(spineItemIndex);
    if (spineItem) {
        reader.openSpineItemPage(spineItem.idref, 0, reader);
    }
}

function MNOIsFixedLayoutFromPaginationInfo(paginationInfo) {
    var isFixedLayout = false;
    if(paginationInfo.spineItem) {
        isFixedLayout = paginationInfo.spineItem.isFixedLayout();
    } else if (paginationInfo.initiator && paginationInfo.initiator.getSpine) {
        isFixedLayout = paginationInfo.initiator.getSpine().package.isFixedLayout();
    }
    return isFixedLayout;
}

function MNOIsFixedLayoutFromSpineItem(spineItem) {
    return spineItem.isFixedLayout();
}

function MNOIsFixedLayout() {
    return ReadiumSDK.reader.package().isFixedLayout();
}
