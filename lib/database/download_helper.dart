import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:objectdb/src/objectdb_storage_filesystem.dart';

class DownloadsDB {
  getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/downloads.db';
    return path;
  }

  //Insertion
  add(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    // db.open();
    db.insert(item);
    // db.tidy();
    await db.close();
  }

  Future<int> remove(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    // db.open();
    int val = await db.remove(item);
    // db.tidy();
    await db.close();
    return val;
  }

  Future removeAllWithId(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    // db.open();
    List val = await db.find({});
    val.forEach((element) {
      db.remove(element);
    });
    // db.tidy();
    await db.close();
  }

  Future<List> listAll() async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    // db.open();
    List val = await db.find({});
    // db.tidy();
    await db.close();
    return val;
  }

  Future<List> check(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    // db.open();
    List val = await db.find(item);
    // db.tidy();
    await db.close();
    return val;
  }

  clear() async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    // db.open();
    db.remove({});
  }
}
