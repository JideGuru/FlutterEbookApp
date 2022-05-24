// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

enum LcpParsingErrors {
  json,
  date,
  link,
  updated,
  updatedDate,
  encryption,
  signature
}

class LcpParsingError {
  static String errorDescription(LcpParsingErrors error) {
    switch (error) {
      case LcpParsingErrors.date:
        return "Invalid ISO8601 dates found.";
      case LcpParsingErrors.link:
        return "Invalid Link found in the JSON.";
      case LcpParsingErrors.encryption:
        return "Invalid Encryption object.";
      case LcpParsingErrors.signature:
        return "Invalid License Document Signature.";
      case LcpParsingErrors.updated:
        return "Invalid Updated object.";
      case LcpParsingErrors.updatedDate:
        return "Invalid Updated object date.";
      case LcpParsingErrors.json:
      default:
        return "The JSON is no representing a valid Status Document.";
    }
  }
}
