import 'package:flutter_ebook_app/src/features/common/constants/shared_preferences_key.dart';
import 'package:flutter_ebook_app/src/features/common/data/notifiers/current_app_theme/current_app_theme_state_notifier.dart';
import 'package:flutter_ebook_app/src/features/common/data/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentAppThemeService {
  final SharedPreferences? _sharedPreferences;

  const CurrentAppThemeService(this._sharedPreferences);

  Future<bool> setCurrentAppTheme(bool isDarkMode) =>
      _sharedPreferences!.setBool(
        SharedPreferencesKeys.isDarkMode,
        isDarkMode,
      );

  CurrentAppTheme getCurrentAppTheme() {
    final isDarkMode =
        _sharedPreferences!.getBool(SharedPreferencesKeys.isDarkMode);
    return (isDarkMode ?? false) ? CurrentAppTheme.dark : CurrentAppTheme.light;
  }

  bool getIsDarkMode() {
    final isDarkMode =
        _sharedPreferences!.getBool(SharedPreferencesKeys.isDarkMode);
    return (isDarkMode ?? false);
  }
}

final currentAppThemeServiceProvider = Provider<CurrentAppThemeService>(
  (ref) {
    return CurrentAppThemeService(ref.watch(sharedPreferencesProvider));
  },
);
