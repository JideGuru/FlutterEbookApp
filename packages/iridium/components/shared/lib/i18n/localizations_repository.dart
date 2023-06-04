// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:intl/locale.dart';

mixin LocalizationsRepository {
  String getMessage(String name, List<Object>? args);
}

/// This is an abstraction to avoid a direct dependency to Flutter
abstract class SimpleLocalizationDelegate<T> {
  const SimpleLocalizationDelegate();

  FutureOr<T> Function(String locale) get builder;

  Future<bool> initializeMessages(String localeName);

  bool shouldReload(covariant SimpleLocalizationDelegate<T> old) => false;

  bool isSupported(Locale locale);
}
