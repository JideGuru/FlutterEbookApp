// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mno_navigator/epub.dart';

class ViewerSettingsBloc
    extends Bloc<ViewerSettingsEvent, ViewerSettingsState> {
  ViewerSettingsBloc(EpubReaderState _readerState)
      : super(ViewerSettingsState(
            ViewerSettings.defaultSettings(fontSize: _readerState.fontSize))) {
    on<IncrFontSizeEvent>((event, emit) =>
        emit(ViewerSettingsState(state.viewerSettings.incrFontSize())));
    on<DecrFontSizeEvent>((event, emit) =>
        emit(ViewerSettingsState(state.viewerSettings.decrFontSize())));
  }

  ViewerSettings get viewerSettings => state.viewerSettings;
}

@immutable
abstract class ViewerSettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class IncrFontSizeEvent extends ViewerSettingsEvent {
  @override
  String toString() => 'IncrFontSizeEvent {}';
}

class DecrFontSizeEvent extends ViewerSettingsEvent {
  @override
  String toString() => 'DecrFontSizeEvent {}';
}

@immutable
class ViewerSettingsState extends Equatable {
  final ViewerSettings viewerSettings;

  const ViewerSettingsState(this.viewerSettings);

  @override
  List<Object> get props => [viewerSettings];

  @override
  String toString() =>
      'ViewerSettingsState { viewerSettings: $viewerSettings }';
}
