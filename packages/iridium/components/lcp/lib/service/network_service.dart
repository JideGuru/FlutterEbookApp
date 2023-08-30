// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' hide Link;

class NetworkException implements Exception {
  final int? status;
  final Exception? cause;

  NetworkException({this.status, this.cause});

  @override
  String toString() => "Network failure with status $status, $cause";
}

class Method {
  final String rawValue;
  static const Method get = Method._("get");
  static const Method post = Method._("post");
  static const Method put = Method._("put");

  const Method._(this.rawValue);

// static Method find(String rawValue) => [get, post, put]
//     .firstWhere((it) => it.rawValue == rawValue, orElse: () => null);
}

class NetworkService {
  Future<Try<ByteData, NetworkException>> fetch(String url,
      {Method method = Method.get,
      Map<String, String> parameters = const {},
      Duration? timeout}) async {
    try {
      Uri uri = Uri.parse(url);
      Uri uriWithParams = Uri(
        scheme: uri.scheme,
        userInfo: uri.userInfo,
        host: uri.host,
        port: uri.port,
        fragment: uri.fragment,
        path: uri.path,
        queryParameters: Map.of(parameters)..addAll(uri.queryParameters),
      );

      HttpClient httpClient = HttpClient();
      httpClient.connectionTimeout = timeout;
      HttpClientResponse response = await httpClient
          .openUrl(method.rawValue, uriWithParams)
          .then((request) => request.close());

      int status = response.statusCode;
      if (status >= 400) {
        return Try.failure(NetworkException(status: status));
      } else {
        Completer<Uint8List> completer = Completer<Uint8List>();
        List<int> contents = [];
        response.listen((c) => contents.addAll(c),
            onDone: () => completer.complete(Uint8List.fromList(contents)));
        return completer.future
            .then((uint8List) => ByteData.sublistView(uint8List))
            .then((bytes) => Try.success(bytes));
      }
    } on Exception catch (e, stacktrace) {
      Fimber.e("fetch ERROR", ex: e, stacktrace: stacktrace);
      return Try.failure(NetworkException(status: null, cause: e));
    }
  }

  Future<MediaType?> download(Uri url, File destination,
      {String? mediaType}) async {
    try {
      HttpClientResponse response =
          await HttpClient().getUrl(url).then((request) => request.close());
      if (response.statusCode >= 400) {
        throw LcpException.network(
            NetworkException(status: response.statusCode));
      }
      List<String> extensions =
          [p.extension(url.path)].where((ext) => ext.isNotEmpty).toList();
      return response.pipe(destination.openWrite()).then((_) => MediaType.of(
          mediaTypes: [mediaType].whereType<String>().toList(),
          fileExtensions: extensions));
    } on Exception catch (e, stacktrace) {
      Fimber.e("download ERROR", ex: e, stacktrace: stacktrace);
      throw LcpException.network(e);
    }
  }
}
