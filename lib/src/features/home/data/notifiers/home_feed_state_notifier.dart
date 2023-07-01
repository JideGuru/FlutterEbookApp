import 'package:flutter/foundation.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/home/data/repositories/home_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'home_feed_state.dart';

part 'home_feed_state_notifier.freezed.dart';

class HomeFeedStateNotifier extends StateNotifier<HomeFeedState> {
  final HomeRepository _homeRepository;

  HomeFeedStateNotifier({
    required HomeRepository homeRepository,
  })  : _homeRepository = homeRepository,
        super(const HomeFeedState.started());

  Future<void> fetch() async {
    if (mounted) {
      state = const HomeFeedState.loadInProgress();
    }
    final popularFeedSuccessOrFailure =
        await _homeRepository.getPopularHomeFeed();
    final recentFeedSuccessOrFailure =
        await _homeRepository.getRecentHomeFeed();
    CategoryFeed? popularFeed = popularFeedSuccessOrFailure.$1;
    CategoryFeed? recentFeed = recentFeedSuccessOrFailure.$1;

    if (mounted) {
      if (popularFeed != null && recentFeed != null) {
        state = HomeFeedState.loadSuccess(
          popular: popularFeed,
          recent: recentFeed,
        );
      } else {
        state = const HomeFeedState.loadFailure();
      }
    }
  }
}

final homeDataStateNotifierProvider =
    StateNotifierProvider.autoDispose<HomeFeedStateNotifier, HomeFeedState>(
  (ref) {
    return HomeFeedStateNotifier(
      homeRepository: ref.watch(homeRepositoryProvider),
    );
  },
);
