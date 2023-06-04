// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:intl/intl.dart';
import 'package:mno_commons/extensions/data.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:universal_io/io.dart' hide Link;

/// The [RequestHandler] provides the means to send data to the HTTP response.
///
/// It also support range requests
abstract class RequestHandler {
  static const Duration _expirationDelay =
      Duration(seconds: 30); //Duration(days: 10);
  static const int _defaultRangeLength = 2 * 1024 * 1024; // 2Mb
  static const String _dateLocale = "en_US";
  static const String _cacheControlValue =
      "no-transform,public,max-age=3000,s-maxage=9000";

  Future init() async {}

  void dispose() {}

  /// This method should handle the requests if the implementation supports the
  /// resource demanded.
  ///
  /// Returns true if the request has been handled
  Future<bool> handle(int requestId, Request request, String href);

  final bool _shouldAddCacheHeaders = false;

  /// Enable this method when debugging is over.
  void _addCacheHeaders(Response response) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss', _dateLocale);
    DateTime expiration = now.add(_expirationDelay);
    response.setHeader(HttpHeaders.cacheControlHeader, _cacheControlValue);
    response.setHeader(HttpHeaders.expiresHeader, formatter.format(expiration));
    response.setHeader(HttpHeaders.lastModifiedHeader, formatter.format(now));
  }

  /// Extract a [request] param [name] and convert it to [int]
  ///
  /// A [defaultValue] may be provided if no param exists or if the parsing as
  /// [int] fails.
  static int getParamAsInt(Request request, String name,
      {int defaultValue = 0}) {
    String? valueStr = request.uri.queryParameters[name];
    return (valueStr != null)
        ? int.tryParse(valueStr) ?? defaultValue
        : defaultValue;
  }

  static int getParamAsIntFromMap(
      Map<String, String> queryParameters, String name,
      {int defaultValue = 0}) {
    String? valueStr = queryParameters[name];
    return (valueStr != null)
        ? int.tryParse(valueStr) ?? defaultValue
        : defaultValue;
  }

  /// Sends a bytes buffer as the request response.
  Future<void> sendData(Request request,
      {required List<int> data, MediaType? mediaType}) async {
    Response response = request.response;

    if (_shouldAddCacheHeaders) {
      _addCacheHeaders(response);
    }

    response
      ..contentType = mediaType?.contentType
      ..add(data);
  }

  /// Sends a byte stream (supporting range access) as the request response.
  Future<void> sendResource(Request request,
      {required Resource resource, MediaType? mediaType}) async {
    Response response = request.response;

    if (_shouldAddCacheHeaders) {
      _addCacheHeaders(response);
    }

    response
      ..contentType = mediaType?.contentType
      ..setHeader(HttpHeaders.acceptRangesHeader, 'bytes');

    String? range = request.getHeader(HttpHeaders.rangeHeader);
    if (range != null) {
      int length = (await resource.length()).getOrNull() ?? 0;
      int start = 0;
      int end = length - 1;

      try {
        List<String> parts = range.split('=');
        if (parts.length != 2 || 'bytes' != parts[0]) {
          throw "Requested range not satisfiable";
        }

        parts = parts[1].split("-");
        if (parts[0].isNotEmpty) {
          start = int.parse(parts[0]);
        }
        if (parts.length == 2 && parts[1].isNotEmpty) {
          end = int.parse(parts[1]);
        } else {
          end = min(length - 1, start + _defaultRangeLength);
        }
        response
          ..statusCode = HttpStatus.partialContent
          ..setHeader(
              HttpHeaders.contentRangeHeader, 'bytes $start-$end/$length');

        ByteData? data =
            (await resource.read(range: IntRange(start, end))).getOrNull();
        if (data != null) {
          await response.addStream(data.asStream());
        }
      } on Exception catch (e, stacktrace) {
        Fimber.d("error", ex: e, stacktrace: stacktrace);
        request.response
          ..statusCode = HttpStatus.requestedRangeNotSatisfiable
          ..write("REQUESTED RANGE NOT SATISFIABLE");
        return;
      }
    } else {
      ByteData? data = (await resource.read()).getOrNull();
      if (data != null) {
        await response.addStream(data.asStream());
      }
    }
  }
}

/// Extends [MediaType] to add conversion to [ContentType]
extension ContentTypeMediaType on MediaType {
  /// Convert [MediaType] to [ContentType]
  ContentType get contentType => ContentType.parse(toString());
}
