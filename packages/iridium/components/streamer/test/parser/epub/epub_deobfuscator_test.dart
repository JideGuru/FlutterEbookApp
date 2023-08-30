// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:dfunc/dfunc.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/epub_deobfuscator.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' hide Link;

Future<void> main() async {
  var identifier = "urn:uuid:36d5078e-ff7d-468e-a5f3-f47c14b91f2f";
  var transformer = EpubDeobfuscator(identifier);
  var deobfuscationDir = Directory("test_resources/epub/deobfuscation");
  assert(await deobfuscationDir.exists());
  Fetcher fetcher =
      FileFetcher.single(href: "/deobfuscation", file: deobfuscationDir);

  var fontResult =
      await fetcher.get(Link(href: "/deobfuscation/cut-cut.woff")).read();
  assert(fontResult.isSuccess);
  ByteData font = fontResult.getOrThrow();

  Resource deobfuscate(String href, String? algorithm) {
    var encryption = algorithm?.let((it) => Encryption(algorithm: it).toJson());
    var properties = encryption?.let((it) => {"encrypted": it}) ?? {};

    var obfuscatedRes = fetcher.get(
        Link(href: href, properties: Properties(otherProperties: properties)));
    return transformer.transform(obfuscatedRes);
  }

  ///TODO this test is falling. Debugging is needed
  test("testIdpfDeobfuscation", () async {
    var deobfuscatedRes = (await deobfuscate("/deobfuscation/cut-cut.obf.woff",
                "http://www.idpf.org/2008/embedding")
            .read())
        .getOrNull()!;
    expect(deobfuscatedRes.buffer.asUint8List(), font.buffer.asUint8List());
  });

  ///TODO this test is falling. Debugging is needed
  test("testAdobeDeobfuscation", () async {
    var deobfuscatedRes = (await deobfuscate("/deobfuscation/cut-cut.adb.woff",
                "http://ns.adobe.com/pdf/enc#RC")
            .read())
        .getOrNull()!;
    expect(deobfuscatedRes.buffer.asUint8List(), font.buffer.asUint8List());
  });

  test(
      "a resource is passed through when the link doesn't contain encryption data",
      () async {
    var deobfuscatedRes =
        (await deobfuscate("/deobfuscation/cut-cut.woff", null).read())
            .getOrNull()!;
    expect(deobfuscatedRes.buffer.asUint8List(), font.buffer.asUint8List());
  });

  test("a resource is passed through when the algorithm is unknown", () async {
    var deobfuscatedRes =
        (await deobfuscate("/deobfuscation/cut-cut.woff", "unknown algorithm")
                .read())
            .getOrNull()!;
    expect(deobfuscatedRes.buffer.asUint8List(), font.buffer.asUint8List());
  });
}
