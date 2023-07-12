import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/home/data/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_feed_notifier.g.dart';

@riverpod
class HomeFeedNotifier extends _$HomeFeedNotifier {
  HomeFeedNotifier() : super();

  @override
  Future<(CategoryFeed, CategoryFeed)> build() async {
    state = const AsyncValue.loading();
    return await _fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetch());
  }

  Future<(CategoryFeed, CategoryFeed)> _fetch() async {
    HomeRepository _homeRepository = ref.read(homeRepositoryProvider);
    final popularFeedSuccessOrFailure =
        await _homeRepository.getPopularHomeFeed();
    final recentFeedSuccessOrFailure =
        await _homeRepository.getRecentHomeFeed();
    CategoryFeed? popularFeed = popularFeedSuccessOrFailure.$1;
    CategoryFeed? recentFeed = recentFeedSuccessOrFailure.$1;
    if (popularFeed == null) {
      throw (popularFeedSuccessOrFailure.$2!.description);
    }

    if (recentFeed == null) throw (recentFeedSuccessOrFailure.$2!.description);
    return (popularFeed, recentFeed);
  }
}
