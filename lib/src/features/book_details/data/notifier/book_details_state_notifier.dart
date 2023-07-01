import 'package:flutter_ebook_app/src/features/book_details/data/repositories/book_details_repository.dart';
import 'package:flutter_ebook_app/src/features/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_details_state.dart';

part 'book_details_state_notifier.freezed.dart';

class BookDetailsStateNotifier extends StateNotifier<BookDetailsState> {
  final BookDetailsRepository _bookDetailsRepository;

  BookDetailsStateNotifier({
    required BookDetailsRepository bookDetailsRepository,
  })  : _bookDetailsRepository = bookDetailsRepository,
        super(const BookDetailsState.started());

  Future<void> fetch(String url) async {
    if (mounted) {
      state = const BookDetailsState.loadInProgress();
    }

    final successOrFailure = await _bookDetailsRepository.getRelatedFeed(url);

    final success = successOrFailure.$1;
    final failure = successOrFailure.$2;
    if (mounted) {
      if (failure is HttpFailure) {
        state = const BookDetailsState.loadFailure();
      }
      if (success is CategoryFeed) {
        state = BookDetailsState.loadSuccess(related: success);
      }
    }
  }
}

final bookDetailsStateNotifierProvider = StateNotifierProvider.autoDispose<
    BookDetailsStateNotifier, BookDetailsState>(
  (ref) {
    return BookDetailsStateNotifier(
      bookDetailsRepository: ref.watch(bookDetailsRepositoryProvider),
    );
  },
);
