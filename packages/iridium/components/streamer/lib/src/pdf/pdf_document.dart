// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:image/image.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/pdf.dart';

abstract class PdfDocument {
  String? get identifier;

  String? get title;

  String? get author;

  String? get subject;

  String? get keywords;

  String? get creator;

  String? get producer;

  String? get creationDate;

  String? get modDate;

  int get pageCount;

  (double, double) getPageSizeByIndex(int pageIndex);

  Image? get cover;

  PdfPage loadPage(int pageIndex);

  void close();

  List<String> get keywordList;

  List<Link> outline(String fileHref);
}
