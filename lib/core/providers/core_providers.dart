import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../storage/secure_token_storage.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/favorites/data/models/favorite_city_model.dart';
import '../../features/history/data/models/search_history_model.dart';
import '../../features/weather/data/models/weather_cache_model.dart';

/// --- Hive boxes ---
/// Ces providers supposent que les box ont déjà été ouvertes dans `main()`
/// avant `runApp` (voir main.dart). On les expose ici en overrides.
final usersBoxProvider = Provider<Box<UserModel>>((ref) {
  throw UnimplementedError('usersBoxProvider doit être overridé dans main()');
});

final weatherCacheBoxProvider = Provider<Box<WeatherCacheModel>>((ref) {
  throw UnimplementedError(
    'weatherCacheBoxProvider doit être overridé dans main()',
  );
});

final favoritesBoxProvider = Provider<Box<FavoriteCityModel>>((ref) {
  throw UnimplementedError(
    'favoritesBoxProvider doit être overridé dans main()',
  );
});

final historyBoxProvider = Provider<Box<SearchHistoryModel>>((ref) {
  throw UnimplementedError(
    'historyBoxProvider doit être overridé dans main()',
  );
});

/// --- Infra ---
final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorageImpl();
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

/// Stream exposant l'état de connectivité en direct (pour bannière offline).
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(networkInfoProvider).onConnectivityChanged;
});

/// Dio "nu" pour OpenWeatherMap, SANS intercepteur d'auth.
/// L'intercepteur est ajouté par `weatherDioProvider` dans auth_providers.dart
/// (le module auth dépend du module core, pas l'inverse — cf. Clean
/// Architecture : on évite la dépendance circulaire en laissant le module
/// qui connaît le refresh logic (auth) enrichir ce Dio de base).
final baseDioProvider = Provider<Dio>((ref) => DioClient.createWeatherClient());

final weatherCacheValidityProvider = Provider<Duration>((ref) {
  return AppConstants.weatherCacheValidity;
});
