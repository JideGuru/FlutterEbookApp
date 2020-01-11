import 'dart:convert';

import 'package:flutter_ebook_app/podo/book_details.dart';
import 'package:flutter_ebook_app/podo/category.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

class Api{

  static String popular = "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom";
  static String recent = "https://catalog.feedbooks.com/publicdomain/browse/en/new.atom";
  static String awards = "https://catalog.feedbooks.com/publicdomain/browse/en/awards.atom";
  static String noteworthy = "https://catalog.feedbooks.com/publicdomain/browse/en/awards.atom";
  static String shortStory = "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC029000";
  static String sciFi = "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC028000";
  static String actionAdventure = "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC002000";
  static String mystery = "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC022000";
  static String romance = "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC027000";
  static String horror = "https://catalog.feedbooks.com/publicdomain/browse/en/top.atom?cat=FBFIC015000";



  static Future getCategory(String url) async{
    var res = await http.get(url);
    print(res.body);
    Xml2Json xml2json = new Xml2Json();
    xml2json.parse(res.body);
    var json = jsonDecode(xml2json.toParker());
    print(json);
    CategoryFeed category = CategoryFeed.fromJson(json);
    print(category.feed.title);
  }

  static Future getBookDetails(String url) async{
    var res = await http.get(url);
    print(res.body);
    Xml2Json xml2json = new Xml2Json();
    xml2json.parse(res.body);
    var json = jsonDecode(xml2json.toParker());
    print(json);
    BookDetails bookDetails = BookDetails.fromJson(json);
    print(bookDetails.entry.title);
  }
}