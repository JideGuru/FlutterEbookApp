import 'dart:async';

import 'package:flutter_ebook_app/src/features/common/data/services/current_app_theme_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_app_theme_notifier.g.dart';

@riverpod
class CurrentAppThemeNotifier extends _$CurrentAppThemeNotifier {
  late CurrentAppThemeService _currentAppThemeService;

  CurrentAppThemeNotifier() : super();

  Future<void> updateCurrentAppTheme(bool isDarkMode) async {
    final success =
        await _currentAppThemeService.setCurrentAppTheme(isDarkMode);

    if (success) {
      state = AsyncValue.data(
        isDarkMode ? CurrentAppTheme.dark : CurrentAppTheme.light,
      );
    }
  }

  @override
  FutureOr<CurrentAppTheme> build() {
    _currentAppThemeService = ref.read(currentAppThemeServiceProvider);
    return _currentAppThemeService.getCurrentAppTheme();
  }
}

enum CurrentAppTheme { light, dark }
