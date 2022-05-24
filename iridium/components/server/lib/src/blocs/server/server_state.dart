// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mno_server/src/blocs/server/server_bloc.dart';

/// Root class for [ServerBloc] states.
@immutable
abstract class ServerState extends Equatable {
  @override
  List<Object> get props => [];
}

/// This is the state when the server has been started.
class ServerStarted extends ServerState {
  /// This is the String representation of the server [address].
  final String address;

  /// Creates a [ServerStarted] instance with [address].
  ServerStarted(this.address);

  @override
  String toString() => 'ServerStarted {address: $address}';
}

/// This is the state for when the server has been closed.
class ServerClosed extends ServerState {
  @override
  String toString() => 'ServerClosed';
}

/// This is the default state, before the server has been started.
class ServerNotStarted extends ServerState {
  @override
  String toString() => 'ServerNotStarted';
}
