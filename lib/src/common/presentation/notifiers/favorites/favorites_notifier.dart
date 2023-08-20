import 'dart:async';

import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_notifier.g.dart';

@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  late FavoritesRepository _repository;

  FavoritesNotifier() : super();

  StreamSubscription<List<Entry>>? _streamSubscription;

  @override
  Future<List<Entry>> build() async {
    _repository = ref.watch(favoritesRepositoryProvider);
    _listen();
    return [];
  }

  Future<void> _listen() async {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }
    _streamSubscription = (await _repository.favoritesListStream()).listen(
      (favorites) => state = AsyncValue.data(favorites),
    );
  }

  Future<void> addBook(Entry book, String id) async {
    await _repository.addBook(book, id);
  }

  Future<void> deleteBook(String id) async {
    await _repository.deleteBook(id);
  }
}
