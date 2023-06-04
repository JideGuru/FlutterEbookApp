// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_server/src/blocs/server/request_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart' as io hide Link;

/// A ServerBloc is used to start/stop a server instance.
///
/// During the time that the server is up, requests are allowed to be processed.
class ServerBloc extends Bloc<ServerEvent, ServerState> {
  static int _serverPort = 4040;
  int requestId = 0;
  bool startHttpServer;
  io.HttpServer? _server;
  RequestController? _requestController;
  late BehaviorSubject<String> _addressSubject;

  /// Creates a [ServerBloc] with a [ServerNotStarted] state.
  ServerBloc({this.startHttpServer = false}) : super(ServerNotStarted()) {
    _addressSubject = BehaviorSubject<String>.seeded("");
    on<StartServer>(_onStartServer);
    on<ShutdownServer>(_onShutdownServer);
  }

  /// Returns the current address of the server.
  ///
  /// Check if the current state is [ServerStarted], to know if the address is
  /// currently used.
  String get address => _addressSubject.value;

  @override
  Future<void> close() async {
    await _shutdownServer();
    return super.close();
  }

  Future<void> _onStartServer(
      StartServer event, Emitter<ServerState> emit) async {
    try {
      for (RequestHandler handler in event.handlers) {
        await handler.init();
      }
      _requestController = RequestController(event.handlers);
      if (startHttpServer) {
        io.HttpServer? server = await _initServer();
        if (server != null) {
          _server = server;
          Fimber.d("serverPort: ${server.port}, ${server.address.host}");
          _addressSubject
              .add("http://${server.address.address}:${server.port}");
          unawaited(_runServer(server));
        }
      } else {
        _addressSubject.add(
            "http://${io.InternetAddress.loopbackIPv4.address}:$_serverPort");
      }
      emit(ServerStarted(address));
    } on Exception catch (e, stacktrace) {
      Fimber.d("ERROR", ex: e, stacktrace: stacktrace);
      _server = null;
      emit(ServerNotStarted());
    }
  }

  Future<io.HttpServer?> _initServer() async {
    // Could start many servers with the "shared" param added to bind !
    // See https://groups.google.com/a/dartlang.org/g/misc/c/Ju4f2d5ziwE
    // and https://github.com/costajob/app-servers/pull/23/commits/4f58ae2d578e3283b534e35821485d0d6c85c862
    io.HttpServer? server;
    while (server == null) {
      try {
        server = await io.HttpServer.bind(
          io.InternetAddress.loopbackIPv4,
          _serverPort,
        );
      } on Exception catch (e, stacktrace) {
        Fimber.d("ERROR", ex: e, stacktrace: stacktrace);
      }
      _serverPort++;
    }
    return server;
  }

  Future<void> _onShutdownServer(
      ShutdownServer event, Emitter<ServerState> emit) async {
    if (state is ServerStarted) {
      await _shutdownServer();
      emit(ServerClosed());
    }
  }

  Future<void> _shutdownServer() async {
    if (_requestController != null) {
      for (RequestHandler handler in _requestController!.handlers) {
        handler.dispose();
      }
    }
    await _server?.close(force: true);
    _requestController = null;
    _server = null;
    _addressSubject.add("");
  }

  Future<void> _runServer(io.HttpServer server) async {
    await for (io.HttpRequest request in server) {
      onRequest(HttpRequest(request));
    }
  }

  Future<T> onRequest<T extends Response>(Request<T> request) =>
      _requestController!.onRequest(requestId++, request).catchError((ex, st) {
        Fimber.d("ERROR", ex: ex, stacktrace: st);
      });
}
