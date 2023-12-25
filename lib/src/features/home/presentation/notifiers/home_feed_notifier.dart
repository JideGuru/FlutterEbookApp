import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_feed_notifier.g.dart';

typedef HomeFeedData = ({CategoryFeed popularFeed, CategoryFeed recentFeed});

@riverpod
class HomeFeedNotifier extends _$HomeFeedNotifier {
  HomeFeedNotifier() : super();

  @override
  Future<HomeFeedData> build() async {
    state = const AsyncValue.loading();
    return _fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => _fetch());
  }

  Future<HomeFeedData> _fetch() async {
    final HomeRepository homeRepository = ref.read(homeRepositoryProvider);
    final popularFeedSuccessOrFailure =
        await homeRepository.getPopularHomeFeed();
    final recentFeedSuccessOrFailure = await homeRepository.getRecentHomeFeed();
    final popularFeed = popularFeedSuccessOrFailure.feed;
    final recentFeed = recentFeedSuccessOrFailure.feed;
    if (popularFeed == null) {
      throw popularFeedSuccessOrFailure.failure!.description;
    }

    if (recentFeed == null) {
      throw recentFeedSuccessOrFailure.failure!.description;
    }
    return (popularFeed: popularFeed, recentFeed: recentFeed);
  }
}
