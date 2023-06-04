// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:image/image.dart';

abstract class PdfPage {
  void close();

  double getPageWidth();

  double getPageHeight();

  Image? renderFullPage(int sizeX, int sizeY) =>
      renderPage(sizeX, sizeY, 0, 0, sizeX, sizeY);

  Image? renderPage(int imageWidth, int imageHeight, int startX, int startY,
      int sizeX, int sizeY);

  Uint8List renderPageBitmap(int imageWidth, int imageHeight, int startX,
      int startY, int sizeX, int sizeY);

  (double, double) deviceToPage(int startX, int startY, int sizeX,
      int sizeY, int rotate, int deviceX, int deviceY);

  (double, double) pageToDevice(int startX, int startY, int sizeX,
      int sizeY, int rotate, double pageX, double pageY);
}
