// Copyright (c) 2007 -  2015 Mantano SAS
// All Rights Reserved

/**
 * The TTS controller is used to manage the retrieval and traversal of
 * utterances to be played in the HTML content.
 * It handles feedback (style) of playing utterance, and navigation when
 * reaching the end of a page or spine item.
 */
function MNOTTSController() {
	var self = this;

	// current utterance element to be played
	this.$element = null;

	// is currently playing continuously
	this.playing = false;

	// is the audio panel visible?
	this.enabled = false;

//	MantanoReader.readerInitialized(function(reader) {
//
//		MantanoReader.documentLoaded(function($document) {
//			if (self.isPlaying()) {
//				self.start();
//			}
//		});

		// play the sentence under the finger when taping the screen,
		// if the TTS is enabled
		xpub.$epubHtml.on("singleTap", function(event) {
			if (!self.enabled) {
				return;
			}

            var position = Helpers.getPositionFromEvent(event);
			var $element = $(document.elementFromPoint(position.x, position.y));
			$element = self._getEnclosingTextElement($element);
			if (self._exists($element)) {
				self.setElement($element);
			}
		});
//	});
};

MNOTTSController.prototype.setEnabled = function(enabled) {
	this.enabled = enabled;
};

MNOTTSController.prototype.isPlaying = function() {
	return this.playing;
};

function openSpineItemForTts(value) {
    if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('LauncherUIOpenSpineItemForTts', value);
    } else {
        LauncherUIOpenSpineItemForTts.postMessage(value);
    }
}

MNOTTSController.prototype.start = function(lastElement) {
	this.playing = true;

	var $element = (lastElement) ?  this.getLastVisibleElement(): this.getFirstVisibleElement();
	if (this._exists($element)) {
		this.setElement($element);
	} else if (nextSpineItem) {
        var data = {idref: nextSpineItem.idref, lastPage: false};
        openSpineItemForTts(JSON.stringify(data));
	} else {
	    self.stop();
	}
};

MNOTTSController.prototype.stop = function() {
	this.playing = false;
	this.setElement(null);
};

/**
 * Requests and highlights the pervious/next element to be played. When found, the
 * element will be notified to the host through the MNOTTSSpeakUtterance
 * notification.
 */
MNOTTSController.prototype.previous = function() {
	this._next(false);
};

MNOTTSController.prototype.next = function() {
	this._next(true);
};

MNOTTSController.prototype._next = function(forward) {
	if (!this.isPlaying()) {
		return;
	}

	var $next = this.getNextElement(this.$element, forward);
	if (this._exists($next)) {
		this.setElement($next);
	} else {
		var nextSpineItem = (forward ? xpub.nextSpineItem : xpub.previousSpineItem);
        this.stop();
		if (nextSpineItem) {
		    var data = {idref: nextSpineItem.idref, lastPage: !forward};
            openSpineItemForTts(JSON.stringify(data));
		}
	}
};

MNOTTSController.prototype.setElement = function($element) {
	if (this.$element) {
		this.$element.removeClass("mno-tts-active");
	}

	this.$element = $element;

	if (this._exists($element)) {
		this.playing = true;
		$element.addClass("mno-tts-active");

		xpub.navigation.insureElementVisibility(xpub.currentSpineItem.idref, $element.get(0), this);
        window.ttsCallbacks.ttsSpeakUtterance($element.text());
	} else {
		this.playing = false;
		 window.ttsCallbacks.ttsDidStop();
	}
};


/**
 * Returns the first visible element containing text to be played at the top
 * of the page. Or null if none could be found.
 */
MNOTTSController.prototype.getFirstVisibleElement = function() {
	var element = xpub.navigation.getFirstVisibleElement();
	if (element) {
		var $element = this._getEnclosedTextElement(element.$element);

		// we skip the first visible element if the beginning is not visible on the page
		if (this._exists($element)) {
			var offset = $element.offset();
			if (offset.left < 0 || offset.top < 0) {
				var $next = this.getNextElement($element, true);
				if ($next) {
					return $next;
				}
			}

			return $element;
		}
	}

	return null;
};


/**
 * Returns the first visible element containing text to be played at the top
 * of the page. Or null if none could be found.
 */
MNOTTSController.prototype.getLastVisibleElement = function() {
	var element = xpub.navigation.getLastVisibleElement();
	if (element) {
		var $element = this._getEnclosedTextElement(element.$element);

		// we skip the first visible element if the beginning is not visible on the page
		if (this._exists($element)) {
			var offset = $element.offset();
			if (offset.left < 0 || offset.top < 0) {
				var $next = this.getNextElement($element, true);
				if ($next) {
					return $next;
				}
			}

			return $element;
		}
	}

	return null;
};

/**
 * Returns the previous or next element to be played after the given one,
 * or null if we can't find any (eg. beginning or end of spine item).
 */
MNOTTSController.prototype.getNextElement = function($element, forward) {
	if (!this._exists($element) || $element.is("body")) {
		return null;
	}

	var $next = (forward ? $element.next() : $element.prev());	
	while (this._exists($next)) {
		$nextText = this._getEnclosedTextElement($next, !forward);
		if (this._exists($nextText)) {
			$next = $nextText;
			break;
		}

		$next = (forward ? $next.next() : $next.prev());	
	}

	// probably the last sibling, so we check the sibling of our own parent
	if (!this._exists($next)) {
		$next = this.getNextElement($element.parent(), forward);
	}

	return this._exists($next) ? $next : null;
};

/**
 * Returns the first element containing text nodes to be played in the given
 * element and its children.
 * If reverse is set to true, then the text element will be looked for from the
 * end of the children list.
 */
MNOTTSController.prototype._getEnclosedTextElement = function($element, reverse) {
	// if the element contains any text node, alors we consider it is a text
	// element to be read as a whole, eg. <p>This is <strong>bold</strong></p>.
	if (!this._exists($element) || this._containsText($element)) {
		return $element;
	}

	// sometimes audio and video tags contain a warning message that we want
	// to skip
	if ($element.is("audio") || $element.is("video")) {
		return null;
	}

	var $children = $element.children();
	if (reverse) {
		$children = $($children.get().reverse());
	}

	var self = this;
	var $textElement = null;
	$children.each(function(i, child) {
		$textElement = self._getEnclosedTextElement($(child), reverse);
		if (self._exists($textElement)) {
			return false;
		}
	});

	return this._exists($textElement) ? $textElement : null;
};

MNOTTSController.prototype._getEnclosingTextElement = function($element) {
	var $textElement = null;
	if (this._containsText($element)) {
		$textElement = $element; // best candidate for now
	}

	var $parent = $element.parent();
	while (this._exists($parent) && !$parent.is("body")) {
		if (this._containsText($parent)) {
			$textElement = $parent;
		}

		$parent = $parent.parent();
	}

	return $textElement;
};

/**
 * Returns whether the given element contains at least one text node that is not
 * made of whitespaces.
 */
MNOTTSController.prototype._containsText = function($element) {
	var found = false;
	$element.contents().each(function(i, node) {
		found = (node.nodeType == Node.TEXT_NODE && $.trim(node.textContent).length > 0);
		if (found) {
			return false;
		}
	});

	return found;
};

MNOTTSController.prototype._exists = function($element) {
	return $element && $element.length > 0;
};
