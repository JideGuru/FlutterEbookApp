import 'dart:io';

import 'package:objectdb/objectdb.dart';

class DownloadsDB{

  static final path = Directory.current.path + '/downloads.db';
  final db = ObjectDB(path);

  //Insertion
  add(Map item) async{
    db.open();
    db.insert(item);
    db.tidy();
    await db.close();
  }

  Future<int> remove(Map item) async{
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