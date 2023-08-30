// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mno_server/src/blocs/server/handlers/request_handler.dart';
import 'package:mno_server/src/blocs/server/server_bloc.dart';

/// Root class for [ServerBloc] events.
@immutable
abstract class ServerEvent extends Equatable {}

/// This event is sent to start the server.
class StartServer extends ServerEvent {
  /// List of [RequestHandler] that will be used by the server to send back
  /// resources.
  final List<RequestHandler> handlers;

  /// Creates a [StartServer] instance with [handlers].
  StartServer(this.handlers);

  @override
  List<Object> get props => [handlers];

  @override
  String toString() => 'StartServer';
}

/// This event is sent to shutdown the server.
class ShutdownServer extends ServerEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ShutdownServer';
}
