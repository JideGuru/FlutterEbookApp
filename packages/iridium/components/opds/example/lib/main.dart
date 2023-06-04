// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_opds/mno_opds.dart';
import 'package:mno_shared/opds.dart';
import 'package:universal_io/io.dart' hide Link;

void main() {
  ParseData parseData = Opds1Parser.parse(
      File("lib/acquisition-feed.atom").readAsStringSync(),
      Uri.parse("https://example.com"));
  print("ODPS feed: ${parseData.feed}");
}
