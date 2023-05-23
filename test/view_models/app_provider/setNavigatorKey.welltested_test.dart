import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'setNavigatorKey.welltested_test.mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([NavigatorState, SharedPreferences],
    customMocks: [MockSpec<GlobalKey<NavigatorState>>()])
void main() {
  late AppProvider appProvider;
  late MockGlobalKey mockGlobalKey;
  late MockNavigatorState mockNavigatorState;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockGlobalKey = MockGlobalKey();
    mockNavigatorState = MockNavigatorState();
    mockSharedPreferences = MockSharedPreferences();
    when(mockSharedPreferences.getString('theme')).thenReturn('light');
    when(mockSharedPreferences.setString('theme', any))
        .thenAnswer((_) async => true);
    appProvider = AppProvider(mockSharedPreferences);
  });

  test('Set navigator key', () {
    appProvider.setNavigatorKey(mockGlobalKey);
    expect(appProvider.navigatorKey, mockGlobalKey);
  });

  test('Notify listeners after setting navigator key', () {
    bool listenerCalled = false;
    appProvider.addListener(() {
      listenerCalled = true;
    });
    appProvider.setNavigatorKey(mockGlobalKey);
    expect(listenerCalled, true);
  });

  test('Set navigator state', () {
    when(mockGlobalKey.currentState).thenReturn(mockNavigatorState);
    appProvider.setNavigatorKey(mockGlobalKey);
    expect(appProvider.navigatorKey.currentState, mockNavigatorState);
  });

  test('Notify listeners after setting navigator state', () {
    when(mockGlobalKey.currentState).thenReturn(mockNavigatorState);
    bool listenerCalled = false;
    appProvider.addListener(() {
      listenerCalled = true;
    });
    appProvider.setNavigatorKey(mockGlobalKey);
    expect(listenerCalled, true);
  });
}
