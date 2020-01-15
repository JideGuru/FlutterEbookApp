import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/podo/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchProvider with ChangeNotifier {
  String message;
  CategoryFeed romance = CategoryFeed();
  CategoryFeed action = CategoryFeed();
  CategoryFeed literary = CategoryFeed();
  CategoryFeed juvenile = CategoryFeed();

  bool loading = true;


  getFeeds() async{
    setLoading(true);
    Api.getCategory(Api.popular).then((popular){
      setRomance(popular);
      Api.getCategory(Api.noteworthy).then((newReleases){
        setAction(newReleases);
        setLoading(false);
      }).catchError((e){
        throw(e);
      });
    }).catchError((e){
      throw(e);
    });
  }


  void setLoading(value) {
    loading = value;
    notifyListeners();
  }

  bool isLoading() {
    return loading;
  }

  void setMessage(value) {
    message = value;
    Fluttertoast.showToast(
      msg: value,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIos: 1,
    );
    notifyListeners();
  }

  String getMessage() {
    return message;
  }

  void setRomance(value) {
    romance = value;
    notifyListeners();
  }

  CategoryFeed getRomance() {
    return romance;
  }

  void setAction(value) {
    action = value;
    notifyListeners();
  }

  CategoryFeed getRecent() {
    return action;
  }

}