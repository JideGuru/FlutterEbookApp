abstract class DownloadsLocalDataSource {
  const DownloadsLocalDataSource();

  Future<void> addBook(Map<String, dynamic> book, String id);

  Future<void> deleteBook(String id);

  Future<void> deleteAllBooksWithId(String id);

  Future<List<Map<String, dynamic>>> downloadList();

  Stream<List<Map<String, dynamic>>> downloadListStream();

  Future<Map<String, dynamic>?> fetchBook(String id);

  Future<void> clearBooks();
}
