import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/util/flutter_toast.dart';
import 'package:flutter_ebook_app/view_models/genre_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'checkError.welltested_test.mocks.dart';

@GenerateMocks([Api, FlutterToastWrapper])
void main() {
  late GenreProvider genreProvider;
  late MockApi mockApi;
  late MockFlutterToastWrapper mockFlutterToastWrapper;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    mockApi = MockApi();
    mockFlutterToastWrapper = MockFlutterToastWrapper();
    genreProvider = GenreProvider();
    genreProvider.api = mockApi;
    genreProvider.flutterToastWrapper = mockFlutterToastWrapper;
    when(mockFlutterToastWrapper.showToast(
            msg: anyNamed('msg'),
            toastLength: anyNamed('toastLength'),
            timeInSecForIosWeb: anyNamed('timeInSecForIosWeb')))
        .thenAnswer((realInvocation) => Future.value(null));
  });

  test('checkError with connection error', () {
    final error = SocketException('Connection error');

    genreProvider.checkError(error);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.connectionError);
  });

  test('checkError with other error', () {
    final error = Exception('Some other error');

    genreProvider.checkError(error);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.error);
  });

  test('checkError with no error', () {
    final error = null;

    genreProvider.checkError(error);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.loading);
  });
}
