part of 'favorites_state_notifier.dart';

@freezed
abstract class FavoritesState with _$FavoritesState {
  const factory FavoritesState.started() = FavoritesStateStarted;

  const factory FavoritesState.listening({
    required List<Entry> favorites,
  }) = FavoritesStateLoadListening;
}
