// CFI parser and representation

var MNOCFI = function(path) {
    if (!path) {
        throw new Error("Trying to create a CFI without a path");
    }

    // First step in the CFI path.
    this.path = path;
};
MNOCFI.prototype.constructor = MNOCFI;

// Create a CFI with its string representation, eg. epubcfi(/6[test]/12!/4/2).
// Returns null if the CFI is invalid. Supports range CFI too.
MNOCFI.fromString = function(cfiString) {
    if (!cfiString.startsWith("epubcfi(") || !cfiString.endsWith(")")) {
        throw new Error("Invalid CFI <" + cfiString + ">");
    }

    var pathString = cfiString.substring(8, cfiString.length - 1);
    var path = MNOCFIStep.pathFromString(pathString);
    return path ? new MNOCFI(path) : null;
};

MNOCFI.prototype.toString = function(ignoreSpatialOffset) {
    var path = this.path ? this.path.toPathString(ignoreSpatialOffset) : '';
    return "epubcfi(" + path + ")";
};

MNOCFI.prototype.copy = function() {
    return new MNOCFI(this.path.copy(true));
};

MNOCFI.prototype.isRange = function() {
    return this.path ? this.path.isRange() : false;
};

// Returns a copy of the CFI if it is a range, otherwise, the copy will have the last step duplicated to create a "fake" range of length 0.
MNOCFI.prototype.toRange = function() {
    return new MNOCFI(this.path.toRange());
};

// Split a range CFI and returns the start path as a new CFI.
MNOCFI.prototype.startCFI = function() {
    return this.split(true);
};

// Split a range CFI and returns the end path as a new CFI.
MNOCFI.prototype.endCFI = function() {
    return this.split(false);
};

MNOCFI.prototype.split = function(start) {
    start = defaultFor(start, true);

    if (!this.isRange()) {
        return this;
    }

    var last = this.path;
    var lastCopy = last.copy();
    var path = lastCopy;
    
    while (last) {
        var current = null;
        if (!start) {
            current = last.endStep;
        }
        if (!current) {
            current = last.nextStep;
        }
        
        if (current) {
            var currentCopy = current.copy();
            lastCopy.nextStep = currentCopy;
            lastCopy = currentCopy;
        }
        
        last = current;
    }
    
    return new MNOCFI(path);
};

// Returns a JS Range for the CFI in the given document, if it exists.
MNOCFI.prototype.getRangeInDocument = function(doc) {
    doc = defaultFor(doc, window.document);
    if (!doc) {
        return null;
    }

    // unfortunately, EPUBcfi.getRangeTargetElements only works with range CFI, so we have to fake one with 0 length if it is not already a range
    var cfi = this.toRange();
    if (!cfi) {
        return null;
    }

    // code inspired by juan's highlights plugin
    // cf. pull requests:
    // https://github.com/readium/readium-shared-js/pull/210
    // https://github.com/readium/readium-shared-js/pull/212
    var range = null;
    try {
        var CFIRangeInfo = EPUBcfi.getRangeTargetElements(cfi.toString(true), doc,
            ["cfi-marker", "mo-cfi-highlight"],
            [],
            ["MathJax_Message"]);

        var startNode = CFIRangeInfo.startElement;
        var startOffset = CFIRangeInfo.startOffset;
        var endNode = CFIRangeInfo.endElement;
        var endOffset = CFIRangeInfo.endOffset;
        if (startNode.length < startOffset) {
            // this is a workaround for "Uncaught IndexSizeError: Index or size was negative, or greater than the allowed value." errors
            // the range cfi generator outputs a cfi like /4/2,/1:125,/16
            startOffset = startNode.length;
        }

        range = doc.createRange();
        range.setStart(startNode, startOffset);
        range.setEnd(endNode, endOffset);
    } catch (error) {
        debugger;
        console.error(error);
    }

    return range;
};

// Returns the bounding client rects for the CFI in the given document, if it exists.
MNOCFI.prototype.getBoundingClientRectInDocument = function(doc) {
    var range = this.getRangeInDocument(doc);
    return RangeFix.getBoundingClientRect(range);
};

// Returns the client rects for the CFI in the given document, if it exists.
MNOCFI.prototype.getClientRectsInDocument = function(doc) {
    var range = this.getRangeInDocument(doc);
    return RangeFix.getClientRects(range);
};

