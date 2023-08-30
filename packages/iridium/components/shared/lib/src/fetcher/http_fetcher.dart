// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/io.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

class HttpFetcher extends Fetcher {
  final String rootHref;

  final List<Resource> _openedResources = [];

  HttpFetcher(this.rootHref);

  @override
  Future<List<Link>> links() async => [Link(href: Uri.parse(rootHref).path)];

  @override
  Resource get(Link link) {
    String linkHref = link.href.addPrefix("./");
    Uri url = Uri.parse(rootHref).resolve(linkHref);
    return HttpResource(url, link);
  }

  @override
  Future<void> close() async {
    await Future.wait(_openedResources.mapNotNull((res) => res.close()));
    _openedResources.clear();
  }
}

class HttpResource extends Resource {
  final Uri url;
  final Link _link;

  static HashMap<Uri, ResourceTry<http.Response>> caching =
      HashMap<Uri, ResourceTry<http.Response>>();

  HttpResource(this.url, this._link);

  @override
  Future<Link> link() async => _link;

  Future<ResourceTry<http.Response>> get response async =>
      caching[url] ??= await catching(() async {
        Uri uri = Uri.parse("$url");
        return http.get(uri, headers: {
          'Access-Control-Allow-Origin': 'http://localhost:49430',
          'Access-Control-Allow-Methods':
              'GET, POST, PATCH, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
        });
      });

  @override
  Future<void> close() async {}

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) =>
      catching(() => _readSync(range));

  Future<ByteData> _readSync(IntRange? range) async {
    http.Response res = (await response).getOrThrow();
    if (range == null) {
      return ByteData.sublistView(res.bodyBytes);
    }
    IntRange range2 = IntRange(max(0, range.first),
        min(range.last, res.contentLength ?? res.bodyBytes.lengthInBytes));

    if (range2.isEmpty) {
      return ByteData(0);
    }

    return ByteData.sublistView(
        res.bodyBytes.sublist(range2.first, range2.last));
  }

  @override
  Future<ResourceTry<int>> length() async {
    int? length = await metadataLength;
    if (length != null) {
      return ResourceTry.success(length);
    }
    return read()
        .then((data) => data.map((byteData) => byteData.lengthInBytes));
  }

  Future<int?> get metadataLength async {
    try {
      http.Response res = (await response).getOrThrow();
      return res.contentLength ?? res.bodyBytes.lengthInBytes;
    } on Exception {
      return Future.value();
    }
  }

  @override
  String toString() => "HttpResource($url)";

  static Future<ResourceTry<T>> catching<T>(
      Future<T> Function() closure) async {
    try {
      T value = await closure();
      return ResourceTry.success(value);
    } on http.ClientException catch (_) {
      return ResourceTry<T>.failure(ResourceException.notFound);
    } on FileNotFoundException catch (_) {
      return ResourceTry<T>.failure(ResourceException.notFound);
    } on Exception catch (e) {
      return ResourceTry<T>.failure(ResourceException.wrap(e));
    } on OutOfMemoryError catch (e) {
      return ResourceTry<T>.failure(ResourceException.wrap(e));
    } catch (e) {
      return ResourceTry<T>.failure(ResourceException.wrap(e));
    }
  }
}
