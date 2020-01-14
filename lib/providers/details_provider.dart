import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/database/favorite_helper.dart';
import 'package:flutter_ebook_app/podo/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailsProvider extends ChangeNotifier{
  String message;
  CategoryFeed related = CategoryFeed();
  bool loading = true;
  Entry entry;
  var db = FavoriteDB();
  bool faved = false;


  getFeed(String url) async{
    setLoading(true);
    checkFav();
    Api.getCategory(url).then((feed){
      setRelated(feed);
      setLoading(false);
    }).catchError((e){
      throw(e);
    });
  }

  checkFav() async{
    List c = await db.check({"id": entry.published.t});
    if(c.isNotEmpty){
      setFaved(true);
    }else{
      setFaved(false);
    }
  }

  addFav() async{
    db.addFav({"id": entry.published.t, "item": entry.toJson()});
    checkFav();
  }

  removeFav() async{
    db.removeFav({"id": entry.published.t}).then((v){
      print(v);
      checkFav();
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

  void setEntry(value) {
    entry = value;
    notifyListeners();
  }

  void setFaved(value) {
    print(value);
    faved = value;
    notifyListeners();
  }
}