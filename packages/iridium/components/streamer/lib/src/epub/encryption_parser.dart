// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:xml/xml.dart';

/// Parser for encryption.xml file.
class EncryptionParser {
  /// Parse encryption.xml file.
  static Map<String, Encryption> parse(XmlDocument document) =>
      Map.fromEntries(document
          .findAllElements("EncryptedData", namespace: Namespaces.enc)
          .mapNotNull(_parseEncryptedData));

  static MapEntry<String, Encryption>? _parseEncryptedData(XmlElement node) {
    String? resourceURI = node
        .getElement("CipherData", namespace: Namespaces.enc)
        ?.getElement("CipherReference", namespace: Namespaces.enc)
        ?.getAttribute("URI");
    if (resourceURI == null) {
      return null;
    }
    String? retrievalMethod = node
        .getElement("KeyInfo", namespace: Namespaces.sig)
        ?.getElement("RetrievalMethod", namespace: Namespaces.sig)
        ?.getAttribute("URI");
    String? scheme = (retrievalMethod == "license.lcpl#/encryption/content_key")
        ? Drm.lcp.scheme
        : null;
    String? algorithm = node
        .getElement("EncryptionMethod", namespace: Namespaces.enc)
        ?.getAttribute("Algorithm");
    if (algorithm == null) {
      return null;
    }
    var compression = node
        .getElement("EncryptionProperties", namespace: Namespaces.enc)
        ?.let(_parseEncryptionProperties);
    int? originalLength = compression?.$1;
    String? compressionMethod = compression?.$2;
    Encryption enc = Encryption(
        scheme: scheme,
        /* profile: drm?.license?.encryptionProfile,
            FIXME: This has probably never worked. Profile needs to be filled somewhere, though. */
        algorithm: algorithm,
        compression: compressionMethod,
        originalLength: originalLength);
    return MapEntry(Href(resourceURI).string, enc);
  }

  static (int, String)? _parseEncryptionProperties(
      XmlElement encryptionProperties) {
    for (XmlElement encryptionProperty in encryptionProperties
        .findElements("EncryptionProperty", namespace: Namespaces.enc)) {
      XmlElement? compressionElement = encryptionProperty
          .getElement("Compression", namespace: Namespaces.comp);
      if (compressionElement != null) {
        var compression =
            _parseCompressionElement(compressionElement);
        if (compression != null) {
          return compression;
        }
      }
    }
    return null;
  }

  static (int, String)? _parseCompressionElement(
      XmlElement compressionElement) {
    int? originalLength =
        compressionElement.getAttribute("OriginalLength")?.toIntOrNull();
    if (originalLength == null) {
      return null;
    }
    String? method = compressionElement.getAttribute("Method");
    if (method == null) {
      return null;
    }
    String compression = (method == "8") ? "deflate" : "none";
    return (originalLength, compression);
  }
}
