import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:xml2json/xml2json.dart';

class Api {
  static String baseURL =
      "https://catalog.feedbooks.com";
  static String popular =
      "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom";
  static String recent =
      "https://catalog.feedbooks.com/publicdomain/browse/en/recent.atom";
  static String awards =
      "https://catalog.feedbooks.com/publicdomain/browse/en/awards.atom";
  static String noteworthy =
      "https://catalog.feedbooks.com/publicdomain/browse/en/homepage_selection.atom";
  static String shortStory =
      "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC029000";
  static String sciFi =
      "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC028000";
  static String actionAdventure =
      "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC002000";
  static String mystery =
      "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC022000";
  static String romance =
      "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC027000";
  static String horror =
      "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC015000";

  static Future<CategoryFeed> getCategory(String url) async {
    Dio dio = Dio();

    var res = await dio.get(url);
    CategoryFeed category;
    if(res.statusCode == 200){
      Xml2Json xml2json = new Xml2Json();
      xml2json.parse(res.data.toString());
      var json = jsonDecode(xml2json.toGData());
      category = CategoryFeed.fromJson(json);
    }else{
      throw("Error ${res.statusCode}");
    }

    return category;
  }
}
