// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mno_lcp/i18n/localizations/messages_all.dart';
import 'package:mno_shared/i18n/locale_utils.dart';
import 'package:mno_shared/i18n/localizations_repository.dart';
import 'package:multiple_localization/multiple_localization.dart';

class LcpLocalizations implements LocalizationsRepository {
  static const LocalizationsDelegate<LcpLocalizations> delegate =
      _LcpLocalizationsDelegate();

  LcpLocalizations(this.locale);

  final String locale;

  static LcpLocalizations? of(BuildContext context) =>
      Localizations.of<LcpLocalizations>(context, LcpLocalizations);

  @override
  String getMessage(String name, List<Object>? args) => Intl.message(
        name,
        name: name,
        args: args,
        locale: locale.toString(),
      );

  String get r2LcpDialogContinue => Intl.message(
        'Continue',
        name: 'r2_lcp_dialog_continue',
        locale: locale.toString(),
      );

  String get r2LcpDialogCancel => Intl.message(
        'Cancel',
        name: 'r2_lcp_dialog_cancel',
        locale: locale.toString(),
      );

  String get r2LcpDialogReasonPassphraseNotFound => Intl.message(
        'Passphrase Required',
        name: 'r2_lcp_dialog_reason_passphraseNotFound',
        locale: locale.toString(),
      );

  String get r2LcpDialogReasonInvalidPassphrase => Intl.message(
        'Incorrect Passphrase',
        name: 'r2_lcp_dialog_reason_invalidPassphrase',
        locale: locale.toString(),
      );

  String r2LcpDialogPrompt(String provider) => Intl.message(
        "This publication is protected by Readium LCP.\n"
        "In order to open it, we need to know the passphrase required by: \n$provider.\n"
        "To help you remember it, the following hint is available:",
        name: 'r2_lcp_dialog_prompt',
        args: [provider],
        locale: locale.toString(),
      );

  String get r2LcpDialogForgotPassphrase => Intl.message(
        'Forgot your passphrase?',
        name: 'r2_lcp_dialog_forgotPassphrase',
        locale: locale.toString(),
      );

  String get r2LcpDialogHelp => Intl.message(
        'Need more help?',
        name: 'r2_lcp_dialog_help',
        locale: locale.toString(),
      );

  String get r2LcpDialogSupport => Intl.message(
        'Support',
        name: 'r2_lcp_dialog_support',
        locale: locale.toString(),
      );

  String get r2LcpDialogSupportWeb => Intl.message(
        'Website',
        name: 'r2_lcp_dialog_support_web',
        locale: locale.toString(),
      );

  String get r2LcpDialogSupportPhone => Intl.message(
        'Phone',
        name: 'r2_lcp_dialog_support_phone',
        locale: locale.toString(),
      );

  String get r2LcpDialogSupportMail => Intl.message(
        'Mail',
        name: 'r2_lcp_dialog_support_mail',
        locale: locale.toString(),
      );
}

class _LcpLocalizationsDelegate
    extends LocalizationsDelegate<LcpLocalizations> {
  const _LcpLocalizationsDelegate();

  @override
  Future<LcpLocalizations> load(Locale locale) => MultipleLocalizations.load(
      initializeMessages, locale, (l) => LcpLocalizations(l));

  @override
  bool shouldReload(_LcpLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) =>
      LocaleUtils.supportedLanguageCodes.contains(locale.languageCode);
}
