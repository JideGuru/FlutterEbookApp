import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:objectdb/src/objectdb_storage_filesystem.dart';


class FavoriteDB {
  getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/favorites.db';
    return path;
  }

  //Insertion
  add(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    db.insert(item);
    await db.close();
  }

  Future<int> remove(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    int val = await db.remove(item);
    await db.close();
    return val;
  }

  Future<List> listAll() async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    List val = await db.find({});
    await db.close();
    return val;
  }

  Future<List> check(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    List val = await db.find(item);
    await db.close();
    return val;
  }
}
