import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/podo/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailsProvider extends ChangeNotifier{
  String message;
  CategoryFeed related = CategoryFeed();
  bool loading = true;

  getFeed(String url) async{
    setLoading(true);
    Api.getCategory(url).then((feed){
      setRelated(feed);
      setLoading(false);
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

  void setRelated(value) {
    related = value;
    notifyListeners();
  }

  CategoryFeed getRelated() {
    return related;
  }
}