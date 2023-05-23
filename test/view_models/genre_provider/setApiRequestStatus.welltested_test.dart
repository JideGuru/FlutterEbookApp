import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/util/flutter_toast.dart';
import 'package:flutter_ebook_app/view_models/genre_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'setApiRequestStatus.welltested_test.mocks.dart';

@GenerateMocks([ScrollController, FlutterToastWrapper])
void main() {
  late GenreProvider genreProvider;
  late MockScrollController mockScrollController;
  late MockFlutterToastWrapper mockFlutterToastWrapper;

  setUp(() {
    genreProvider = GenreProvider();
    mockScrollController = MockScrollController();
    mockFlutterToastWrapper = MockFlutterToastWrapper();
    genreProvider.controller = mockScrollController;
    genreProvider.flutterToastWrapper = mockFlutterToastWrapper;
    when(mockFlutterToastWrapper.showToast(
            msg: anyNamed('msg'),
            toastLength: anyNamed('toastLength'),
            timeInSecForIosWeb: anyNamed('timeInSecForIosWeb')))
        .thenAnswer((realInvocation) => Future.value(null));
  });

  test('setApiRequestStatus with loading status', () {
    genreProvider.setApiRequestStatus(APIRequestStatus.loading);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.loading);
  });

  test('setApiRequestStatus with success status', () {
    genreProvider.setApiRequestStatus(APIRequestStatus.loaded);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.loaded);
  });

  test('setApiRequestStatus with error status', () {
    genreProvider.setApiRequestStatus(APIRequestStatus.error);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.error);
  });

  test('setApiRequestStatus with connection error status', () {
    genreProvider.setApiRequestStatus(APIRequestStatus.connectionError);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.connectionError);
  });
}
