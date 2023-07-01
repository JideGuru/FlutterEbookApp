import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_ebook_app/src/features/features.dart';

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

    final successOrFailure = await _exploreRepository.getGenreFeed(url);
    final success = successOrFailure.$1;
    final failure = successOrFailure.$2;
    if (mounted) {
      if (failure is HttpFailure) {
        state = const GenreFeedState.loadFailure();
      }
      if (success is CategoryFeed) {
        state = GenreFeedState.loadSuccess(
          loadingMore: false,
          books: success.feed?.entry ?? [],
        );
      }
    }
  }

  Future<void> paginate(int page) async {
    state.maybeWhen(
      loadSuccess: (books, loadingMore) async {
        if (mounted) {
          state = GenreFeedState.loadSuccess(
            books: books,
            loadingMore: true,
          );

          final successOrFailure =
              await _exploreRepository.getGenreFeed(url + '&page=$page');
          final success = successOrFailure.$1;
          final failure = successOrFailure.$2;
          if (mounted) {
            if (failure is HttpFailure) {
              state = const GenreFeedState.loadFailure();
            }
            if (success is CategoryFeed) {
              List<Entry> newItems = List.from(books)
                ..addAll(success.feed?.entry ?? []);
              state = GenreFeedState.loadSuccess(
                loadingMore: false,
                books: newItems,
              );
            }
          }
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
