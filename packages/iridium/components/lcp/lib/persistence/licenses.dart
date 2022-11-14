// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_lcp/lcp.dart';
import 'package:sqflite/sqflite.dart';

class LicensesTable {
  static const String name = "Licenses";
  static const String id = "id";
  static const String printsleft = "printsLeft";
  static const String copiesleft = "copiesLeft";
  static const String registered = "registered";
}

class Licenses implements DeviceRepository, LicensesRepository {
  static const int _true = 1;
  final Database database;
  Map<String, int>? copies;
  Map<String, int>? prints;

  Licenses(this.database);

  Future<void> loadData() async {
    copies = await _getAll(LicensesTable.copiesleft);
    prints = await _getAll(LicensesTable.printsleft);
  }

  Future<bool> _exists(LicenseDocument license) async {
    List<Map<String, dynamic>> result = await database.query(
      LicensesTable.name,
      columns: [LicensesTable.id],
      where: '${LicensesTable.id} = ?',
      whereArgs: [license.id],
    );
    return Future.value(result.isNotEmpty);
  }

  Future<Map<String, int>> _getAll(String column) async {
    List<Map<String, dynamic>> result = await database.query(
      LicensesTable.name,
      columns: [LicensesTable.id, column],
    );
    return (result.isNotEmpty)
        ? {
            for (Map<String, dynamic> row in result)
              row[LicensesTable.id] as String: row[column] as int
          }
        : {};
  }

  // ignore: unused_element
  Future<int> _get(String column, String licenseId) async {
    List<Map<String, dynamic>> result = await database.query(
      LicensesTable.name,
      columns: [column],
      where: '${LicensesTable.id} = ?',
      whereArgs: [licenseId],
    );
    return Future.value(
        (result.isNotEmpty) ? result.first[column] as int : null);
  }

  Future<int> _set(String column, int value, String licenseId) =>
      database.update(
        LicensesTable.name,
        {
          column: value,
        },
        where: '${LicensesTable.id} = ?',
        whereArgs: [licenseId],
      );

  @override
  Future<bool> isDeviceRegistered(LicenseDocument license) async {
    if (!await _exists(license)) {
      throw LcpException.runtime(
          "The LCP License doesn't exist in the database");
    }
    List<Map<String, dynamic>> result = await database.query(
      LicensesTable.name,
      columns: [LicensesTable.registered],
      where: '${LicensesTable.id} = ? AND ${LicensesTable.registered} = ?',
      whereArgs: [license.id, _true],
    );
    return result.isNotEmpty;
  }

  @override
  Future<int> registerDevice(LicenseDocument license) async {
    if (!await _exists(license)) {
      throw LcpException.runtime(
          "The LCP License doesn't exist in the database");
    }
    return database.update(
      LicensesTable.name,
      {
        LicensesTable.registered: _true,
      },
      where: '${LicensesTable.id} = ?',
      whereArgs: [license.id],
    );
  }

  @override
  void addLicense(LicenseDocument license) async {
    if (await _exists(license)) {
      return;
    }
    await database.insert(
        LicensesTable.name,
        {
          LicensesTable.id: license.id,
          LicensesTable.printsleft: license.rights.print,
          LicensesTable.copiesleft: license.rights.copy,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  int? copiesLeft(String licenseId) => copies?[licenseId];

  @override
  void setCopiesLeft(int quantity, String licenseId) {
    copies?[licenseId] = quantity;
    _set(LicensesTable.copiesleft, quantity, licenseId);
  }

  @override
  int? printsLeft(String licenseId) => prints?[licenseId];

  @override
  void setPrintsLeft(int quantity, String licenseId) {
    prints?[licenseId] = quantity;
    _set(LicensesTable.printsleft, quantity, licenseId);
  }
}
