import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/util/flutter_toast.dart';
import 'package:flutter_ebook_app/view_models/genre_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'getFeed.welltested_test.mocks.dart';

@GenerateMocks([CategoryFeed, Api, Feed, FlutterToastWrapper])
void main() {
  late GenreProvider genreProvider;
  late MockCategoryFeed mockCategoryFeed;
  late MockFeed mockFeed;
  late MockApi mockApi;
  late MockFlutterToastWrapper mockFlutterToastWrapper;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    mockCategoryFeed = MockCategoryFeed();
    mockFeed = MockFeed();
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

  test('Get feed successfully', () async {
    final url = 'testUrl';
    when(mockApi.getCategory(url)).thenAnswer((_) async => mockCategoryFeed);
    when(mockCategoryFeed.feed).thenReturn(mockFeed);
    when(mockFeed.entry).thenReturn([]);

    await genreProvider.getFeed(url);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.loaded);
    expect(genreProvider.items, mockCategoryFeed.feed!.entry!);

    verify(mockApi.getCategory(url)).called(1);
  });

  test('Get feed with connection error', () async {
    final url = 'testUrl';
    when(mockApi.getCategory(url))
        .thenThrow(SocketException('Connection Error'));

    await genreProvider.getFeed(url);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.connectionError);
    verify(mockApi.getCategory(url)).called(1);
    verifyNever(mockCategoryFeed.feed!.entry!).called(0);
    verifyNever(genreProvider.listener(url)).called(0);
    verifyNever(genreProvider.showToast('Connection error')).called(0);
  });

  test('Get feed with unknown error', () async {
    final url = 'testUrl';
    when(mockApi.getCategory(url)).thenThrow(Exception('Unknown Error'));

    await genreProvider.getFeed(url);

    expect(genreProvider.apiRequestStatus, APIRequestStatus.error);
    verify(mockApi.getCategory(url)).called(1);
    verifyNever(mockCategoryFeed.feed!.entry!).called(0);
    verifyNever(genreProvider.listener(url)).called(0);
    verifyNever(
            genreProvider.showToast('Something went wrong, please try again'))
        .called(0);
  });
}
