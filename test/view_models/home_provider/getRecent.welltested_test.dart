import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'getRecent.welltested_test.mocks.dart';

@GenerateMocks([CategoryFeed])
void main() {
  late HomeProvider homeProvider;
  late MockCategoryFeed mockCategoryFeed;

  setUp(() {
    mockCategoryFeed = MockCategoryFeed();
    homeProvider = HomeProvider();
  });

  test('Get recent categories successfully', () async {
    // Stub the values of recent category feed
    homeProvider.recent = mockCategoryFeed;

    // Call the method
    final recent = await homeProvider.getRecent();

    // Verify the results
    expect(recent, mockCategoryFeed);
  });
}
