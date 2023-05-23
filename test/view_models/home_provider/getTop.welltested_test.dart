import 'dart:math';

import 'getTop.welltested_test.mocks.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Api, CategoryFeed])
void main() {
  late HomeProvider homeProvider;
  late MockCategoryFeed mockCategoryFeed;

  setUp(() {
    mockCategoryFeed = MockCategoryFeed();

    homeProvider = HomeProvider();
  });

  test('Get top gets the top category feed', () async {
    // Arrange
    homeProvider.top = mockCategoryFeed;

    // Act
    final top = await homeProvider.getTop();

    // Assert
    expect(top, mockCategoryFeed);
  });
}
