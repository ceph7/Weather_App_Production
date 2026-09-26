import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/providers/core_providers.dart';
import 'package:weather_app/features/auth/data/models/user_model.dart';
import 'package:weather_app/features/auth/presentation/screens/login_screen.dart';
import 'package:weather_app/features/favorites/data/models/favorite_city_model.dart';
import 'package:weather_app/features/history/data/models/search_history_model.dart';
import 'package:weather_app/features/weather/data/models/weather_cache_model.dart';
import 'package:weather_app/features/weather/presentation/screens/home_screen.dart';
import 'package:weather_app/main.dart';

/// Test d'intégration bout-en-bout : un nouvel utilisateur crée un compte,
/// est redirigé vers l'accueil, se déconnecte, puis se reconnecte avec les
/// mêmes identifiants. Exerce la vraie pile (Hive + Riverpod + navigation)
/// sans aucun mock, à l'exception du réseau météo (pas de clé API en CI).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Box<UserModel> usersBox;
  late Box<WeatherCacheModel> weatherCacheBox;
  late Box<FavoriteCityModel> favoritesBox;
  late Box<SearchHistoryModel> historyBox;

  setUp(() async {
    await Hive.initFlutter('integration_test_auth');
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

    usersBox = await Hive.openBox<UserModel>('${AppConstants.usersBox}_it');
    weatherCacheBox = await Hive.openBox<WeatherCacheModel>(
      '${AppConstants.weatherCacheBox}_it',
    );
    favoritesBox = await Hive.openBox<FavoriteCityModel>(
      '${AppConstants.favoritesBox}_it',
    );
    historyBox = await Hive.openBox<SearchHistoryModel>(
      '${AppConstants.searchHistoryBox}_it',
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

  testWidgets(
    'un nouvel utilisateur peut créer un compte, arriver sur l\'accueil, '
    'se déconnecter puis se reconnecter',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            usersBoxProvider.overrideWithValue(usersBox),
            weatherCacheBoxProvider.overrideWithValue(weatherCacheBox),
            favoritesBoxProvider.overrideWithValue(favoritesBox),
            historyBoxProvider.overrideWithValue(historyBox),
          ],
          child: const WeatherApp(),
        ),
      );
      await tester.pumpAndSettle();

      // On démarre sans session : l'écran de connexion doit être visible.
      expect(find.byType(LoginScreen), findsOneWidget);

      // Aller vers l'inscription.
      await tester.tap(find.byKey(const Key('go_to_register_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('register_name_field')),
        'Ada Lovelace',
      );
      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'ada@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'secret123',
      );
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      // L'inscription réussie ramène sur la pile précédente, dont l'état
      // d'authentification bascule automatiquement vers l'accueil.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(usersBox.containsKey('ada@example.com'), true);

      // Déconnexion depuis l'accueil.
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Reconnexion avec les identifiants créés à l'instant.
      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'ada@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'secret123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );
}
