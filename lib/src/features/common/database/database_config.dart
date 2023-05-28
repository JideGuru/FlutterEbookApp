import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

abstract class DatabaseConfig {
  static Database getDatabaseInstance(String dbName) {
    final database = _instances[dbName];
    if (database == null) {
      throw Exception('the name provided' ' has no instance available for use');
    }
    return database;
  }

  static void init(StoreRef<dynamic, dynamic> store) => _initDatabases(
        databaseNames,
        store,
      );

  static final Map<String, Database> _instances = {};

  static void _initDatabases(
    List<String> dbNames,
    StoreRef<dynamic, dynamic> store,
  ) async {
    for (var name in dbNames) {
      final dbPath = await _generateDbPath(name);
      final dbFactory = databaseFactoryIo;
      final db = await dbFactory.openDatabase(dbPath);
      final databaseReference = _instances[name];
      if (databaseReference != null) await databaseReference.close();
      _instances[name] = db;
    }
  }

  static List<String> get databaseNames => [
        downloadsDatabaseName,
        favoritesDatabaseName,
      ];

  static String get downloadsDatabaseName => 'download.db';

  static String get favoritesDatabaseName => 'favorites.db';

  static Future<String> _generateDbPath(String dbName) async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final dbPath = join(dir.path, dbName);
    return dbPath;
  }
}
