import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/database/favorite_helper.dart';

class FavoritesProvider extends ChangeNotifier {
  List posts = List();
  bool loading = true;
  var db = FavoriteDB();

  getFeed() async {
    setLoading(true);
    posts.clear();
    db.listAll().then((all) {
      posts.addAll(all);
      setLoading(false);
    });
  }

  void setLoading(value) {
    loading = value;
    notifyListeners();
  }

  void setPosts(value) {
    posts = value;
    notifyListeners();
  }

  List getPosts() {
    return posts;
  }
}
