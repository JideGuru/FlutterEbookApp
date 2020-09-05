import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

class LocatorDB {
  getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/locator.db';
    return path;
  }

  //Insertion
  add(Map item) async {
    final db = ObjectDB(await getPath());
    db.open();
    db.insert(item);
    await db.close();
  }

  update(Map item) async {
    final db = ObjectDB(await getPath());
    db.open();
    int update = await db.update({'bookId': item['bookId']}, item);
    if(update == 0){
      db.insert(item);
    }
    await db.close();
  }

  Future<int> remove(Map item) async {
    final db = ObjectDB(await getPath());
    db.open();
    int val = await db.remove(item);
    await db.close();
    return val;
  }

  Future<List> listAll() async {
    final db = ObjectDB(await getPath());
    db.open();
    List val = await db.find({});
    await db.close();
    return val;
  }

  Future<List> getLocator(String id) async {
    final db = ObjectDB(await getPath());
    db.open();
    List val = await db.find({'bookId': id});
    await db.close();
    return val;
  }
}
