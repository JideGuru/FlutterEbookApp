import 'package:dartz/dartz.dart';
import 'package:flutter_ebook_app/src/features/common/constants/api.dart';
import 'package:flutter_ebook_app/src/features/common/data/failures/http_failure.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/common/data/providers/dio_provider.dart';
import 'package:flutter_ebook_app/src/features/common/data/repositories/book/book_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreRepository extends BookRepository {
  ExploreRepository(super.httpClient);

  Future<Either<HttpFailure, CategoryFeed>> getGenreFeed(String url) {
    String stripedUrl = url.replaceAll(ApiEndpoints.baseURL, '');
    final failureOrSuccess = getCategory(stripedUrl);
    return failureOrSuccess;
  }
}

final exploreRepositoryProvider =
    Provider.autoDispose<ExploreRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ExploreRepository(dio);
});
