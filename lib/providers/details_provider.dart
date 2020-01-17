import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/database/favorite_helper.dart';
import 'package:flutter_ebook_app/podo/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailsProvider extends ChangeNotifier{
  String message;
  CategoryFeed related = CategoryFeed();
  bool loading = true;
  Entry entry;
  var db = FavoriteDB();
  bool faved = false;

  static var httpClient = HttpClient();
  Dio dio = new Dio();

  Future downloadFile(String url, String filename) async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    if(permission != PermissionStatus.granted){
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      startDownload(url, filename);
    }else{
      startDownload(url, filename);
    }
  }

  startDownload(String url, String filename) async{
    Directory appDocDir = await getExternalStorageDirectory();
    if(Platform.isAndroid){
      Directory(appDocDir.path.split("Android")[0]+"${Constants.appName}").create();
    }

    String path = Platform.isIOS
        ? appDocDir.path+"/$filename.epub"
        : appDocDir.path.split("Android")[0]+"${Constants.appName}/$filename.epub";
    print(path);
    File file = File(path);
    if(!await file.exists()){
      await file.create();
      await dio.download(url,path,
        // Listen the download progress.
        onReceiveProgress: (received, total) {
          print((received / total * 100).toStringAsFixed(0) + "%");
          String progress = (received / total * 100).toStringAsFixed(0) + "%";
          print(progress);
        },
      );
    }else{
      setMessage("You have already download this");
    }

  }

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
    faved = value;
    notifyListeners();
  }
}