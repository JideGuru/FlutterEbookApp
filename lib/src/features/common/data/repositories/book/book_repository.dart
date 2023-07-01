import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_ebook_app/src/features/common/data/failures/http_failure.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:xml2json/xml2json.dart';

abstract class BookRepository {
  final Dio httpClient;

  const BookRepository(this.httpClient);

  Future<(CategoryFeed?, HttpFailure?)> getCategory(String url) async {
    try {
      final res = await httpClient.get(url);
      CategoryFeed category;
      Xml2Json xml2json = Xml2Json();
      xml2json.parse(res.data.toString());
      var json = jsonDecode(xml2json.toGData());
      category = CategoryFeed.fromJson(json as Map<String, dynamic>);
      return (category, null);
    } on DioError catch (error) {
      final statusCode = error.response?.statusCode ?? 500;
      if (statusCode == 404) {
        return (null, HttpFailure.notFound);
      }
      return (null, HttpFailure.unknown);
    }
  }
}
