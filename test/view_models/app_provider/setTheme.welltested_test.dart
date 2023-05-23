import 'package:mockito/annotations.dart';

import 'setTheme.welltested_test.mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/theme/theme_config.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late AppProvider appProvider;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    when(mockSharedPreferences.getString('theme')).thenReturn('light');
    when(mockSharedPreferences.setString('theme', any))
        .thenAnswer((_) async => true);
    appProvider = AppProvider(mockSharedPreferences);
  });

  test('Set theme to light theme', () async {
    when(mockSharedPreferences.setString('theme', 'light'))
        .thenAnswer((_) => Future.value(true));
    appProvider.setTheme(ThemeConfig.lightTheme, 'light');
    expect(appProvider.theme, ThemeConfig.lightTheme);
  });

  test('Set theme to dark theme', () async {
    when(mockSharedPreferences.setString('theme', 'dark'))
        .thenAnswer((_) => Future.value(true));
    appProvider.setTheme(ThemeConfig.darkTheme, 'dark');
    expect(appProvider.theme, ThemeConfig.darkTheme);
  });

  test('Set theme to custom theme', () async {
    final customTheme = ThemeData(primaryColor: Colors.green);
    when(mockSharedPreferences.setString('theme', 'custom'))
        .thenAnswer((_) => Future.value(true));
    appProvider.setTheme(customTheme, 'custom');
    expect(appProvider.theme, customTheme);
  });

  test('Notify listeners after setting theme', () async {
    when(mockSharedPreferences.setString('theme', 'light'))
        .thenAnswer((_) => Future.value(true));
    bool listenerCalled = false;
    appProvider.addListener(() {
      listenerCalled = true;
    });
    appProvider.setTheme(ThemeConfig.lightTheme, 'light');
    await Future.delayed(Duration(milliseconds: 100));
    expect(listenerCalled, true);
  });
}
