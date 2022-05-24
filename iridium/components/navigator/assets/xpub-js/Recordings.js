navigator.epubReadingSystem = {
    "xpub": {
        'ux': {
            'toggleMenu': function() {
                uxCallbacks.toggleMenu();
            }
        },
        'recordings': {
            'audio': {
                // feedbackCallback(float averageVolume)
                //     0.0 -> 1.0
                // callback(string error)
                //     Forbidden
                'start': function(identifier, feedbackCallback, stopCallback) {
                    console.log("audio.start", identifier, feedbackCallback, stopCallback);
                    var feedbackId = xpub.saveFunction(feedbackCallback);
                    var stopId = xpub.saveCallback(function() {
                        xpub.deleteFunction(feedbackId);
                        if (stopCallback) {
                            stopCallback.apply(null, arguments);
                        }
                    });
                    recordingsCallbacks.notifyRecordingsAudioStart('audio', identifier, feedbackId, stopId);
                },

                // callback(error)
                //     RecordingFailed
                'stop': function(callback) {
                    console.log("audio.stop", callback);
                    var callbackId = xpub.saveCallback(callback);
                    recordingsCallbacks.notifyRecordingsAudioStop(callbackId);
                },

                // callback(bool isRecording)
                'isRecording': function(callback) {
                    console.log("audio.isRecording", callback);
                    var callbackId = xpub.saveCallback(callback);
                    recordingsCallbacks.isRecording(callbackId);
                },

                // see storage.delete
                'delete': function(identifier, callback) {
                    console.log("audio.delete", identifier, callback);
                    var callbackId = xpub.saveCallback(callback);
                    recordingsCallbacks.notifyStorageDelete('audio', identifier, callbackId);
                },

                // see storage.exists
                'exists': function(identifier, callback) {
                    console.log("audio.exists", identifier, callback);
                    var callbackId = xpub.saveCallback(callback);
                    recordingsCallbacks.exists('audio', identifier, callbackId);
                },

                // see storage.getContentURL
                'getPlaybackURL': function(identifier, callback) {
                    console.log("audio.getPlaybackURL", identifier, callback);
                    var callbackId = xpub.saveCallback(callback);
                    recordingsCallbacks.getContentURL('audio', identifier, callbackId);
                }
            }
        },

        "storage": {
            // callback(string error)
            //     Forbidden
            //     SaveFailed
            "save": function(identifier, mimeType, content, callback) {
                console.log("storage.save", identifier, mimeType, content, callback);
                var callbackId = xpub.saveCallback(callback);
                recordingsCallbacks.notifyStorageSave('file', identifier, mimeType, content, callbackId);
            },

            "saveLocalStorage": function(localStorage) {
                console.log("storage.saveLocalStorage", localStorage);
                recordingsCallbacks.notifyLocalStorage(JSON.stringify(localStorage));
            },

            // callback(string error)
            //     Forbidden
            //     DeleteFailed
            "delete": function(identifier, callback) {
                console.log("storage.delete", identifier, callback);
                var callbackId = xpub.saveCallback(callback);
                recordingsCallbacks.notifyStorageDelete('file', identifier, callbackId);
            },

            // callback(bool exists)
            "exists": function(identifier, callback) {
                console.log("storage.exists", identifier, callback);
                var callbackId = xpub.saveCallback(callback);
                recordingsCallbacks.exists('file', identifier, callbackId);
            },

            // callback(string url)
            "getContentURL": function(identifier, callback) {
                console.log("storage.getContentURL", identifier, callback);
                var callbackId = xpub.saveCallback(callback);
                recordingsCallbacks.getContentURL('file', identifier, callbackId);
            }
        },

        "share": function(message, rect) {
            shareCallbacks.share(message);
        }
    }
};
window.xpub = (window.xpub === undefined) ? {} : window.xpub;
xpub.saveCallback = function(callback) {
    return this.saveFunction(callback, true);
}

xpub.saveFunction = function(funct, oneShot) {
    if (!funct) {
        return null;
    }

    var functions = this.getFunctions();
    var identifier;
    do {
        identifier = Math.floor(Math.random() * 10000);
    } while (functions[identifier] != null);

    functions[identifier] = function() {
        funct.apply(undefined, arguments);
        if (oneShot) {
            xpub.deleteFunction(identifier);
        }
    };

    return identifier;
}

xpub.deleteFunction = function(identifier) {
    var functions = this.getFunctions();
    delete functions[identifier];
}

xpub.callFunction = function(identifier) {
    var functions = this.getFunctions();
    var funct = functions[identifier];
    if (funct) {
        var args = Array.prototype.slice.call(arguments).slice(1);
        funct.apply(undefined, args);
    }
}

xpub.getFunctions = function() {
    var xpub = window.top.xpub;
    if (!xpub._functions) {
        xpub._functions = {};
    }
    return xpub._functions;
}

xpub.loadLocalStorage = function(values) {
    console.log("loadLocalStorage", values);
    localStorage.clear();
    if (values) {
        $.each(values, function(key, value) {
            localStorage.setItem(key, value);
        });
    }
}

function wrap(original) {
    return function() {
        var value = original.apply(this, arguments);
        navigator.epubReadingSystem.xpub.storage.saveLocalStorage(localStorage);
        return value;
    };
}
localStorage.setItem = wrap(localStorage.setItem);
localStorage.removeItem = wrap(localStorage.removeItem);
localStorage.clear = wrap(localStorage.clear);
