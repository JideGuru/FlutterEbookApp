import 'package:flutter_ebook_app/src/common/common.dart';

abstract class FavoritesLocalDataSource {
  const FavoritesLocalDataSource();

  Future<void> addBook(Entry book, String id);

  Future<void> deleteBook(String id);

  Stream<List<Entry>> favoritesListStream();

  Future<void> clearBooks();
}
