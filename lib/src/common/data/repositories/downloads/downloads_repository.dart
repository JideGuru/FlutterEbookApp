import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DownloadsRepository {
  const DownloadsRepository();

  Future<void> addBook(Map<String, dynamic> book, String id);

  Future<void> deleteBook(String id);

  Future<void> deleteAllBooksWithId(String id);

  Future<List<Map<String, dynamic>>> downloadList();

  Future<Map<String, dynamic>?> fetchBook(String id);

  Future<Stream<List<Map<String, dynamic>>>> downloadListStream();

  Future<void> clearBooks();
}

class DownloadsRepositoryImpl extends DownloadsRepository {
  final DownloadsLocalDataSource localDataSource;

  const DownloadsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> addBook(Map<String, dynamic> book, String id) async {
    await localDataSource.addBook(book, id);
  }

  @override
  Future<void> clearBooks() async {
    await localDataSource.clearBooks();
  }

  @override
  Future<void> deleteAllBooksWithId(String id) async {
    await localDataSource.deleteAllBooksWithId(id);
  }

  @override
  Future<void> deleteBook(String id) async {
    await localDataSource.deleteBook(id);
  }

  @override
  Future<List<Map<String, dynamic>>> downloadList() async {
    return localDataSource.downloadList();
  }

  @override
  Future<Map<String, dynamic>?> fetchBook(String id) async {
    return localDataSource.fetchBook(id);
  }

  @override
  Future<Stream<List<Map<String, dynamic>>>> downloadListStream() async {
    return localDataSource.downloadListStream();
  }
}

final downloadsRepositoryProvider = Provider.autoDispose<DownloadsRepository>(
  (ref) {
    final localDataSource = ref.watch(downloadsLocalDataSourceProvider);
    return DownloadsRepositoryImpl(localDataSource: localDataSource);
  },
);
