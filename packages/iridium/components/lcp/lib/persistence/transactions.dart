// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';
import 'package:sqflite/sqflite.dart';

class TransactionsTable {
  static const String name = "Transactions";
  static const String id = "licenseId";
  static const String origin = "origin";
  static const String userid = "userId";
  static const String passphrase = "passphrase";
}

class Transactions implements PassphrasesRepository {
  final Database database;

  Transactions(this.database);

  @override
  void addPassphrase(String passphraseHash, String? licenseId, String? provider,
          String? userId) =>
      database.insert(
          TransactionsTable.name,
          {
            TransactionsTable.id: licenseId,
            TransactionsTable.origin: provider,
            TransactionsTable.userid: userId,
            TransactionsTable.passphrase: passphraseHash,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);

  @override
  Future<String?> passphrase(String licenseId) async {
    List<Map<String, dynamic>> result = await database.query(
      TransactionsTable.name,
      columns: [TransactionsTable.passphrase],
      where: '${TransactionsTable.origin} = ?',
      whereArgs: [licenseId],
    );
    return (result.isNotEmpty)
        ? result.first[TransactionsTable.passphrase]
        : Future.value(null);
  }

  @override
  Future<List<String>> passphrases(String userId) async {
    List<Map<String, dynamic>> result = await database.query(
      TransactionsTable.name,
      columns: [TransactionsTable.passphrase],
      where: '${TransactionsTable.userid} = ?',
      whereArgs: [userId],
    );
    return result
        .map((e) => e[TransactionsTable.passphrase])
        .whereType<String>()
        .toList();
  }

  @override
  Future<List<String>> allPassphrases() async {
    List<Map<String, dynamic>> result = await database.query(
      TransactionsTable.name,
      columns: [TransactionsTable.passphrase],
    );
    return result
        .map((e) => e[TransactionsTable.passphrase])
        .whereType<String>()
        .toList();
  }
}
