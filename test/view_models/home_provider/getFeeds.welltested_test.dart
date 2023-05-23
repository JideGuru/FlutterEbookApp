import 'getFeeds.welltested_test.mocks.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/util/functions.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([CategoryFeed, Api])
void main() {
  late HomeProvider homeProvider;
  late MockCategoryFeed mockTop;
  late MockCategoryFeed mockRecent;
  late MockApi mockApi;

  setUp(() {
    mockTop = MockCategoryFeed();
    mockRecent = MockCategoryFeed();
    mockApi = MockApi();
    homeProvider = HomeProvider();
    homeProvider.api = mockApi;
  });

  test('Get feeds successfully', () async {
    when(mockApi.getCategory(Api.popular)).thenAnswer((_) async => mockTop);
    when(mockApi.getCategory(Api.recent)).thenAnswer((_) async => mockRecent);

    await homeProvider.getFeeds();

    expect(homeProvider.apiRequestStatus, APIRequestStatus.loaded);
    expect(homeProvider.top, mockTop);
    expect(homeProvider.recent, mockRecent);

    verify(mockApi.getCategory(Api.popular)).called(1);
    verify(mockApi.getCategory(Api.recent)).called(1);
  });

  test('Get feeds with connection error', () async {
    when(mockApi.getCategory(Api.popular))
        .thenThrow(Exception('Connection Error'));

    await homeProvider.getFeeds();

    expect(homeProvider.apiRequestStatus, APIRequestStatus.error);

    verify(mockApi.getCategory(Api.popular)).called(1);
    verifyNever(mockApi.getCategory(Api.recent)).called(0);
  });

  test('Get feeds with unknown error', () async {
    when(mockApi.getCategory(Api.popular))
        .thenThrow(Exception('Unknown Error'));

    await homeProvider.getFeeds();

    expect(homeProvider.apiRequestStatus, APIRequestStatus.error);

    verify(mockApi.getCategory(Api.popular)).called(1);
    verifyNever(mockApi.getCategory(Api.recent)).called(0);
  });
}
