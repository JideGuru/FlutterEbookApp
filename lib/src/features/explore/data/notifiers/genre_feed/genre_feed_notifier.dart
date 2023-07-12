import 'dart:async';

import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'genre_feed_notifier.g.dart';

@riverpod
class GenreFeedNotifier extends _$GenreFeedNotifier {
  GenreFeedNotifier() : super();

  late ExploreRepository _exploreRepository;
  late String _url;

  @override
  Future<(List<Entry>, bool)> build(String url) async {
    _exploreRepository = ref.read(exploreRepositoryProvider);
    _url = url;
    return (await _fetch(), false);
  }

  Future<void> fetch() async {
    state = AsyncValue.data((await _fetch(), false));
  }

  Future<List<Entry>> _fetch() async {
    state = const AsyncValue.loading();
    final successOrFailure = await _exploreRepository.getGenreFeed(_url);
    final success = successOrFailure.$1;
    final failure = successOrFailure.$2;
    if (success == null) {
      throw (failure?.description ?? '');
    }
    return success.feed?.entry ?? [];
  }

  Future<void> paginate(int page) async {
    state.maybeWhen(
      data: (data) async {
        List<Entry> books = data.$1;
        state = AsyncValue.data((books, true));
        final successOrFailure =
            await _exploreRepository.getGenreFeed(_url + '&page=$page');
        final success = successOrFailure.$1;
        final failure = successOrFailure.$2;
        if (success == null) {
          throw (failure?.description ?? '');
        }
        List<Entry> newItems = List.from(books)
          ..addAll(success.feed?.entry ?? []);
        state = AsyncValue.data((newItems, false));
      },
      orElse: () {
        return;
      },
    );
  }
}
