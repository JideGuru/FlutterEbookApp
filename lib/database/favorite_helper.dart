import 'dart:io';

import 'package:objectdb/objectdb.dart';

class FavoriteDB{

  static final path = Directory.systemTemp.path + '/favorite.db';
  final db = ObjectDB(path);

  //Insertion
  addFav(Map item) async{
    db.open();
    db.insert(item);
    db.tidy();
    await db.close();
  }

  Future<int> removeFav(Map item) async{
    db.open();
    int val = await db.remove(item);
    db.tidy();
    await db.close();
    return val;
  }

  Future<List> listAll() async{
    db.open();
    List val = await db.find({});
    db.tidy();
    await db.close();
    return val;
  }

  Future<List> check(Map item) async{
    db.open();
    List val = await db.find(item);
    db.tidy();
    await db.close();
    return val;
  }
}