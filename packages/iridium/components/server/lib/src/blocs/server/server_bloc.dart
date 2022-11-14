// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_server/src/blocs/server/request_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

/// A ServerBloc is used to start/stop a server instance.
///
/// During the time that the server is up, requests are allowed to be processed.
class ServerBloc extends Bloc<ServerEvent, ServerState> {
  static int _serverPort = 4040;
  HttpServer? _server;
  RequestController? _requestController;
  late BehaviorSubject<String> _addressSubject;

  /// Creates a [ServerBloc] with a [ServerNotStarted] state.
  ServerBloc() : super(ServerNotStarted()) {
    _addressSubject = BehaviorSubject<String>.seeded("");
    on<StartServer>(_onStartServer);
    on<ShutdownServer>(_onShutdownServer);
  }

  /// Returns the current address of the server.
  ///
  /// Check if the current state is [ServerStarted], to know if the address is
  /// currently used.
  String get address => _addressSubject.value;

  Future<void> _onStartServer(
      StartServer event, Emitter<ServerState> emit) async {
    try {
      HttpServer? server = await _initServer();
      if (server != null) {
        _server = server;
        _requestController = RequestController(event.handlers);
        Fimber.d("serverPort: ${server.port}, ${server.address.host}");
        _addressSubject.add("http://${server.address.address}:${server.port}");
        unawaited(_runServer(server));
      }
      emit(ServerStarted(address));
    } on Exception catch (e, stacktrace) {
      Fimber.d("ERROR", ex: e, stacktrace: stacktrace);
      _server = null;
      emit(ServerNotStarted());
    }
  }

  Future<HttpServer?> _initServer() async {
    HttpServer? server;
    while (server == null) {
      try {
        server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
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
      await _server?.close(force: true);
      _server = null;
      _addressSubject.add("");
      emit(ServerClosed());
    }
  }

  Future<void> _runServer(HttpServer server) async {
    int requestId = 0;
    await for (HttpRequest request in server) {
      int currentRequestId = requestId++;
      _requestController!.onRequest(currentRequestId, request);
    }
  }
}
