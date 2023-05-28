part of 'genre_feed_state_notifier.dart';

@freezed
abstract class GenreFeedState with _$GenreFeedState {
  const factory GenreFeedState.started() = GenreFeedStateStarted;

  const factory GenreFeedState.loadInProgress() = GenreFeedStateLoadInProgress;

  const factory GenreFeedState.loadSuccess({
    required List<Entry> books,
    required bool loadingMore,
  }) = GenreFeedStateLoadSuccess;

  const factory GenreFeedState.loadFailure() = GenreFeedStateLoadFailure;
}
