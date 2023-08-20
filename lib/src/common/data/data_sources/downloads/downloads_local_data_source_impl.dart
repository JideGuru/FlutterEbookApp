import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

class DownloadsLocalDataSourceImpl implements DownloadsLocalDataSource {
  final Database _database;
  final StoreRef<String, Map<String, dynamic>> _store;

  const DownloadsLocalDataSourceImpl({
    required Database database,
    required StoreRef<String, Map<String, dynamic>> store,
  })  : _database = database,
        _store = store;

  @override
  Future<void> addBook(Map<String, dynamic> book, String id) async {
    await _store.record(id).put(_database, book, merge: true);
  }

  @override
  Future<void> clearBooks() async {
    await _store.delete(_database);
  }

  @override
  Future<void> deleteAllBooksWithId(String id) async {
    await _store.record(id).delete(_database);
  }

  @override
  Future<void> deleteBook(String id) async {
    await _store.record(id).delete(_database);
  }

  @override
  Future<List<Map<String, dynamic>>> downloadList() async {
    return _store.query().getSnapshots(_database).then(
          (records) => records.map((record) => record.value).toList(),
        );
  }

  @override
  Future<Map<String, dynamic>?> fetchBook(String id) async {
    return _store.record(id).get(_database);
  }

  @override
  Stream<List<Map<String, dynamic>>> downloadListStream() {
    return _store
        .query()
        .onSnapshots(_database)
        .map<List<Map<String, dynamic>>>(
          (records) => records
              .map<Map<String, dynamic>>((record) => record.value)
              .toList(),
        );
  }
}

final downloadsLocalDataSourceProvider =
    Provider.autoDispose<DownloadsLocalDataSource>(
  (ref) {
    final database = ref.watch(downloadsDatabaseProvider);
    final store = ref.watch(storeRefProvider);
    return DownloadsLocalDataSourceImpl(database: database, store: store);
  },
);
