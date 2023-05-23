import 'dispose.welltested_test.mocks.dart';
import 'dart:async';
import 'package:flutter_ebook_app/database/favorite_helper.dart';
import 'package:flutter_ebook_app/view_models/favorites_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FavoriteDB, StreamSubscription])
void main() {
  late FavoritesProvider favoritesProvider;
  late MockFavoriteDB mockFavoriteDB;
  late MockStreamSubscription<List> mockStreamSubscription;

  setUp(() {
    mockFavoriteDB = MockFavoriteDB();
    mockStreamSubscription = MockStreamSubscription<List>();
    favoritesProvider = FavoritesProvider();
    favoritesProvider.db = mockFavoriteDB;
    favoritesProvider.streamSubscription = mockStreamSubscription;
  });

  test('dispose with non-null stream subscription', () {
    when(mockStreamSubscription.cancel())
        .thenAnswer((realInvocation) async => null);

    favoritesProvider.dispose();

    verify(mockStreamSubscription.cancel()).called(1);
    expect(favoritesProvider.streamSubscription, null);
  });

  test('dispose with null stream subscription', () {
    favoritesProvider.streamSubscription = null;

    favoritesProvider.dispose();

    expect(favoritesProvider.streamSubscription, null);
  });
}
