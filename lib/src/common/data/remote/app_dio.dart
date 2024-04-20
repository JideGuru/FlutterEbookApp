import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:logman/logman.dart';

class AppDio with DioMixin implements Dio {
  AppDio._() {
    const String baseUrl = baseURL;
    options = BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
    );
    interceptors
      ..add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (DioException e, handler) async {
            return handler.next(e);
          },
        ),
      )
      ..add(LogmanDioInterceptor());
    httpClientAdapter = getAdapter();
  }

  static Dio getInstance() => AppDio._();
}

class LogmanDioInterceptor extends Interceptor {
  final Logman _logman = Logman.instance;

  LogmanDioInterceptor();

  final _cache = <RequestOptions, String>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = UniqueKey().toString();
    _cache[options] = requestId;
    final sentAt = DateTime.now();

    final requestRecord = NetworkRequestLogmanRecord(
      id: requestId,
      url: options.uri.toString(),
      method: options.method,
      headers: options.headers,
      body: options.data,
      sentAt: sentAt,
    );
    _logman.networkRequest(requestRecord);

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Map<String, String> responseHeaders = response.headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
    final id = _cache[response.requestOptions];
    final receivedAt = DateTime.now();

    final responseRecord = NetworkResponseLogmanRecord(
      id: id!,
      statusCode: response.statusCode,
      headers: responseHeaders,
      body: response.data.toString(),
      receivedAt: receivedAt,
    );

    _logman.networkResponse(responseRecord);

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Map<String, String>? responseHeaders = err.response?.headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
    final id = _cache[err.requestOptions];

    final responseRecord = NetworkResponseLogmanRecord(
      id: id!,
      statusCode: err.response?.statusCode ?? 0,
      headers: responseHeaders,
      body: err.response?.data.toString(),
      receivedAt: DateTime.now(),
    );

    _logman.networkResponse(responseRecord);

    return super.onError(err, handler);
  }
}
