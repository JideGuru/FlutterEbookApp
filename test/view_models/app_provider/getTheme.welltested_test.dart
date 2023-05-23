import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'getTheme.welltested_test.mocks.dart';

@GenerateMocks([ThemeData, SharedPreferences])
void main() {
  late AppProvider appProvider;
  late MockThemeData mockThemeData;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    when(mockSharedPreferences.getString('theme')).thenReturn('light');
    when(mockSharedPreferences.setString('theme', any))
        .thenAnswer((_) async => true);
    appProvider = AppProvider(mockSharedPreferences);
    mockThemeData = MockThemeData();
  });

  test('Get light theme', () {
    when(mockThemeData.primaryColor).thenReturn(Colors.blue);
    when(mockThemeData.accentColor).thenReturn(Colors.green);
    when(mockThemeData.textTheme).thenReturn(TextTheme());
    appProvider.theme = mockThemeData;
    expect(appProvider.getTheme('light'), mockThemeData);
  });

  test('Get dark theme', () {
    when(mockThemeData.primaryColor).thenReturn(Colors.red);
    when(mockThemeData.accentColor).thenReturn(Colors.yellow);
    when(mockThemeData.textTheme).thenReturn(TextTheme());
    appProvider.theme = mockThemeData;
    expect(appProvider.getTheme('dark'), mockThemeData);
  });

  test('Get default theme', () {
    when(mockThemeData.primaryColor).thenReturn(Colors.blue);
    when(mockThemeData.accentColor).thenReturn(Colors.green);
    when(mockThemeData.textTheme).thenReturn(TextTheme());
    appProvider.theme = mockThemeData;
    expect(appProvider.getTheme('default'), mockThemeData);
  });

  test('Get null theme', () {
    when(mockThemeData.primaryColor).thenReturn(Colors.blue);
    when(mockThemeData.accentColor).thenReturn(Colors.green);
    when(mockThemeData.textTheme).thenReturn(TextTheme());
    appProvider.theme = mockThemeData;
    expect(appProvider.getTheme(null), mockThemeData);
  });
}
