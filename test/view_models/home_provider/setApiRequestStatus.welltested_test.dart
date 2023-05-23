import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HomeProvider homeProvider;

  setUp(() {
    homeProvider = HomeProvider();
  });

  test('Set API request status to loading', () {
    homeProvider.setApiRequestStatus(APIRequestStatus.loading);
    expect(homeProvider.apiRequestStatus, APIRequestStatus.loading);
  });

  test('Set API request status to success', () {
    homeProvider.setApiRequestStatus(APIRequestStatus.loaded);
    expect(homeProvider.apiRequestStatus, APIRequestStatus.loaded);
  });

  test('Set API request status to error', () {
    homeProvider.setApiRequestStatus(APIRequestStatus.error);
    expect(homeProvider.apiRequestStatus, APIRequestStatus.error);
  });

  test('Notify listeners after setting API request status', () {
    bool listenerCalled = false;
    homeProvider.addListener(() {
      listenerCalled = true;
    });
    homeProvider.setApiRequestStatus(APIRequestStatus.loading);
    expect(listenerCalled, true);
  });
}
