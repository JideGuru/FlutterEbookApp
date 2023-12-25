import 'dart:async';

import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'downloads_notifier.g.dart';

@riverpod
class DownloadsNotifier extends _$DownloadsNotifier {
  late DownloadsRepository _repository;

  DownloadsNotifier() : super();

  StreamSubscription<List<Map<String, dynamic>>>? _streamSubscription;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    _repository = ref.watch(downloadsRepositoryProvider);
    _listen();
    return _repository.downloadList();
  }

  Future<void> _listen() async {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }
    _streamSubscription = (await _repository.downloadListStream()).listen(
      (downloads) => state = AsyncValue.data(downloads),
    );
  }

  Future<void> fetchBook(String id) async {
    await _repository.fetchBook(id);
  }

  Future<void> addBook(Map<String, dynamic> book, String id) async {
    await _repository.addBook(book, id);
  }

  Future<void> deleteBook(String id) async {
    await _repository.deleteBook(id);
  }

  Future<void> clearBooks() async {
    await _repository.clearBooks();
  }
}
