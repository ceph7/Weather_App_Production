import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:weather_app/features/favorites/data/models/favorite_city_model.dart';
import 'package:weather_app/features/favorites/data/repositories/favorites_repository.dart';

import '../../../../helpers/hive_test_helper.dart';

void main() {
  late Box<FavoriteCityModel> box;
  late FavoritesRepository repository;

  setUpAll(() {
    Hive.registerAdapter(FavoriteCityModelAdapter());
  });

  setUp(() async {
    await HiveTestHelper.setUp();
    box = await Hive.openBox<FavoriteCityModel>('favorites_test_box');
    repository = FavoritesRepository(box);
  });

  tearDown(() async {
    await box.close();
    await HiveTestHelper.tearDown();
  });

  group('isFavorite', () {
    test('retourne false quand la ville n\'a jamais été ajoutée', () {
      expect(repository.isFavorite('Paris'), false);
    });
  });

  group('toggleFavorite', () {
    test('ajoute la ville aux favoris si elle n\'y est pas', () async {
      await repository.toggleFavorite('Paris');

      expect(repository.isFavorite('Paris'), true);
    });

    test('retire la ville des favoris si elle y est déjà', () async {
      await repository.toggleFavorite('Paris');
      await repository.toggleFavorite('Paris');

      expect(repository.isFavorite('Paris'), false);
    });

    test('normalise la casse et les espaces pour la clé', () async {
      await repository.toggleFavorite('  Paris  ');

      expect(repository.isFavorite('paris'), true);
      expect(repository.isFavorite('PARIS'), true);
    });
  });

  group('getFavorites', () {
    test('retourne les favoris triés du plus récent au plus ancien', () async {
      await repository.toggleFavorite('Paris');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repository.toggleFavorite('Tokyo');

      final favorites = repository.getFavorites();

      expect(favorites.first, 'Tokyo');
      expect(favorites, contains('Paris'));
    });

    test('retourne une liste vide si aucun favori', () {
      expect(repository.getFavorites(), isEmpty);
    });
  });
}
