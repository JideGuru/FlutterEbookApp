import 'dart:async';

import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/common/data/repositories/favorites/favorites_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_state.dart';

part 'favorites_state_notifier.freezed.dart';

class FavoritesStateNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesStateNotifier({
    required FavoritesRepository repository,
  })  : _repository = repository,
        super(const FavoritesState.started());

  StreamSubscription<List<Entry>>? _streamSubscription;

  Future<void> listen() async {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }
    _streamSubscription = (await _repository.favoritesListStream()).listen(
      (favorites) {
        if (mounted) state = FavoritesState.listening(favorites: favorites);
      },
    );
  }

  Future<void> addBook(Entry book, id) async {
    await _repository.addBook(book, id);
  }

  Future<void> deleteBook(id) async {
    await _repository.deleteBook(id);
  }
}

final favoritesStateNotifierProvider =
    StateNotifierProvider.autoDispose<FavoritesStateNotifier, FavoritesState>(
  (ref) {
    return FavoritesStateNotifier(
      repository: ref.watch(favoritesRepositoryProvider),
    );
  },
);