// Create a CFI from a spine item IDRef, with an optional element sub-path.
MNOCFI.fromIDRef = function(idref, elementPath) {
    var cfi = null;
    var path = null

    if (idref) {
        path = MNOCFIStep.pathFromIDRef(idref);
    } else {
        // creates a fake path if no IDRef is given
        path = MNOCFIStep.pathFromString("/99!");
    }

    if (path) {
        if (elementPath) {
            path.lastStep().nextStep = elementPath;
        }

        cfi = new MNOCFI(path);
    }

    return cfi;
};

// Create a CFI from a spine item IDRef and a DOM Element.
MNOCFI.fromElement = function(element, idref) {
    var elementPath = MNOCFIStep.pathFromElement(element);
    return elementPath ? MNOCFI.fromElementPath(elementPath, idref) : null;
};

// Create a CFI from a spine item IDRef and an element CFI.
MNOCFI.fromElementCFI = function(elementCFI, idref) {
    var elementPath = MNOCFIStep.pathFromString(elementCFI);
    return elementPath ? MNOCFI.fromElementPath(elementPath, idref) : null;
};

// Create a CFI from a spine item IDRef and a CFI Element path.
MNOCFI.fromElementPath = function(elementPath, idref) {
    idref = defaultFor(idref, xpub.currentSpineItem ? xpub.currentSpineItem.idref : null);
    return MNOCFI.fromIDRef(idref, elementPath);
};

// Resolve a MNOLocation or openPageRequest's CFI by filling the spine item information. Because Readium don't use full CFI internally.
MNOCFI.resolveLocation = function(location) {
    if (!location || (location.idref && location.elementCfi) || !location.cfi) {
        return;
    }

    var cfi = MNOCFI.fromString(location.cfi);
    cfi = cfi.startCFI(); // open page request doesn't support range CFI
    var result = cfi.toIDRefAndElementCFI();
    if (result) {
        if (result.idref) {
            location.idref = result.idref;
        }

        if (result.elementCfi) {
            location.elementCfi = result.elementCfi;
        } else {
            location.spineItemPageIndex = 0;
        }
    }
};

// Unescape the given string escaped with '^'.
MNOCFI.unescape = function(string) {
    if (string) {
        string = string.replace(/\^(.)/g, "$1")
    }

    return string;
};

// Escape special CFI characters in the given string using '^'.
MNOCFI.escape = function(string) {
    // The list of characters to escape is available in the CFI specification: http://www.idpf.org/epub/linking/cfi/#epubcfi.ebnf.special-chars
    if (string) {
        string = string.replace(/([\^[\](),;=])/g, "^$1")
    }

    return string;
};


var MNOCFIStep = function(index) {
    index = defaultFor(index, 0);

    // Node index in the DOM.
    this.index = index;

    // Brackets assertion, if there's any. Usually it's an XML element ID.
    this.assertion = null;

    // Whether the following path is relative to the document pointed to this step.
    this.isIndirection = false;

    // Optional character offset, for text nodes (or img's alt).
    this.characterOffset = 0;

    // Optional spatial 2D offset, for images or videos. The values must be between 0.0 and 1.0. The top-left corner is (0, 0).
    this.spatialOffsetX = 0;
    this.spatialOffsetY = 0;

    // Next step in the path.
    this.nextStep = null;

    // Alternative next step, if the path is a CFI range and we are at the step of separation between the start path and the end path.
    this.endStep = null;
};
MNOCFIStep.prototype.constructor = MNOCFIStep;

MNOCFIStep.prototype.lastStep = function() {
    if (this.nextStep) {
        return this.nextStep.lastStep();
    } else {
        return this;
    }
};

// Returns the next (or this one) step that is an indirection to a different document. If no step is an indirection, returns null.
MNOCFIStep.prototype.nextIndirectionStep = function() {
    if (this.isIndirection) {
        return this;
    } else if (this.nextStep) {
        return this.nextStep.nextIndirectionStep();
    } else {
        return null;
    }
};

MNOCFIStep.prototype.isRange = function() {
    if (this.endStep) {
        return true;
    }

    if (this.nextStep) {
        return this.nextStep.isRange();
    }

    return false;
};

