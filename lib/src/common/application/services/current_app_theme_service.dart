import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentAppThemeService {
  final SharedPreferences? _sharedPreferences;

  const CurrentAppThemeService(this._sharedPreferences);

  Future<bool> setCurrentAppTheme(bool isDarkMode) =>
      _sharedPreferences!.setBool(
        isDarkModeKey,
        isDarkMode,
      );

  CurrentAppTheme getCurrentAppTheme() {
    final isDarkMode = _sharedPreferences!.getBool(isDarkModeKey);
    return (isDarkMode ?? false) ? CurrentAppTheme.dark : CurrentAppTheme.light;
  }

  bool getIsDarkMode() {
    final isDarkMode = _sharedPreferences!.getBool(isDarkModeKey);
    return isDarkMode ?? false;
  }
}

final currentAppThemeServiceProvider = Provider<CurrentAppThemeService>(
  (ref) {
    return CurrentAppThemeService(ref.watch(sharedPreferencesProvider));
  },
);
