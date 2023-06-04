// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

class PdfBookmark {
  final int _destPageIdx;
  final String title;
  final List<PdfBookmark> _children = [];

  PdfBookmark(this._destPageIdx, this.title);

  int getDestPageIdx() => _destPageIdx;

  List<PdfBookmark> get children => _children;

  int get destPageIdx => _destPageIdx;
}
