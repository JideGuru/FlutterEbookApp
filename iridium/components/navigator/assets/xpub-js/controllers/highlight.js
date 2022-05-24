// Copyright (c) 2007 -  2015 Mantano SAS
// All Rights Reserved

function MNOHighlightController() {
    var self = this;
}

// Utility fonctions
function createSelectionResultFromNotification(boxes, annotationId, range) {
    var result = {};
    if (boxes) {
        result.boxes = createJsonBoxes(boxes);
    }
    if (annotationId) {
        result.id = annotationId;
    }
    if (range) {
        result.startCfi = EPUBcfi.generateCharacterOffsetCFIComponent(range.startContainer, range.startOffset);
        result.endCfi = EPUBcfi.generateCharacterOffsetCFIComponent(range.endContainer, range.endOffset);
    }
    return result;
}

function createJsonBoxes(boxes) {
    var rects = [];
    _.each(boxes, function (rect) {
        rects.push({left: rect.left, top: rect.top, right: rect.right, bottom: rect.bottom});
    });
    return rects;
}

MNOHighlightController.prototype.computeBoxesForCfi = function (idref, annotationId, cfi) {
    var boxes = this.getClientRectsForCfi(cfi);
    if (boxes) {
        window.selectionCallbacks.boxesComputed(JSON.stringify(createSelectionResultFromNotification(boxes, annotationId)));
    }
};
/**
 * @param selectionTouchInfo: Object {touch:{x:Number, y:Number}, cfi:String}
 */
MNOHighlightController.prototype.computeBoxesForPositions = function (selectionTouchInfo) {
    var range = this.getRangeForPositions(selectionTouchInfo);

    var boxes = this.getClientRectsForRange(range);
    if (boxes) {
        window.selectionCallbacks.boxesComputed(JSON.stringify(createSelectionResultFromNotification(boxes, null, range)));
    }
};
/**
 * @param startCfi: String
 * @param endCfi: String
 * @param granularity: String. One of "character", "word", "sentence", "line", "paragraph", "lineboundary", "sentenceboundary", "paragraphboundary", or "documentboundary"
 */
MNOHighlightController.prototype.extendSelection = function (startCfi, endCfi, granularity) {
    var contentDoc = document;

    var caretStartPosition = this.computePositionFromCfi(contentDoc, startCfi);
    var caretEndPosition = this.computePositionFromCfi(contentDoc, endCfi);
    if (!caretStartPosition || !caretEndPosition) {
        return;
    }

    var extendedRange = this.modifySelection(contentDoc, caretStartPosition, caretEndPosition, granularity);
    var boxes = this.getClientRectsForRange(extendedRange);
    if (boxes) {
        window.selectionCallbacks.selectionExtended(JSON.stringify(createSelectionResultFromNotification(boxes, null, extendedRange)));
    }
};
/**
 * @param startCfi: String
 * @param endCfi: String
 */
MNOHighlightController.prototype.notifyEndSelection = function (startCfi, endCfi) {
    var contentDoc = document;

    var caretStartPosition = this.computePositionFromCfi(contentDoc, startCfi);
    var caretEndPosition = this.computePositionFromCfi(contentDoc, endCfi);
    if (!caretStartPosition || !caretEndPosition) {
        return;
    }

    var range = this.createRangeFromPositions(contentDoc, caretStartPosition, caretEndPosition);
    var boxes = this.getClientRectsForRange(range);
    var cfi = this.createCfiFromRange(range);
    // TODO get HTML content. Using range.cloneContents()?
    var text = range.toString();
    //TODO extend selection
    if (boxes) {
        var result = {boxes: createJsonBoxes(boxes), cfi: cfi, text: text};
        window.selectionCallbacks.selectionEnded(JSON.stringify(result));
    }
};
MNOHighlightController.prototype.computeStartAndEndCfisForSelection = function (cfi) {
    var cfi = MNOCFI.fromElementCFI(cfi);
    if (cfi) {
        var range = cfi.getRangeInDocument();
        window.selectionCallbacks.startAndEndCfiComputed(JSON.stringify(createSelectionResultFromNotification(null, null, range)));
    }
};

MNOHighlightController.prototype.getClientRectsForCfi = function (cfi) {
    var cfi = MNOCFI.fromElementCFI(cfi);
    if (cfi) {
        var range = cfi.getRangeInDocument();
        return cfi.getClientRectsInDocument();
    }
    return undefined;
};

MNOHighlightController.prototype.getClientRectsForRange = function (range) {

    if (!range) {
        return;
    }
    return RangeFix.getClientRects(range);
};

/**
 * @param selectionTouchInfo: Object {touch:{x:Number, y:Number}, cfi:String}
 */
