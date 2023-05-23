
import 'getFavoritesStream.welltested_test.mocks.dart';import 'dart:async';

import 'package:flutter_ebook_app/database/favorite_helper.dart';
import 'package:flutter_ebook_app/view_models/favorites_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FavoriteDB])
void main() {
  late FavoritesProvider favoritesProvider;
  late MockFavoriteDB mockFavoriteDB;

  setUp(() {
    favoritesProvider = FavoritesProvider();
    mockFavoriteDB = MockFavoriteDB();
    favoritesProvider.db = mockFavoriteDB;
  });

  test('getFavoritesStream returns a stream of favorites', () async {
    final streamController = StreamController<List<dynamic>>();
    final expectedFavorites = [
      {'id': 1, 'title': 'Book 1'},
      {'id': 2, 'title': 'Book 2'},
      {'id': 3, 'title': 'Book 3'},
    ];
    streamController.add(expectedFavorites);
    when(mockFavoriteDB.listAllStream()).thenAnswer((_) => Future.value(streamController.stream));

    final stream = await favoritesProvider.getFavoritesStream();

    expect(stream, isA<Stream<List>>());
    expect(await stream.first, expectedFavorites);
  });

  test('getFavoritesStream returns an empty stream if no favorites are present', () async {
    final streamController = StreamController<List<dynamic>>();
    streamController.add([]);
    when(mockFavoriteDB.listAllStream()).thenAnswer((_) => Future.value(streamController.stream));

    final stream = await favoritesProvider.getFavoritesStream();

    expect(stream, isA<Stream<List>>());
    expect(await stream.first, []);
  });

  test('getFavoritesStream returns an error stream if an error occurs', () async {
    final streamController = StreamController<List<dynamic>>();
    streamController.addError('Error');
    when(mockFavoriteDB.listAllStream()).thenAnswer((_) => Future.value(streamController.stream));

    final stream = await favoritesProvider.getFavoritesStream();

    expect(stream, isA<Stream<List>>());
    expect(() async => await stream.first, throwsA(isA<String>()));
  });
}