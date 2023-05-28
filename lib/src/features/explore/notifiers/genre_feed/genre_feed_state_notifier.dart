import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/explore/repositories/explore_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'genre_feed_state.dart';

part 'genre_feed_state_notifier.freezed.dart';

class GenreFeedStateNotifier extends StateNotifier<GenreFeedState> {
  final ExploreRepository _exploreRepository;
  final String url;

  GenreFeedStateNotifier({
    required ExploreRepository exploreRepository,
    required this.url,
  })  : _exploreRepository = exploreRepository,
        super(const GenreFeedState.started());

  Future<void> fetch() async {
    if (mounted) {
      state = const GenreFeedState.loadInProgress();
    }

    final failureOrSuccess = await _exploreRepository.getGenreFeed(url);
    failureOrSuccess.fold(
      (failure) {
        if (mounted) state = const GenreFeedState.loadFailure();
      },
      (success) {
        if (mounted) {
          state = GenreFeedState.loadSuccess(
            loadingMore: false,
            books: success.feed?.entry ?? [],
          );
        }
      },
    );
  }

  Future<void> paginate(int page) async {
    state.maybeWhen(
      loadSuccess: (books, loadingMore) async {
        if (mounted) {
          state = GenreFeedState.loadSuccess(
            books: books,
            loadingMore: true,
          );

          final failureOrSuccess =
              await _exploreRepository.getGenreFeed(url + '&page=$page');
          failureOrSuccess.fold(
            (failure) {
              if (mounted) state = const GenreFeedState.loadFailure();
            },
            (success) {
              if (mounted) {
                List<Entry> newItems = List.from(books)
                  ..addAll(success.feed?.entry ?? []);
                state = GenreFeedState.loadSuccess(
                  loadingMore: false,
                  books: newItems,
                );
              }
            },
          );
        }
      },
      orElse: () {
        return;
      },
    );
  }
}

final genreFeedStateNotifierProvider = StateNotifierProvider.family
    .autoDispose<GenreFeedStateNotifier, GenreFeedState, String>(
  (ref, link) {
    return GenreFeedStateNotifier(
      exploreRepository: ref.watch(exploreRepositoryProvider),
      url: link,
    );
  },
);
