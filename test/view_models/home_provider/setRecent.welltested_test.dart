import 'setRecent.welltested_test.mocks.dart';
import 'package:flutter_ebook_app/models/category.dart';

import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([CategoryFeed])
void main() {
  late HomeProvider homeProvider;

  late MockCategoryFeed mockRecent;

  setUp(() {
    mockRecent = MockCategoryFeed();
    homeProvider = HomeProvider();
  });

  test('Set recent category feed', () {
    homeProvider.setRecent(mockRecent);
    expect(homeProvider.recent, mockRecent);
  });

  test('Notify listeners after setting recent category feed', () {
    homeProvider.addListener(() {
      expect(homeProvider.recent, mockRecent);
    });
    homeProvider.setRecent(mockRecent);
  });
}
