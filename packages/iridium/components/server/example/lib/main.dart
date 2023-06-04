// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:universal_io/io.dart' hide Link;

import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/mediatype.dart';

void main() {
  ServerBloc serverBloc = ServerBloc();
  serverBloc.stream.listen((event) async {
    if (event is ServerStarted) {
      HttpClient client = HttpClient();
      Uri url = Uri.parse("${event.address}/test");
      var response = await client
          .getUrl(url)
          .then((request) => request.close())
          .then((response) => response.transform(Utf8Decoder()).first);
      print("response: $response");
      serverBloc.add(ShutdownServer());
    }
  });
  serverBloc.add(StartServer([_HelloWorldRequestHandler()]));
}

class _HelloWorldRequestHandler extends RequestHandler {
  @override
  Future<bool> handle(int requestId, Request request, String href) async {
    await sendData(
      request,
      data: "Hello world".codeUnits,
      mediaType: MediaType.text,
    );

    return true;
  }
}
