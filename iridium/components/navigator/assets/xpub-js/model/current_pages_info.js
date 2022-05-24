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
//  OF THE POSSIBILITY OFSUCH DAMAGE.

/**
 * Used to report pagination state back to the host application
 *
 * @class Models.CurrentPagesInfo
 *
 * @constructor
 *
 * @param {Models.Package} package
 * @param {boolean} isFixedLayout is fixed or reflowable spine item
*/
var CurrentPagesInfo = function(package, spineItem, isFixedLayout, pageOffset, columnWidth) {

    this.package = package;
    this.spineItem = spineItem;
    this.isRightToLeft = package.isRightToLeft();
    this.isFixedLayout = isFixedLayout;
    this.spineItemCount = package.spineItemCount;
    this.pageOffset = pageOffset;
    this.columnWidth = columnWidth;
    this.pageBookmarks = [];
    this.openPages = [];

    this.addOpenPage = function(spineItemPageIndex, spineItemPageCount,
                        spineItemPageThumbnailsCount, idref, spineItemIndex) {
        // START Mantano (Mickaël)
        // calculate absolute page number
        var pageNumber = 0;
        if (spineItem) {
            var percent = spineItemPageIndex / spineItemPageCount;
            pageNumber = spineItem.firstPageNumber + Math.floor(percent * spineItem.pagesCount);
        }
        // END Mantano

        this.openPages.push({spineItemPageIndex: spineItemPageIndex, spineItemPageCount: spineItemPageCount,
                    spineItemPageThumbnailsCount: spineItemPageThumbnailsCount, idref: idref,
                    spineItemIndex: spineItemIndex
        // START Mantano (Mickaël)
        , pageNumber: pageNumber
        // END Mantano
        });

        this.sort();
    };

    this.canGoLeft = function () {
        return this.isRightToLeft ? this.canGoNext() : this.canGoPrev();
    };

    this.canGoRight = function () {
        return this.isRightToLeft ? this.canGoPrev() : this.canGoNext();
    };

    this.canGoNext = function() {
        if(this.openPages.length == 0) {
            return false;
        }

        var lastOpenPage = this.openPages[this.openPages.length - 1];

        return lastOpenPage.spineItemIndex < package.spineItemCount || lastOpenPage.spineItemPageIndex < lastOpenPage.spineItemPageCount - 1;
    };

    this.canGoPrev = function() {
        if(this.openPages.length == 0) {
            return false;
        }

        var firstOpenPage = this.openPages[0];

        return lastOpenPage.spineItemIndex > 0 || 0 < firstOpenPage.spineItemPageIndex;
    };

    this.sort = function() {
        this.openPages.sort(function(a, b) {
            if(a.spineItemIndex != b.spineItemIndex) {
                return a.spineItemIndex - b.spineItemIndex;
            }

            return a.pageIndex - b.pageIndex;
        });
    };
};
