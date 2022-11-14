// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:mno_shared/i18n/locale_utils.dart';
import 'package:mno_shared/i18n/localizations/messages_all.dart' as m;
import 'package:mno_shared/i18n/localizations_repository.dart';

class ReaderSharedLocalizations implements LocalizationsRepository {
  static const SimpleLocalizationDelegate<ReaderSharedLocalizations> delegate =
      _ReaderSharedLocalizationsDelegate();

  ReaderSharedLocalizations(this.locale);

  final String locale;

  @override
  String getMessage(String name, List<Object>? args) => Intl.message(
        name,
        name: name,
        args: args,
        locale: locale.toString(),
      );

  String get r2SharedPublicationOpeningExceptionError => Intl.message(
        'Error opening document',
        name: 'r2_shared_publication_opening_exception_error',
        locale: locale.toString(),
      );

  String get r2SharedPublicationOpeningExceptionUnsupportedFormat =>
      Intl.message(
        'Format not supported',
        name: 'r2_shared_publication_opening_exception_unsupported_format',
        locale: locale.toString(),
      );

  String get r2SharedPublicationOpeningExceptionNotFound => Intl.message(
        'File not found',
        name: 'r2_shared_publication_opening_exception_not_found',
        locale: locale.toString(),
      );

  String get r2SharedPublicationOpeningExceptionParsingFailed => Intl.message(
        'The file is corrupted and can\'t be opened',
        name: 'r2_shared_publication_opening_exception_parsing_failed',
        locale: locale.toString(),
      );

  String get r2SharedPublicationOpeningExceptionForbidden => Intl.message(
        'You are not allowed to open this publication',
        name: 'r2_shared_publication_opening_exception_forbidden',
        locale: locale.toString(),
      );

  String get r2SharedPublicationOpeningExceptionUnavailable => Intl.message(
        'Not available, please try again later',
        name: 'r2_shared_publication_opening_exception_unavailable',
        locale: locale.toString(),
      );

  String get r2SharedPublicationOpeningExceptionIncorrectCredentials =>
      Intl.message(
        'Provided credentials were incorrect',
        name: 'r2_shared_publication_opening_exception_incorrect_credentials',
        locale: locale.toString(),
      );

  String get r2SharedResourceExceptionBadRequest => Intl.message(
        'Invalid request which can\'t be processed',
        name: 'r2_shared_resource_exception_bad_request',
        locale: locale.toString(),
      );

  String get r2SharedResourceExceptionNotFound => Intl.message(
        'Resource not found',
        name: 'r2_shared_resource_exception_not_found',
        locale: locale.toString(),
      );

  String get r2SharedResourceExceptionForbidden => Intl.message(
        'You are not allowed to access the resource',
        name: 'r2_shared_resource_exception_forbidden',
        locale: locale.toString(),
      );

  String get r2SharedResourceExceptionUnavailable => Intl.message(
        'The resource is currently unavailable, please try again later',
        name: 'r2_shared_resource_exception_unavailable',
        locale: locale.toString(),
      );

  String get r2SharedResourceExceptionOutOfMemory => Intl.message(
        'The resource is too large to be read on this device',
        name: 'r2_shared_resource_exception_out_of_memory',
        locale: locale.toString(),
      );

  String get r2SharedResourceExceptionCancelled => Intl.message(
        'The request was cancelled',
        name: 'r2_shared_resource_exception_cancelled',
        locale: locale.toString(),
      );

  String get r2SharedResourceExceptionOther => Intl.message(
        'A service error occurred',
        name: 'r2_shared_resource_exception_other',
        locale: locale.toString(),
      );
}

class _ReaderSharedLocalizationsDelegate
    extends SimpleLocalizationDelegate<ReaderSharedLocalizations> {
  const _ReaderSharedLocalizationsDelegate();

  @override
  FutureOr<ReaderSharedLocalizations> Function(String locale) get builder =>
      (l) => ReaderSharedLocalizations(l);

  @override
  bool isSupported(Locale locale) => LocaleUtils.isSupported(locale);

  @override
  Future<bool> initializeMessages(String localeName) =>
      m.initializeMessages(localeName);
}
