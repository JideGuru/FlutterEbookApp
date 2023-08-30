//  LauncherOSX
//
//  Created by Boris Schneiderman.
//  Copyright (c) 2014 Readium Foundation and/or its licensees. All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice, this 
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice, 
//  this list of conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution.
//  3. Neither the name of the organization nor the names of its contributors may be 
//  used to endorse or promote products derived from this software without specific 
//  prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
//  OF THE POSSIBILITY OF SUCH DAMAGE.

/**
 * Top level ReadiumSDK namespace
 * @namespace
 */
window.Globals = {

    /**
     * Current version of the JS SDK
     * @static
     * @return {string} version
     */
    version: function () {
        return "0.8.0";
    },
    /**
     * @namespace
     */
    Views: {
        /**
         * Landscape Orientation
         */
        ORIENTATION_LANDSCAPE: "orientation_landscape",
        /**
         * Portrait Orientation
         */
        ORIENTATION_PORTRAIT: "orientation_portrait"
    },
    /**
     * @namespace
     */
    Events: {
        /**
         * @event
         */
        READER_INITIALIZED: "ReaderInitialized",
        /**
         * This gets triggered on every page turnover. It includes spine information and such.
         * @event
         */
        PAGINATION_CHANGED: "PaginationChanged",
        /**
         * @event
         */
        SETTINGS_APPLIED: "SettingsApplied",
        /**
         * @event
         */
        FXL_VIEW_RESIZED: "FXLViewResized",
        /**
         * @event
         */
        READER_VIEW_CREATED: "ReaderViewCreated",
        /**
         * @event
         */
        READER_VIEW_DESTROYED: "ReaderViewDestroyed",
        /**
         * @event
         */
        CONTENT_DOCUMENT_LOAD_START: "ContentDocumentLoadStart",
        /**
         * @event
         */
        CONTENT_DOCUMENT_LOADED: "ContentDocumentLoaded",
        /**
         * @event
         */
        MEDIA_OVERLAY_STATUS_CHANGED: "MediaOverlayStatusChanged",
        /**
         * @event
         */
        MEDIA_OVERLAY_TTS_SPEAK: "MediaOverlayTTSSpeak",
        /**
         * @event
         */
        MEDIA_OVERLAY_TTS_STOP: "MediaOverlayTTSStop",
        /**
         * @event
         */
        PLUGINS_LOADED: "PluginsLoaded"
    },
    /**
     * Internal Events
     *
     * @desc Should not be triggered outside of {@link Views.ReaderView}.
     * @namespace
     */
    InternalEvents: {
        /**
         * @event
         */
        CURRENT_VIEW_PAGINATION_CHANGED: "CurrentViewPaginationChanged",
    }

};
