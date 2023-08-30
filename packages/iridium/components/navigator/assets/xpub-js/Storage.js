
(function() {

    // Wraps the localStorage's functions to save it when changed. We can't use the "storage" event as it is only fired in other tabs and frames. 
    localStorage.setItem = wrap(localStorage.setItem);
    localStorage.removeItem = wrap(localStorage.removeItem);
    localStorage.clear = wrap(localStorage.clear);

    function wrap(funct) {
        return function() {
            var value = funct.apply(this, arguments);
            xpub.postMessage("localStorageChanged", {
                "localStorage": JSON.parse(JSON.stringify(localStorage))
            });
            return value;
        };
    }

    var namespace = "file";
	var files = {};

    navigator.epubReadingSystem.xpub.storage = {

        // callback(bool success)
        save: function(identifier, mimetype, content, callback) {
            identifier = this.makeSafeIdentifier(identifier);
            this._addCallback("save", namespace, identifier, callback);
            recordingsCallbasks.notifyStorageSave(namespace, identifier, mimeType, content);
        },

        // callback(bool success)
        delete: function(identifier, callback) {
            identifier = this.makeSafeIdentifier(identifier);
            this._addCallback("delete", namespace, identifier, callback);
            recordingsCallbasks.notifyStorageDelete(namespace, identifier);
        },

        // callback(bool exists)
        exists: function(identifier, callback) {
            identifier = this.makeSafeIdentifier(identifier);
            var identifiers = this.files[namespace];
            if (identifiers) {
                return identifiers.indexOf(identifier) != -1;
            }

            return false;
        },

        // callback(string url)
        getContentURL: function(identifier, callback) {
            xpub.postMessage("storageGetContentURL", {
                "namespace": namespace,
                "identifier": identifier
            }, callback);
        },

        _addCallback: function(operation, namespace, identifier, callback) {
            if (!callback)
                return;

            var namespaces = this.callbacks[operation];
            if (!namespaces) {
                namespaces = {};
                this.callbacks[operation] = namespaces;
            }

            var identifiers = namespaces[namespace];
            if (!identifiers) {
                identifiers = {};
                namespaces[namespace] = identifiers;
            }

            var callbacks = identifiers[identifier];
            if (!callbacks) {
                callbacks = [];
                identifiers[identifier] = callbacks;
            }

            callbacks.push(callback);
        },

        _callCallbacks: function(operation, namespace, identifier, error) {
            var namespaces = this.callbacks[operation];
            if (namespaces) {
                var identifiers = namespaces[namespace];
                if (identifiers) {
                    var callbacks = identifiers[identifier];
                    if (callbacks) {
                        delete identifiers[identifier];
                        $.each(callbacks, function(index, callback) {
                            callback(error);
                        });
                    }
                }
            }
        },
        makeSafeIdentifier: function(identifier) {
        	return encodeURIComponent(identifier);
        };
    };
})();
