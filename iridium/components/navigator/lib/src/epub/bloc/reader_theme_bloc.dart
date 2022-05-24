// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mno_navigator/epub.dart';

class ReaderThemeBloc extends Bloc<ReaderThemeEvent, ReaderThemeState> {
  ReaderThemeBloc(ReaderThemeConfig? defaultTheme)
      : super(
            ReaderThemeState(defaultTheme ?? ReaderThemeConfig.defaultTheme)) {
    on<ReaderThemeEvent>(
        (event, emit) => emit(ReaderThemeState(event.readerTheme.copy())));
  }

  ReaderThemeConfig get currentTheme => state.readerTheme;
}

@immutable
class ReaderThemeEvent extends Equatable {
  final ReaderThemeConfig readerTheme;

  const ReaderThemeEvent(this.readerTheme);

  @override
  List<Object> get props => [readerTheme];
}

@immutable
class ReaderThemeState extends Equatable {
  final ReaderThemeConfig readerTheme;

  const ReaderThemeState(this.readerTheme);

  @override
  List<Object> get props => [readerTheme];
}
