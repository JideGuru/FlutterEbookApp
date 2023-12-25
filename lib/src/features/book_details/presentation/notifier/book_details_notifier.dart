import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/book_details/data/repositories/book_details_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_details_notifier.g.dart';

@riverpod
class BookDetailsNotifier extends _$BookDetailsNotifier {
  late BookDetailsRepository _bookDetailsRepository;

  late String _url;

  BookDetailsNotifier();

  @override
  Future<CategoryFeed> build(String url) async {
    _bookDetailsRepository = ref.watch(bookDetailsRepositoryProvider);
    _url = url;
    return _fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  Future<CategoryFeed> _fetch() async {
    state = const AsyncValue.loading();
    final successOrFailure = await _bookDetailsRepository.getRelatedFeed(_url);

    final success = successOrFailure.feed;
    final failure = successOrFailure.failure;

    if (failure is HttpFailure) {
      throw failure.description;
    }
    return success!;
  }
}
