import 'dart:async';

import 'package:flutter_ebook_app/src/features/common/data/repositories/downloads/downloads_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'downloads_state.dart';

part 'downloads_state_notifier.freezed.dart';

class DownloadsStateNotifier extends StateNotifier<DownloadsState> {
  final DownloadsRepository _repository;

  DownloadsStateNotifier({
    required DownloadsRepository repository,
  })  : _repository = repository,
        super(const DownloadsState.started());

  StreamSubscription<List<Map<String, dynamic>>>? _streamSubscription;

  Future<void> listen() async {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }
    _streamSubscription = (await _repository.downloadListStream()).listen(
      (downloads) {
        if (mounted) state = DownloadsState.listening(downloads: downloads);
      },
    );
  }

  Future<void> fetchBook(id) async {
    await _repository.fetchBook(id);
  }

  Future<void> addBook(Map<String, dynamic> book, id) async {
    await _repository.addBook(book, id);
  }

  Future<void> deleteBook(String id) async {
    await _repository.deleteBook(id);
  }
}

final downloadsStateNotifierProvider =
    StateNotifierProvider.autoDispose<DownloadsStateNotifier, DownloadsState>(
  (ref) {
    return DownloadsStateNotifier(
      repository: ref.watch(downloadsRepositoryProvider),
    );
  },
);
