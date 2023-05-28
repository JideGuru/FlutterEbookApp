part of 'book_details_state_notifier.dart';

@freezed
abstract class BookDetailsState with _$BookDetailsState {
  const factory BookDetailsState.started() = BookDetailsStateStarted;

  const factory BookDetailsState.loadInProgress() =
      BookDetailsStateLoadInProgress;

  const factory BookDetailsState.loadSuccess({
    required CategoryFeed related,
  }) = BookDetailsStateLoadSuccess;

  const factory BookDetailsState.loadFailure() = BookDetailsStateLoadFailure;
}
