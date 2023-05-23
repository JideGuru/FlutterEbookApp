import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ebook_app/theme/theme_config.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'setKey.welltested_test.mocks.dart';

@GenerateMocks([Key, GlobalKey, NavigatorState, SharedPreferences])
void main() {
  late AppProvider appProvider;
  late MockKey mockKey;
  late MockGlobalKey<NavigatorState> mockNavigatorKey;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockKey = MockKey();
    mockNavigatorKey = MockGlobalKey<NavigatorState>();
    mockSharedPreferences = MockSharedPreferences();
    when(mockSharedPreferences.getString('theme')).thenReturn('light');
    when(mockSharedPreferences.setString('theme', any))
        .thenAnswer((_) async => true);
    appProvider = AppProvider(mockSharedPreferences);
  });

  test('Set key value', () {
    appProvider.setKey(mockKey);
    expect(appProvider.key, mockKey);
  });

  test('Notify listeners after setting key value', () {
    bool listenerCalled = false;
    appProvider.addListener(() {
      listenerCalled = true;
    });
    appProvider.setKey(mockKey);
    expect(listenerCalled, true);
  });

  test('Set navigator key value', () {
    appProvider.navigatorKey = mockNavigatorKey;
    expect(appProvider.navigatorKey, mockNavigatorKey);
  });

  test('Check if theme is set to light theme by default', () {
    expect(appProvider.theme, ThemeConfig.lightTheme);
  });

  test('Check if theme is set to dark theme after setting it', () {
    appProvider.theme = ThemeConfig.darkTheme;
    expect(appProvider.theme, ThemeConfig.darkTheme);
  });
}
