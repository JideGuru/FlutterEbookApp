var MNOLocation = function(cfi) {
	if (cfi instanceof MNOCFI) {
		cfi = cfi.toString();
	}
	
	this.version = 2;
	this.cfi = cfi;
	this.idref = undefined;
	this.spineItemPageIndex = undefined;
	this.textCfi = undefined;
	this.elementCfi = undefined;
	this.elementId = undefined;
};
MNOLocation.prototype.constructor = MNOLocation;

MNOLocation.prototype.equals = function(other) {
	var equal = this.cfi === other.cfi;
	equal &= this.idref === other.idref;
	equal &= this.spineItemPageIndex === other.spineItemPageIndex;
	equal &= this.textCfi === other.textCfi;
	equal &= this.elementCfi === other.elementCfi;
	equal &= this.elementId === other.elementId;
	return equal;
};

MNOLocation.prototype.toString = function() {
    return JSON.stringify(this);
};

MNOLocation.fromJSON = function(json) {
	return MNOLocation.fromDictionary(JSON.parse(json));
};

MNOLocation.fromDictionary = function(obj) {
	if (!obj || (!obj.idref && !obj.cfi)) {
		return null;
	}

	var location = new MNOLocation(obj.cfi);
	location.idref = obj.idref;
	location.spineItemPageIndex = obj.spineItemPageIndex;
	location.textCfi = obj.textCfi;
	location.elementCfi = obj.elementCfi;
	location.elementId = obj.elementId;
	location.updateCFI();

	return location;
};

MNOLocation.fromPageOpenRequest = function(request) {
	if (!request.spineItem)
		return null;

	var location = new MNOLocation();
	location.idref = request.spineItem.idref;
	location.spineItemPageIndex = request.spineItemPageIndex;
	location.elementId = request.elementId;
	location.textCfi = request.textCfi;
	location.elementCfi = request.elementCfi;
	location.updateCFI();
	return location;
};

MNOLocation.fromHighlight = function(highlight) {
	return MNOLocation.fromSelection(highlight);
};

MNOLocation.fromSelection = function(selection) {
	if (!selection) {
		return null;
	}

	var location = new MNOLocation()
	location.idref = selection.idref;
	location.elementCfi = selection.cfi;
	location.updateCFI();
	return location;
};

MNOLocation.fromBookmark = function(bookmark) {
	if ($.type(bookmark) == "string") {
		bookmark = JSON.parse(bookmark);
	}

	var location = new MNOLocation()
	location.idref = bookmark.idref;
	location.elementCfi = bookmark.contentCFI;
	location.updateCFI();
	return location;
};

MNOLocation.prototype.updateCFI = function() {
	if (!this.idref || this.cfi)
		return;

	var cfi = null;

	if (this.elementCfi) {
		cfi = MNOCFI.fromElementCFI(this.elementCfi, this.idref);
	}

	if (!cfi && this.elementId) {
		var element = MantanoReader.$currentDocumentHTML.find('#' + this.elementId).get(0);
		cfi = MNOCFI.fromElement(element, this.idref);
	}

	if (!cfi) {
		cfi = MNOCFI.fromIDRef(this.idref);
	}

	this.cfi = cfi ? cfi.toString() : null;
};