// Returns a copy of the path if it is a range, otherwise, the copy will have the last step duplicated to create a "fake" range of length 0.
MNOCFIStep.prototype.toRange = function() {
    var step = this.copy(true);
    if (!step.isRange()) {
        var beforeLastStep = step;
        while (beforeLastStep.nextStep && beforeLastStep.nextStep.nextStep) {
            beforeLastStep = beforeLastStep.nextStep;
        }

        if (beforeLastStep.nextStep) {
            beforeLastStep.endStep = beforeLastStep.nextStep.copy(true);
        }
    }

    return step;
};

MNOCFIStep.prototype.isTextNode = function() {
    return (this.index % 2) != 0;
};

MNOCFIStep.prototype.copy = function(deepCopy) {
    deepCopy = defaultFor(deepCopy, false);

    var copy = new MNOCFIStep();
    copy.index = this.index;
    copy.assertion = this.assertion;
    copy.isIndirection = this.isIndirection;
    copy.characterOffset = this.characterOffset;
    copy.spatialOffsetX = this.spatialOffsetX;
    copy.spatialOffsetY = this.spatialOffsetY;

    if (deepCopy) {
        copy.nextStep = this.nextStep ? this.nextStep.copy(true) : null;
        copy.endStep = this.endStep ? this.endStep.copy(true) : null;
    }

    return copy;
};

// Create a step from a string, eg. /12[chapter6]!
MNOCFIStep.fromString = function(stepString) {
    // Regex to extract informations from a CFI step, with groups:
    //  1. index of the node
    //  2. (optional) bracket assertion
    //  3. (optional) character offset, eg. 32
    //  4. (optional) spatial offset, eg. 10:50
    var regex = /^\/([\d]+)(?:\[((?:[^\]\^]|\^.)*)\])?(?:!|:(\d+)|@(\d+:\d+))?$/;
    var result = stepString.match(regex);
    if (!result || result.length != 5) {
        throw new Error("Invalid CFI step <" + stepString + ">");
    }

    var step = new MNOCFIStep();
    step.index = parseInt(result[1]);
    step.assertion = MNOCFI.unescape(result[2]);
    step.isIndirection = stepString.endsWith("!");
    step.characterOffset = result[3] ? parseInt(result[3]) : 0;

    var spatialOffset = result[4];
    if (spatialOffset) {
        spatialOffset = spatialOffset.split(':');
        if (spatialOffset.length == 2) {
            step.spatialOffsetX = Math.max(0, Math.min(1, parseInt(spatialOffset[0]) / 100.0));
            step.spatialOffsetY = Math.max(0, Math.min(1, parseInt(spatialOffset[1]) / 100.0));
        }
    }

    return step;
};

MNOCFIStep.prototype.toString = function(ignoreSpatialOffset) {
    var string = '/' + this.index;

    if (this.assertion) {
        string += '[' + MNOCFI.escape(this.assertion) + ']';
    }

    if (this.isIndirection) {
        string += '!';

    } else if (this.isTextNode() || this.characterOffset > 0) {
        string += ':' + this.characterOffset;

    } else if (!ignoreSpatialOffset && (this.spatialOffsetX > 0 || this.spatialOffsetY > 0)) {
        var x = Math.trunc(this.spatialOffsetX * 100);
        var y = Math.trunc(this.spatialOffsetY * 100);
        string += '@' + x + ':' + y;
    }

    return string;
};

// Create a new CFI path for the given spine item's IDRef, eg. "chap2" -> /6/4[chap2]!
MNOCFIStep.pathFromIDRef = function(idref) {
    var path = null;
    var spineItem = xpub.currentSpineItem;
    if (spineItem) {
        path = new MNOCFIStep(xpub.package.cfiIndex);
        var documentStep = new MNOCFIStep((1 + spineItem.index) * 2);
        documentStep.assertion = idref;
        documentStep.isIndirection = true;
        path.nextStep = documentStep;
    }

    return path;
};

