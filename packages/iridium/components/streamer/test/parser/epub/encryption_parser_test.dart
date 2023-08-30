// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/encryption_parser.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;
import 'package:xml/xml.dart';

void main() {
  Future<Map<String, Encryption>> parseEncryption(String resource) async {
    String path = "test_resources/epub/$resource";
    var document = XmlDocument.parse(await File(path).readAsString());
    return EncryptionParser.parse(document);
  }

  Map<String, Encryption> encryptionMap = {
    "/OEBPS/xhtml/chapter01.xhtml": Encryption(
        algorithm: "http://www.w3.org/2001/04/xmlenc#aes256-cbc",
        compression: "deflate",
        originalLength: 13291,
        profile: null,
        scheme: "http://readium.org/2014/01/lcp"),
    "/OEBPS/xhtml/chapter02.xhtml": Encryption(
        algorithm: "http://www.w3.org/2001/04/xmlenc#aes256-cbc",
        compression: "none",
        originalLength: 12914,
        profile: null,
        scheme: "http://readium.org/2014/01/lcp")
  };

  test("Check EncryptionParser with namespace prefixes", () async {
    expect(await parseEncryption("encryption/encryption-lcp-prefixes.xml"),
        encryptionMap);
  });

  test("Check EncryptionParser with default namespaces", () async {
    expect(await parseEncryption("encryption/encryption-lcp-xmlns.xml"),
        encryptionMap);
  });

  test("Check EncryptionParser with unknown retrieval method", () async {
    expect(await parseEncryption("encryption/encryption-unknown-method.xml"), {
      "/OEBPS/xhtml/chapter.xhtml": Encryption(
          algorithm: "http://www.w3.org/2001/04/xmlenc#kw-aes128",
          compression: "deflate",
          originalLength: 12914,
          profile: null,
          scheme: null),
      "/OEBPS/images/image.jpeg": Encryption(
          algorithm: "http://www.w3.org/2001/04/xmlenc#kw-aes128",
          compression: null,
          originalLength: null,
          profile: null,
          scheme: null)
    });
  });
}
