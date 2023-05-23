import 'dart:io';

import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HomeProvider homeProvider;

  setUp(() {
    homeProvider = HomeProvider();
  });

  test('checkError with connection error', () {
    final error = SocketException('Connection error');

    homeProvider.checkError(error);

    expect(homeProvider.apiRequestStatus, APIRequestStatus.connectionError);
  });

  test('checkError with other error', () {
    final error = Exception('Some other error');

    homeProvider.checkError(error);

    expect(homeProvider.apiRequestStatus, APIRequestStatus.error);
  });

  test('checkError with no error', () {
    final error = null;

    homeProvider.checkError(error);

    expect(homeProvider.apiRequestStatus, APIRequestStatus.loading);
  });
}
