// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:intl/locale.dart';

class LocaleUtils {
  static List<String> get supportedLanguageCodes => [
        'es',
        'en',
        'fr',
        'de',
      ];

  static bool isSupported(Locale locale) =>
      supportedLanguageCodes.contains(locale.languageCode);
}
