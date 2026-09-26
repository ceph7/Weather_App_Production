import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:weather_app/features/history/data/models/search_history_model.dart';
import 'package:weather_app/features/history/data/repositories/history_repository.dart';

import '../../../../helpers/hive_test_helper.dart';

void main() {
  late Box<SearchHistoryModel> box;
  late HistoryRepository repository;

  setUpAll(() {
    Hive.registerAdapter(SearchHistoryModelAdapter());
  });

  setUp(() async {
    await HiveTestHelper.setUp();
    box = await Hive.openBox<SearchHistoryModel>('history_test_box');
    repository = HistoryRepository(box);
  });

  tearDown(() async {
    await box.close();
    await HiveTestHelper.tearDown();
  });

  group('addSearch', () {
    test('ajoute une entrée récupérable via getHistory', () async {
      await repository.addSearch('Lomé');

      final history = repository.getHistory();

      expect(history.length, 1);
      expect(history.first.cityName, 'Lomé');
    });

    test('remplace l\'entrée existante plutôt que d\'en créer une seconde '
        'pour la même ville (clé normalisée)', () async {
      await repository.addSearch('Lomé');
      await repository.addSearch('lomé');

      expect(repository.getHistory().length, 1);
    });

    test('conserve au maximum maxEntries entrées, en purgeant les plus '
        'anciennes', () async {
      for (var i = 0; i < HistoryRepository.maxEntries + 5; i++) {
        await repository.addSearch('Ville$i');
        // Garantit un ordre temporel strict entre les entrées.
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }

      final history = repository.getHistory();

      expect(history.length, HistoryRepository.maxEntries);
      // Les toutes premières villes ajoutées doivent avoir été purgées.
      expect(
        history.any((e) => e.cityName == 'Ville0'),
        false,
        reason: 'la plus ancienne entrée doit avoir été supprimée',
      );
    });
  });

  group('getHistory', () {
    test('trie les entrées de la plus récente à la plus ancienne', () async {
      await repository.addSearch('Paris');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repository.addSearch('Tokyo');

      final history = repository.getHistory();

      expect(history.first.cityName, 'Tokyo');
      expect(history.last.cityName, 'Paris');
    });
  });

  group('clearHistory', () {
    test('vide complètement l\'historique', () async {
      await repository.addSearch('Paris');
      await repository.clearHistory();

      expect(repository.getHistory(), isEmpty);
    });
  });
}
