import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class FavoritesRepository {
  const FavoritesRepository();

  Future<void> addBook(Entry book, String id);

  Future<void> deleteBook(String id);

  Future<Stream<List<Entry>>> favoritesListStream();

  Future<void> clearBooks();
}

class FavoritesRepositoryImpl extends FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  const FavoritesRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> addBook(Entry book, String id) async {
    await localDataSource.addBook(book, id);
  }

  @override
  Future<void> deleteBook(String id) async {
    await localDataSource.deleteBook(id);
  }

  @override
  Future<Stream<List<Entry>>> favoritesListStream() async {
    return localDataSource.favoritesListStream();
  }

  @override
  Future<void> clearBooks() async {
    await localDataSource.clearBooks();
  }
}

final favoritesRepositoryProvider = Provider.autoDispose<FavoritesRepository>(
  (ref) {
    final localDataSource = ref.watch(favoritesLocalDataSourceProvider);
    return FavoritesRepositoryImpl(localDataSource: localDataSource);
  },
);
