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
 * Representation of opening page request
 * Provides the spine item to be opened and one of the following properties:
 *  spineItemPageIndex {Number},
 *  elementId {String},
 *  elementCfi {String},
 *  firstPage {bool},
 *  lastPage {bool}
 *
 * @param {Models.SpineItem} spineItem
 *
 * @constructor
 */
var PageOpenRequest = function(spineItem) {

    this.spineItem = spineItem;
    this.spineItemPageIndex = undefined;
    // START Mantano (Mickaël)
    this.spineItemPercentage = 0;
    this.pageNumber = -1;
    // END Mantano
    this.elementId = undefined;
    this.elementCfi = undefined;
    this.firstPage = false;
    this.lastPage = false;

    this.reset = function() {
        this.spineItemPageIndex = undefined;
        // START Mantano (Mickaël)
        this.spineItemPercentage = 0;
        this.pageNumber = -1;
        // END Mantano
        this.elementId = undefined;
        this.elementCfi = undefined;
        this.firstPage = false;
        this.lastPage = false;
    };

    this.setFirstPage = function() {
        this.reset();
        this.firstPage = true;
    };

    this.setLastPage = function() {
        this.reset();
        this.lastPage = true;
    };

    this.setPageIndex = function(pageIndex) {
        this.reset();
        this.spineItemPageIndex = pageIndex;
    };

    this.setElementId = function(elementId) {
        this.reset();
        this.elementId = elementId;
    };

    this.setElementCfi = function(elementCfi) {

        this.reset();
        this.elementCfi = elementCfi;
    };

    // START Mantano (Mickaël)

    this.setPageNumber = function(pageNumber) {
        this.reset();
        this.pageNumber = pageNumber;
    };

    this.setPercentage = function(percentage) {
        this.reset();
        this.spineItemPercentage = percentage;
    };

    this.toString = function() {
        var idref = (this.spineItem ? this.spineItem.idref : "");
        return "PageOpenRequest {\n \
    \tspineItem: " + idref + "\n \
    \tspineItemPageIndex: " + this.spineItemPageIndex + "\n \
    \telementId: " + this.elementId + "\n \
    \telementCfi: " + this.elementCfi + "\n \
    \tfirstPage: " + this.firstPage + "\n \
    \tlastPage: " + this.lastPage + "\n \
    \tinitiator: " + this.initiator + "\n \
}"
    }

    // END Mantano

};
