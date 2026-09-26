import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/providers/core_providers.dart';
import 'package:weather_app/features/auth/data/models/user_model.dart';
import 'package:weather_app/features/favorites/data/models/favorite_city_model.dart';
import 'package:weather_app/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:weather_app/features/history/data/models/search_history_model.dart';
import 'package:weather_app/features/weather/data/models/weather_cache_model.dart';
import 'package:weather_app/features/weather/presentation/providers/weather_providers.dart';
import 'package:weather_app/features/weather/presentation/screens/home_screen.dart';
import 'package:weather_app/features/weather/presentation/screens/saved_screen.dart';
import 'package:weather_app/features/weather/presentation/screens/search_screen.dart';

/// Test d'intégration : une fois connecté, l'utilisateur navigue entre les
/// trois onglets, recherche une ville (ce qui l'ajoute à l'historique) puis
/// la marque comme favorite, et retrouve bien cette ville dans l'onglet
/// "Enregistrés". Ne dépend d'aucun appel réseau réel.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Box<UserModel> usersBox;
  late Box<WeatherCacheModel> weatherCacheBox;
  late Box<FavoriteCityModel> favoritesBox;
  late Box<SearchHistoryModel> historyBox;

  setUp(() async {
    await Hive.initFlutter('integration_test_nav');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WeatherCacheModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FavoriteCityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SearchHistoryModelAdapter());
    }

    usersBox = await Hive.openBox<UserModel>('${AppConstants.usersBox}_nav_it');
    weatherCacheBox = await Hive.openBox<WeatherCacheModel>(
      '${AppConstants.weatherCacheBox}_nav_it',
    );
    favoritesBox = await Hive.openBox<FavoriteCityModel>(
      '${AppConstants.favoritesBox}_nav_it',
    );
    historyBox = await Hive.openBox<SearchHistoryModel>(
      '${AppConstants.searchHistoryBox}_nav_it',
    );
  });

  tearDown(() async {
    await usersBox.clear();
    await weatherCacheBox.clear();
    await favoritesBox.clear();
    await historyBox.clear();
    await usersBox.close();
    await weatherCacheBox.close();
    await favoritesBox.close();
    await historyBox.close();
  });

  Widget buildHome() {
    return ProviderScope(
      overrides: [
        usersBoxProvider.overrideWithValue(usersBox),
        weatherCacheBoxProvider.overrideWithValue(weatherCacheBox),
        favoritesBoxProvider.overrideWithValue(favoritesBox),
        historyBoxProvider.overrideWithValue(historyBox),
        // Fige la ville sélectionnée pour ne pas déclencher d'appel réseau
        // vers OpenWeatherMap dès l'ouverture de l'onglet météo.
        selectedCityProvider.overrideWith((ref) => 'Lomé'),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets(
    'navigue entre les onglets, recherche une ville puis la marque comme '
    'favorite, retrouvée ensuite dans "Enregistrés"',
    (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();

      // Onglet Recherche.
      await tester.tap(find.text('Recherche'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('city_search_field')),
        'Kara',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // La recherche a changé la ville sélectionnée globalement.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SearchScreen)),
      );
      expect(container.read(selectedCityProvider), 'Kara');

      // On ajoute directement "Kara" aux favoris via le repository exposé
      // par les providers (pas besoin d'attendre un appel réseau réel ici :
      // ce test couvre la navigation + la persistance, pas l'API météo).
      await container.read(favoritesControllerProvider.notifier).toggle('Kara');
      await tester.pumpAndSettle();

      // Onglet Enregistrés : la ville favorite doit y apparaître.
      await tester.tap(find.text('Enregistrés'));
      await tester.pumpAndSettle();
      expect(find.byType(SavedScreen), findsOneWidget);
      expect(find.text('Kara'), findsOneWidget);

      // Retour à l'onglet Météo : la navigation ne doit pas planter.
      await tester.tap(find.text('Météo'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsNothing);
    },
  );
}
