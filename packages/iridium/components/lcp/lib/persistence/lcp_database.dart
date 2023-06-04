// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:mno_lcp/persistence/licenses.dart';
import 'package:mno_lcp/persistence/transactions.dart';
import 'package:sqflite/sqflite.dart';

class LcpDatabase {
  static late LcpDatabase _database;
  final Licenses licenses;
  final Transactions transactions;

  LcpDatabase(this.licenses, this.transactions);

  static LcpDatabase get instance => _database;

  @override
  String toString() =>
      'LcpDatabase{licenses: $licenses, transactions: $transactions}';

  static Future<LcpDatabase> create() async {
    Database database = await openDatabase(
      'lcpdatabase.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
create table if not exists ${LicensesTable.name} ( 
  ${LicensesTable.id} text primary key, 
  ${LicensesTable.printsleft} integer not null,
  ${LicensesTable.copiesleft} integer not null,
  ${LicensesTable.registered} integer)
''');
        await db.execute('''
create table if not exists ${TransactionsTable.name} ( 
  ${TransactionsTable.id} text primary key, 
  ${TransactionsTable.origin} text null,
  ${TransactionsTable.userid} text null,
  ${TransactionsTable.passphrase} text null)
''');
      },
    );
    Licenses licenses = Licenses(database);
    await licenses.loadData();
    Transactions transactions = Transactions(database);

    _database = LcpDatabase(licenses, transactions);
    Fimber.d("_database: $_database");
    return _database;
  }
}
