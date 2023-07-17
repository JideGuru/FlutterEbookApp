import 'package:flutter_ebook_app/src/features/common/constants/api.dart';
import 'package:flutter_ebook_app/src/features/common/data/providers/dio_provider.dart';
import 'package:flutter_ebook_app/src/features/common/data/repositories/book/book_repository.dart';
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
