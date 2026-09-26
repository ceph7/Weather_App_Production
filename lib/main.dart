import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/core_providers.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/favorites/data/models/favorite_city_model.dart';
import 'features/history/data/models/search_history_model.dart';
import 'features/weather/data/models/weather_cache_model.dart';
import 'features/weather/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR');
  await initializeDateFormatting('en_US');

  await Hive.initFlutter();
  Hive
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(WeatherCacheModelAdapter())
    ..registerAdapter(FavoriteCityModelAdapter())
    ..registerAdapter(SearchHistoryModelAdapter());

  final usersBox = await Hive.openBox<UserModel>(AppConstants.usersBox);
  final weatherCacheBox =
      await Hive.openBox<WeatherCacheModel>(AppConstants.weatherCacheBox);
  final favoritesBox =
      await Hive.openBox<FavoriteCityModel>(AppConstants.favoritesBox);
  final historyBox =
      await Hive.openBox<SearchHistoryModel>(AppConstants.searchHistoryBox);

  runApp(
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
}

class WeatherApp extends ConsumerWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const _AuthGate(),
    );
  }
}

/// Redirige vers Login ou Home selon l'état de session, en gérant le
/// chargement initial (restauration de session) proprement.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
      data: (user) => user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
