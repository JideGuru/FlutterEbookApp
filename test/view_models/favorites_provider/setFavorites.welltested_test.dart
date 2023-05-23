import 'package:flutter_ebook_app/view_models/favorites_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late FavoritesProvider favoritesProvider;

  setUp(() {
    favoritesProvider = FavoritesProvider();
  });

  test('setFavorites with empty list', () {
    final emptyList = <dynamic>[];
    bool notifyListenersCalled = false;
    favoritesProvider.addListener(() => {notifyListenersCalled = true});

    favoritesProvider.setFavorites(emptyList);

    expect(favoritesProvider.favorites, emptyList);
    expect(notifyListenersCalled, true);
  });

  test('setFavorites with non-empty list', () {
    final nonEmptyList = [1, 2, 3];
    bool notifyListenersCalled = false;
    favoritesProvider.addListener(() => {notifyListenersCalled = true});

    favoritesProvider.setFavorites(nonEmptyList);

    expect(favoritesProvider.favorites, nonEmptyList);
    expect(notifyListenersCalled, true);
  });
}
