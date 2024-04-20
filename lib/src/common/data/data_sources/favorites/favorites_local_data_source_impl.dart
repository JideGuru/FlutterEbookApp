import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logman/logman.dart';
import 'package:sembast/sembast.dart';

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final Database _database;
  final StoreRef<String, Map<String, dynamic>> _store;

  const FavoritesLocalDataSourceImpl({
    required Database database,
    required StoreRef<String, Map<String, dynamic>> store,
  })  : _database = database,
        _store = store;

  @override
  Future<void> addBook(Entry book, String id) async {
    await _store.record(id).put(_database, book.toJson());
    Logman.instance.info(
      'Added book to favorites: ${book.title}',
    );
  }

  @override
  Future<void> deleteBook(String id) async {
    await _store.record(id).delete(_database);
    Logman.instance.info(
      'Deleted book from favorites: $id',
    );
  }

  @override
  Stream<List<Entry>> favoritesListStream() {
    return _store.query().onSnapshots(_database).map<List<Entry>>(
          (records) => records
              .map<Entry>((record) => Entry.fromJson(record.value))
              .toList(),
        );
  }

  @override
  Future<void> clearBooks() async {
    await _store.delete(_database);
    Logman.instance.info(
      'Cleared all books from favorites',
    );
  }
}

final favoritesLocalDataSourceProvider =
    Provider.autoDispose<FavoritesLocalDataSource>(
  (ref) {
    final database = ref.watch(favoritesDatabaseProvider);
    final store = ref.watch(storeRefProvider);
    return FavoritesLocalDataSourceImpl(database: database, store: store);
  },
);
