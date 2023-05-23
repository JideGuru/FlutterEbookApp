import 'package:mockito/annotations.dart';

import 'checkTheme.welltested_test.mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/theme/theme_config.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([ThemeData, SharedPreferences])
void main() {
  late AppProvider appProvider;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    mockSharedPreferences = MockSharedPreferences();
    when(mockSharedPreferences.getString('theme')).thenReturn('light');
    when(mockSharedPreferences.setString('theme', any))
        .thenAnswer((_) async => true);
    appProvider = AppProvider(mockSharedPreferences);
  });

  test('Check theme with light theme stored in shared preferences', () async {
    when(mockSharedPreferences.getString('theme')).thenReturn('light');

    final result = await appProvider.checkTheme();

    expect(result, ThemeConfig.lightTheme);
    expect(appProvider.theme, ThemeConfig.lightTheme);
  });

  test('Check theme with dark theme stored in shared preferences', () async {
    when(mockSharedPreferences.getString('theme')).thenReturn('dark');

    final result = await appProvider.checkTheme();

    expect(result, ThemeConfig.darkTheme);
    expect(appProvider.theme, ThemeConfig.darkTheme);
  });

  test('Check theme with no theme stored in shared preferences', () async {
    when(mockSharedPreferences.getString('theme')).thenReturn(null);

    final result = await appProvider.checkTheme();

    expect(result, ThemeConfig.lightTheme);
    expect(appProvider.theme, ThemeConfig.lightTheme);
  });
}
