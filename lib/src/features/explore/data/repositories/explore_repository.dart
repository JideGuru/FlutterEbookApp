import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreRepository extends BookRepository {
  ExploreRepository(super.httpClient);

  Future<BookRepositoryData> getGenreFeed(
    String url,
  ) {
    final String stripedUrl = url.replaceAll(ApiEndpoints.baseURL, '');
    final successOrFailure = getCategory(stripedUrl);
    return successOrFailure;
  }
}

final exploreRepositoryProvider =
    Provider.autoDispose<ExploreRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ExploreRepository(dio);
});
