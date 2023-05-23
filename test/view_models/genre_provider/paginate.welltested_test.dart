import 'package:flutter_ebook_app/util/flutter_toast.dart';
import 'package:mockito/annotations.dart';

import 'paginate.welltested_test.mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/view_models/genre_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  Api,
  ScrollController,
  ScrollPositionWithSingleContext,
  FlutterToastWrapper
])
void main() {
  late GenreProvider genreProvider;
  late MockApi mockApi;
  late MockFlutterToastWrapper mockFlutterToastWrapper;

  setUp(() {
    mockApi = MockApi();
    mockFlutterToastWrapper = MockFlutterToastWrapper();
    genreProvider = GenreProvider();
    genreProvider.api = mockApi;
    genreProvider.flutterToastWrapper = mockFlutterToastWrapper;
    genreProvider.apiRequestStatus = APIRequestStatus.loaded;
    when(mockFlutterToastWrapper.showToast(
            msg: anyNamed('msg'),
            toastLength: anyNamed('toastLength'),
            timeInSecForIosWeb: anyNamed('timeInSecForIosWeb')))
        .thenAnswer((realInvocation) => Future.value(null));
  });

  test('paginate with successful API call', () async {
    final url = 'some_url';
    final categoryFeed = CategoryFeed(feed: Feed(entry: [Entry(), Entry()]));

    when(mockApi.getCategory('$url&page=2'))
        .thenAnswer((_) async => categoryFeed);

    await genreProvider.paginate(url);

    expect(genreProvider.items.length, 2);
    expect(genreProvider.page, 2);
    expect(genreProvider.loadingMore, false);
    expect(genreProvider.loadMore, true);
    verify(mockApi.getCategory('$url&page=2')).called(1);
  });

  test('paginate with failed API call', () async {
    final url = 'some_url';
    final error = Exception('Some error');
    when(mockApi.getCategory('$url&page=2')).thenThrow(error);

    expect(() => genreProvider.paginate(url), throwsA(error));
    expect(genreProvider.items.length, 0);
    expect(genreProvider.page, 2);
    expect(genreProvider.loadingMore, false);
    expect(genreProvider.loadMore, false);
    verify(mockApi.getCategory('$url&page=2')).called(1);
  });

  test('paginate with loadingMore true', () async {
    final url = 'some_url';
    genreProvider.loadingMore = true;

    await genreProvider.paginate(url);

    expect(genreProvider.items.length, 0);
    expect(genreProvider.page, 1);
    expect(genreProvider.loadingMore, true);
    expect(genreProvider.loadMore, true);
    verifyNever(mockApi.getCategory(any));
  });

  test('paginate with loadMore false', () async {
    final url = 'some_url';
    genreProvider.loadMore = false;

    await genreProvider.paginate(url);

    expect(genreProvider.items.length, 0);
    expect(genreProvider.page, 1);
    expect(genreProvider.loadingMore, false);
    expect(genreProvider.loadMore, false);
    verifyNever(mockApi.getCategory(any));
  });

  test('paginate with apiRequestStatus loading', () async {
    final url = 'some_url';
    genreProvider.apiRequestStatus = APIRequestStatus.loading;

    await genreProvider.paginate(url);

    expect(genreProvider.items.length, 0);
    expect(genreProvider.page, 1);
    expect(genreProvider.loadingMore, false);
    expect(genreProvider.loadMore, true);
    verifyNever(mockApi.getCategory(any));
  });

  test('paginate with successful API call and maxScrollExtent', () async {
    final url = 'some_url';
    final categoryFeed = CategoryFeed(feed: Feed(entry: [Entry(), Entry()]));
    when(mockApi.getCategory('$url&page=2'))
        .thenAnswer((_) async => categoryFeed);
    final scrollController = MockScrollController();
    genreProvider.controller = scrollController;
    final scrollPosition = MockScrollPositionWithSingleContext();
    when(scrollController.position).thenReturn(scrollPosition);
    when(scrollPosition.maxScrollExtent).thenReturn(100.0);

    await genreProvider.paginate(url);
    await Future.delayed(Duration(milliseconds: 200));
    expect(genreProvider.items.length, 2);
    expect(genreProvider.page, 2);
    expect(genreProvider.loadingMore, false);
    expect(genreProvider.loadMore, true);
    verify(mockApi.getCategory('$url&page=2')).called(1);
    verify(scrollController.jumpTo(100.0)).called(1);
  });
}
