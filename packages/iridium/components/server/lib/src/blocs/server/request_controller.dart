// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:mno_server/mno_server.dart';
import 'package:universal_io/io.dart' as io;

/// A [RequestController] is used to process each request received by the
/// server.
class RequestController {
  /// List of [RequestHandler].
  final List<RequestHandler> handlers;

  /// Creates a [RequestController] instance with [handlers].
  RequestController(this.handlers);

  /// This method process the [request].
  ///
  /// It will try each [RequestHandler] from [handlers] to provide a response.
  /// If the [request] is not handled by any [handlers], it will send back a
  /// [HttpStatus.notFound] error.
  Future<T> onRequest<T extends Response>(
      int requestId, Request<T> request) async {
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    T response = request.response;
    String href = Uri.decodeFull(request.uri.toString());
    if (href.startsWith("/")) {
      href = href.substring(1);
    }

    try {
      for (RequestHandler handler in handlers) {
        if (await handler.handle(requestId, request, href)) {
          stopwatch.stop();
          // Fimber.d(
          //     "========= REQUEST HREF: $href, time: ${stopwatch.elapsedMilliseconds}ms");
          return response;
        }
      }

      response
        ..statusCode = io.HttpStatus.notFound
        ..write("NOT FOUND");
    } on Exception catch (e, stacktrace) {
      response.statusCode = io.HttpStatus.internalServerError;
      Fimber.d("Request error", ex: e, stacktrace: stacktrace);
    } finally {
      await response.flush();
      await response.close();
      // Fimber.d(
      //     "========= onRequest, HREF: $href, TOTAL TIME AFTER RESPONSE FLUSH: ${stopwatch.elapsedMilliseconds}ms");
    }
    return response;
  }
}
