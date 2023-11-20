import 'dart:async';

import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'genre_feed_notifier.g.dart';

typedef GenreFeedData = ({List<Entry> books, bool loadingMore});

@riverpod
class GenreFeedNotifier extends _$GenreFeedNotifier {
  GenreFeedNotifier() : super();

  late ExploreRepository _exploreRepository;
  late String _url;

  @override
  Future<GenreFeedData> build(String url) async {
    _exploreRepository = ref.read(exploreRepositoryProvider);
    _url = url;
    return (books: await _fetch(), loadingMore: false);
  }

  Future<void> fetch() async {
    state = AsyncValue.data((books: await _fetch(), loadingMore: false));
  }

  Future<List<Entry>> _fetch() async {
    state = const AsyncValue.loading();
    final successOrFailure = await _exploreRepository.getGenreFeed(_url);
    final success = successOrFailure.feed;
    final failure = successOrFailure.failure;
    if (success == null) {
      throw failure?.description ?? '';
    }
    return success.feed?.entry ?? [];
  }

  Future<void> paginate(int page) async {
    state.maybeWhen(
      data: (data) async {
        final List<Entry> books = data.books;
        state = AsyncValue.data((books: books, loadingMore: true));
        final successOrFailure =
            await _exploreRepository.getGenreFeed('$_url&page=$page');
        final success = successOrFailure.feed;
        final failure = successOrFailure.failure;
        if (success == null) {
          throw failure?.description ?? '';
        }
        final List<Entry> newItems = List.from(books)
          ..addAll(success.feed?.entry ?? []);
        state = AsyncValue.data((books: newItems, loadingMore: false));
      },
      orElse: () {
        return;
      },
    );
  }
}