// Create a new CFI path from its string representation. Supports ranges if separated by ','.
MNOCFIStep.pathFromString = function(pathString) {
    // Extract the range path parts, if needed.
    // 1. full path or parent path if range
    // 2. (optional) start path, if range
    // 3. (optional) end path, if range
    // eg. /6[test]/12!/4/2 -> /6[test]/12!/4/2
    //     /6/4!/1,/2/4:8,/3:19 -> /6/4!/1, /2/4:8, /3:19
    var regex = /^((?:[^,)\^]|\^.)*),?((?:[^,)\^]|\^.)*),?((?:[^,)\^]|\^.)*)$/;
    var result = pathString.match(regex);
    if (!result || result.length != 4) {
        throw new Error("Invalid CFI path <" + pathString + ">, result <" + result + ">");
    }

    pathString = result[1];
    var startString = result[2];
    var endString = result[3];

    var path = MNOCFIStep._localPathFromString(pathString)
    if (path) {
        var last = path.lastStep();
        if (startString) {
            last.nextStep = MNOCFIStep._localPathFromString(startString);
        }
        if (endString) {
            last.endStep = MNOCFIStep._localPathFromString(endString);
        }

    }

    return path;
};

// Create a new CFI path from its string representation. Doesn't support ranges.
MNOCFIStep._localPathFromString = function(pathString) {
    // Match individual steps in a path
    // eg. /6[tes^/t]/12!/4/2:31 -> /6[tes^/t], /12!, /4, /2:31
    var regex = /(\/(?:[^/\)\^]|\^.)+)/g;
    var result = pathString.match(regex);
    if (!result) {
        throw new Error("Invalid CFI path <" + pathString + ">");
    }

    var path = null;
    var last = null;
    for (var i = 0; i < result.length; i++) {
        var step = MNOCFIStep.fromString(result[i]);
        if (step) {
            if (last) {
                last.nextStep = step;
            } else {
                path = step;
            }
            last = step;
        } else {
            path = null;
            break;
        }
    }

    return path;
};

MNOCFIStep.prototype.toPathString = function(ignoreSpatialOffset) {
    var string = this.toString(ignoreSpatialOffset);

    var next = this.nextStep ? this.nextStep.toPathString(ignoreSpatialOffset) : '';
    var end = this.endStep ? this.endStep.toPathString(ignoreSpatialOffset) : '';
    if (end) {
        string += ',' + next + ',' + end;
    } else {
        string += next;
    }

    return string;
};

// Create a new CFI path from an Element, going up to the root element.
MNOCFIStep.pathFromElement = function(element, isIndirection) {
    isIndirection = defaultFor(isIndirection, false);

    var path = null;

    while (element && element.parentElement) {
        var step = MNOCFIStep.fromElement(element);
        if (step) {
            if (path) {
                step.nextStep = path;
            } else {
                step.isIndirection = isIndirection;
            }
            path = step;
        }

        element = element.parentElement;
    }

    return path;
};

// Create a step from an Element, relative to its parent.
MNOCFIStep.fromElement = function(element, isIndirection) {
    isIndirection = defaultFor(isIndirection, false);

    var $element = $(element);
    if (!$element) {
        return null;
    }

    var step = new MNOCFIStep();

    // CFI Element steps are always even because each TEXT nodes between Elements are counted (even empty ones). Also they start at 2, not 0.
    step.index = (1 + $element.index()) * 2;
    step.assertion = $element.attr("id");
    step.isIndirection = isIndirection;

    return step;
};

// Finds the Element targeted by this path starting from the given parentElement inside the root element. If one of the steps is an indirection, stops at its Element. TEXT steps are ignored.
// Returns an object containing the element, as well as the matching step in the path (eg. if it is an indirection, the step will be the last step in the current document).
// eg. {element: Element, step: MNOCFIStep}
MNOCFIStep.prototype.resolve = function(rootElement, parentElement) {
    // CFI Element steps are always even because each TEXT nodes between Elements are counted (even empty ones). Also they start at 2, not 0.
    var element = null;
    var index = (this.index / 2) - 1;
    if (parentElement.children.length > index) {
        element = parentElement.children[index];
    }

    if (this.assertion && (!element || element.id != this.assertion)) {
        // fallback by searching the element using the ID assertion
        element = $(rootElement).find('#' + this.assertion).get(0);
    }

    if (element && !this.isIndirection && this.nextStep && !this.nextStep.isTextNode()) {
        return this.nextStep.resolve(rootElement, element);
    } else {
        return {
            element: element,
            step: this
        };
    }
};
