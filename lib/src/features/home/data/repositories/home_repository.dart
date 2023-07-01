import 'package:flutter_ebook_app/src/features/common/constants/api.dart';
import 'package:flutter_ebook_app/src/features/common/data/failures/http_failure.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/common/data/providers/dio_provider.dart';
import 'package:flutter_ebook_app/src/features/common/data/repositories/book/book_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeRepository extends BookRepository {
  HomeRepository(super.httpClient);

  Future<(CategoryFeed?, HttpFailure?)> getPopularHomeFeed() {
    final successOrFailure = getCategory(ApiEndpoints.popular);
    return successOrFailure;
  }

  Future<(CategoryFeed?, HttpFailure?)> getRecentHomeFeed() {
    final successOrFailure = getCategory(ApiEndpoints.recent);
    return successOrFailure;
  }
}

final homeRepositoryProvider = Provider.autoDispose<HomeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeRepository(dio);
});
