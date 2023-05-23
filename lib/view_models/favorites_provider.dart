import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/database/favorite_helper.dart';
import 'package:welltested/welltested.dart';

@Welltested()
class FavoritesProvider extends ChangeNotifier {
  List favorites = [];
  var db = FavoriteDB();

  @visibleForTesting
  StreamSubscription<List>? streamSubscription;

  Future<void> listen() async {
    if (streamSubscription != null) {
      streamSubscription!.cancel();
      streamSubscription = null;
    }
    streamSubscription = (await db.listAllStream()).listen(
      (books) => favorites = books,
    );
  }

  @override
  void dispose() {
    if (streamSubscription != null) {
      streamSubscription!.cancel();
      streamSubscription = null;
    }
    super.dispose();
  }

  Future<Stream<List>> getFavoritesStream() async {
    Stream<List<dynamic>> all = await db.listAllStream();
    return all;
  }

  void setFavorites(value) {
    favorites = value;
    notifyListeners();
  }
}
