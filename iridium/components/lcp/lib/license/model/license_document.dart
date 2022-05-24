// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/mediatype.dart';

// The possible rel of Links.
class LicenseRel {
  static const LicenseRel hint = LicenseRel._("hint");
  static const LicenseRel publication = LicenseRel._("publication");
  static const LicenseRel self = LicenseRel._("self");
  static const LicenseRel support = LicenseRel._("support");
  static const LicenseRel status = LicenseRel._("status");
  final String val;

  const LicenseRel._(this.val);

  @override
  String toString() => 'LicenseRel{val: $val}';
}

/// Document that contains references to the various keys, links to related
/// external resources, rights and restrictions that are applied to the
/// Protected Publication, and user information.
class LicenseDocument {
  final String id;

  /// Date when the license was first issued.
  final DateTime issued;

  /// Date when the license was last updated.
  final DateTime updated;

  /// Unique identifier for the Provider (URI).
  final Uri provider;

  // Encryption object.
  final Encryption encryption;

  /// Used to associate the License Document with resources that are not
  /// locally available.
  final Links _links;
  final Rights rights;

  /// The user owning the License.
  final User user;

  /// Used to validate the license integrity.
  final Signature signature;
  final Map jsonObject;
  final String rawJson;
  final ByteData data;

  LicenseDocument._(
      this.id,
      this.issued,
      this.updated,
      this.provider,
      this.encryption,
      this._links,
      this.rights,
      this.user,
      this.signature,
      this.jsonObject,
      this.rawJson,
      this.data);

  factory LicenseDocument.parse(ByteData data) {
    Uint8List list =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String text = utf8.decode(list);
    Map jsonObject;
    try {
      jsonObject = json.decode(text);
    } on Exception {
      throw Exception(LcpParsingError.errorDescription(LcpParsingErrors.json));
    }
    String id;
    DateTime issued;
    Uri provider;
    try {
      id = jsonObject["id"];
      issued = DateTime.parse(jsonObject["issued"]);
      provider = Uri.parse(jsonObject["provider"]);
    } on Exception {
      throw Exception(LcpParsingError.errorDescription(LcpParsingErrors.json));
    }

    Encryption encryption = Encryption.parse(jsonObject["encryption"]);
    Links links = Links.parse(jsonObject["links"] as List);

    Rights? rights;
    if (jsonObject.containsKey("rights")) {
      rights = Rights.parse(jsonObject["rights"]);
    }

    User? user;
    if (jsonObject.containsKey("user")) {
      user = User.parse(jsonObject["user"]);
    }

    Signature signature = Signature.parse(jsonObject["signature"]);

    DateTime updated = issued;
    if (jsonObject.containsKey("updated")) {
      var parsedDateTime = DateTime.tryParse(jsonObject["updated"]);
      if (parsedDateTime != null) {
        updated = parsedDateTime;
      }
    }

    if (links.firstWithRel(LicenseRel.hint.val) == null) {
      throw Exception(LcpError.errorDescription(LcpErrorCase.hintLinkNotFound));
    }

    if (links.firstWithRel(LicenseRel.publication.val) == null) {
      throw Exception(
          LcpError.errorDescription(LcpErrorCase.publicationLinkNotFound));
    }
    // TODO What to do if user or rights is null? Can it happen?
    return LicenseDocument._(id, issued, updated, provider, encryption, links,
        rights!, user!, signature, jsonObject, text, data);
  }

  /// Returns the first link containing the given rel.
  ///
  /// - Parameter rel: The rel to look for.
  /// - Returns: The first link containing the rel.
  Link? link(LicenseRel rel, {MediaType? type}) =>
      _links.firstWithRel(rel.val, type: type);

  /// Returns all links containing the given rel.
  ///
  /// - Parameter rel: The rel to look for.
  /// - Returns: All links containing the rel.
  List<Link> links(LicenseRel rel, {MediaType? type}) =>
      _links.allWithRel(rel.val, type: type);

  static Link? findLink(List<Link> links, LicenseRel rel) =>
      links.firstWhereOrNull((element) => element.rel.contains(rel.val));

  String getHint() => encryption.userKey.textHint;

  String get description => 'License($id)';

  Uri url(LicenseRel rel,
      {MediaType? preferredType, Map<String, String> parameters = const {}}) {
    Link? l =
        link(rel, type: preferredType) ?? _links.firstWithRelAndNoType(rel.val);
    if (l == null) {
      throw LcpException.parsing.url(rel.val);
    }

    return l.urlWithParams(parameters: parameters);
  }

  @override
  String toString() =>
      'LicenseDocument{id: $id, issued: $issued, updated: $updated, '
      'provider: $provider, encryption: $encryption, links: $_links, '
      'rights: $rights, user: $user, signature: $signature, '
      'jsonObject: $jsonObject}';
}
