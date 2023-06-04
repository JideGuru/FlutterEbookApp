import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_ebook_app/src/features/common/constants/api.dart';

class AppDio with DioMixin implements Dio {
  AppDio._() {
    String baseUrl = ApiEndpoints.baseURL;
    options = BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
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
    httpClientAdapter = IOHttpClientAdapter();
  }

  static Dio getInstance() => AppDio._();
}
