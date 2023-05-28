import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ebook_app/src/features/common/constants/api.dart';

class AppDio with DioMixin implements Dio {
  AppDio._([BaseOptions? options]) {
    String baseUrl = ApiEndpoints.baseURL;
    this.options = BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: 30000,
      sendTimeout: 30000,
      receiveTimeout: 30000,
    );
    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioError e, handler) async {
          return handler.next(e);
        },
      ),
    );
    httpClientAdapter = DefaultHttpClientAdapter();
  }

  static Dio getInstance() => AppDio._();
}
