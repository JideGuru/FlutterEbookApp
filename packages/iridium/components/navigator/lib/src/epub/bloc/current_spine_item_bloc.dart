// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class CurrentSpineItemBloc
    extends Bloc<CurrentSpineItemEvent, CurrentSpineItemState> {
  CurrentSpineItemBloc() : super(const CurrentSpineItemState(0)) {
    on<CurrentSpineItemEvent>(
        (event, emit) => emit(CurrentSpineItemState(event.spineItemIdx)));
  }
}

@immutable
class CurrentSpineItemEvent extends Equatable {
  final int spineItemIdx;

  const CurrentSpineItemEvent(this.spineItemIdx);

  @override
  List<Object> get props => [spineItemIdx];

  @override
  String toString() => 'CurrentSpineItemEvent {spineItemIdx: $spineItemIdx}';
}

@immutable
class CurrentSpineItemState extends Equatable {
  final int spineItemIdx;

  const CurrentSpineItemState(this.spineItemIdx);

  @override
  List<Object> get props => [spineItemIdx];

  @override
  String toString() => 'CurrentSpineItemState {spineItemIdx: $spineItemIdx}';
}