MNOHighlightController.prototype.getRangeForPositions = function (selectionTouchInfo) {
    // code taken from highlights by juan plugin
    // TODO: this should be part of a common code, probably in cfi_navigation_logic
    // cf. pull requests https://github.com/readium/readium-shared-js/pull/210 and
    // https://github.com/readium/readium-shared-js/pull/212

    var contentDoc = document;

    var caretStartPosition = this.computeCaretPositionFromPoint(contentDoc, selectionTouchInfo.touch.x, selectionTouchInfo.touch.y);
    var caretEndPosition = caretStartPosition;

    if (selectionTouchInfo.cfi) {
        caretEndPosition = this.computePositionFromCfi(contentDoc, selectionTouchInfo.cfi);
    } else {
        var extendedRange = this.modifySelection(contentDoc, caretStartPosition, caretEndPosition, 'word');
        if (extendedRange) {
            caretStartPosition = {offsetNode: extendedRange.startContainer, offset: extendedRange.startOffset};
            caretEndPosition = {offsetNode: extendedRange.endContainer, offset: extendedRange.endOffset};
        }
    }

    return this.createRangeFromPositions(contentDoc, caretStartPosition, caretEndPosition);

};
MNOHighlightController.prototype.createRangeFromPositions = function (contentDoc, caretStartPosition, caretEndPosition) {
    // Doc: https://developer.mozilla.org/fr/docs/Web/API/Node/compareDocumentPosition
    if (caretStartPosition.offsetNode == undefined || caretEndPosition.offsetNode == undefined)
        return;
    var compareEndToStartNodes = caretEndPosition.offsetNode.compareDocumentPosition(caretStartPosition.offsetNode);
    var SAME_NODE = 0;
    if (compareEndToStartNodes & Node.DOCUMENT_POSITION_FOLLOWING ||
        (compareEndToStartNodes == SAME_NODE && caretEndPosition.offset < caretStartPosition.offset)) {
        var temp = caretStartPosition;
        caretStartPosition = caretEndPosition;
        caretEndPosition = temp;
    }

    var range = contentDoc.createRange();

    range.setStart(caretStartPosition.offsetNode, caretStartPosition.offset);
    range.setEnd(caretEndPosition.offsetNode, caretEndPosition.offset);

    return range;
};
MNOHighlightController.prototype.modifySelection = function (contentDoc, caretStartPosition, caretEndPosition, granularity) {
    if (caretStartPosition.offsetNode == undefined || caretEndPosition.offsetNode == undefined)
        return;
    var extendedRange = contentDoc.createRange();
    extendedRange.setStart(caretStartPosition.offsetNode, caretStartPosition.offset);
    extendedRange.setEnd(caretEndPosition.offsetNode, caretEndPosition.offset);
    extendedRange = this.extendRange(contentDoc, extendedRange, 'backward', granularity);
    extendedRange = this.extendRange(contentDoc, extendedRange, 'forward', granularity);
    this.updateEndContainerIfNotTextNode(extendedRange);
    return extendedRange;
};
MNOHighlightController.prototype.extendRange = function (document, extendedRange, direction, granularity) {
    var selection = document.getSelection();
    selection.removeAllRanges();
    selection.addRange(extendedRange);
    selection.modify('extend', direction, granularity);
    var range = selection.getRangeAt(0);
    selection.removeAllRanges();
    return range;
};
MNOHighlightController.prototype.updateEndContainerIfNotTextNode = function (extendedRange) {
    if (extendedRange.endContainer.nodeType == Node.ELEMENT_NODE) {
        var endContainer = $(extendedRange.endContainer).contents().filter(function () {
            return this.nodeType == Node.TEXT_NODE;
        }).first()[0];
        extendedRange.setEnd(endContainer, 0);
    }
};

MNOHighlightController.prototype.computeCaretPositionFromPoint = function (doc, x, y) {
    var textNode;
    var offset;
    // Firefox
    if (doc.caretPositionFromPoint) {
        var caretPosition = doc.caretPositionFromPoint(x, y);
        if (caretPosition) {
            textNode = caretPosition.offsetNode;
            offset = caretPosition.offset;
        }

        // Webkit
    } else if (doc.caretRangeFromPoint) {
        var caretRange = doc.caretRangeFromPoint(x, y);
        if (caretRange) {
            textNode = caretRange.startContainer;
            offset = caretRange.startOffset;
        }
    }
    return {offsetNode: textNode, offset: offset};
};
MNOHighlightController.prototype.computePositionFromCfi = function (contentDoc, cfi) {
    var parts = cfi.split(':');
    var position;

    try {
        var node = EPUBcfi.getTargetElementWithPartialCFI("epubcfi(" + parts[0] + ")", contentDoc);
        if (node) {
            position = {offsetNode: node[0], offset: parseInt(parts[1])};
        }
    } catch (error) {
    }

    return position;
};

MNOHighlightController.prototype.createCfiFromRange = function (range) {
    return {"idref":xpub.currentSpineItem.idref, "cfi":this.generateRangeComponent(range)};
};
MNOHighlightController.prototype.generateRangeComponent = function (range) {
    return EPUBcfi.generateRangeComponent(
        range.startContainer,
        range.startOffset,
        range.endContainer,
        range.endOffset, ["cfi-marker", "cfi-blacklist", "mo-cfi-highlight"], [], ["MathJax_Message", "MathJax_SVG_Hidden"]
    );
};
