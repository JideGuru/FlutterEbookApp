import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
import 'package:path/path.dart' as path;

class LocatorDB {
  getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    return path.join(documentDirectory.path, 'locator.db');
  }

  //Insertion
  add(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    db.insert(item);
    await db.close();
  }

  update(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    int update = await db.update({'bookId': item['bookId']}, item);
    if (update == 0) {
      db.insert(item);
    }
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

  Future<List> getLocator(String id) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    List val = await db.find({'bookId': id});
    await db.close();
    return val;
  }
}
