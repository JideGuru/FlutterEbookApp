import 'listen.welltested_test.mocks.dart';
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

  setUp(() {
    mockFavoriteDB = MockFavoriteDB();
    favoritesProvider = FavoritesProvider();
    favoritesProvider.db = mockFavoriteDB;
  });

  test('listen with null subscription', () async {
    when(mockFavoriteDB.listAllStream())
        .thenAnswer((_) async => Stream.value(<dynamic>[]));

    await favoritesProvider.listen();

    verify(mockFavoriteDB.listAllStream()).called(1);
  });

  test('listen with non-null subscription', () async {
    final mockStreamSubscription = MockStreamSubscription<List>();
    when(mockFavoriteDB.listAllStream())
        .thenAnswer((_) async => Stream.value(<dynamic>[]));
    favoritesProvider.streamSubscription = mockStreamSubscription;

    await favoritesProvider.listen();

    verify(mockStreamSubscription.cancel()).called(1);
    verify(mockFavoriteDB.listAllStream()).called(1);
  });

  test('listen with books', () async {
    final books = [
      {'id': 1, 'title': 'Book 1'},
      {'id': 2, 'title': 'Book 2'},
    ];
    final mockStreamSubscription = MockStreamSubscription<List>();
    when(mockFavoriteDB.listAllStream()).thenAnswer(
        (_) async => Stream.value(books.map((book) => book).toList()));
    favoritesProvider.streamSubscription = mockStreamSubscription;

    /// listener is not being triggered in the test is that the stream fires an event asynchronously,
    /// while the test completes synchronously. To fix it, you should use a `completer` to force the
    /// test to wait for the stream event.
    final completer = Completer();
    when(mockStreamSubscription.cancel()).thenAnswer((_) {
      completer.complete();
      return Future.value();
    });

    await favoritesProvider.listen();

    // Wait for the cancel() to be called after the listener was triggered.
    await completer.future;
    print(favoritesProvider.favorites);
    expect(favoritesProvider.favorites, books);
    verify(mockStreamSubscription.cancel()).called(1);
    verify(mockFavoriteDB.listAllStream()).called(1);
  });

  test('listen with empty books', () async {
    final mockStreamSubscription = MockStreamSubscription<List>();
    when(mockFavoriteDB.listAllStream())
        .thenAnswer((_) async => Stream.value(<dynamic>[]));
    favoritesProvider.streamSubscription = mockStreamSubscription;

    await favoritesProvider.listen();

    expect(favoritesProvider.favorites, []);
    verify(mockStreamSubscription.cancel()).called(1);
    verify(mockFavoriteDB.listAllStream()).called(1);
  });
}
