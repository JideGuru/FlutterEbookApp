part of 'home_feed_state_notifier.dart';

@freezed
abstract class HomeFeedState with _$HomeFeedState {
  const factory HomeFeedState.started() = HomeFeedStateStarted;

  const factory HomeFeedState.loadInProgress() = HomeFeedStateLoadInProgress;

  const factory HomeFeedState.loadSuccess({
    required CategoryFeed popular,
    required CategoryFeed recent,
  }) = HomeFeedStateLoadSuccess;

  const factory HomeFeedState.loadFailure() = HomeFeedStateLoadFailure;
}
