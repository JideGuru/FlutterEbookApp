import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class HomeRepository extends BookRepository {
  HomeRepository(super.httpClient);

  Future<BookRepositoryData> getPopularHomeFeed() {
    final successOrFailure = getCategory(ApiEndpoints.popular);
    return successOrFailure;
  }

  Future<BookRepositoryData> getRecentHomeFeed() {
    final successOrFailure = getCategory(ApiEndpoints.recent);
    return successOrFailure;
  }
}

final homeRepositoryProvider = Provider.autoDispose<HomeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeRepository(dio);
});
