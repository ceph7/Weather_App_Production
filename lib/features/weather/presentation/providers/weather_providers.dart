import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/weather_local_datasource.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/weather_usecases.dart';

final weatherRemoteDatasourceProvider = Provider<WeatherRemoteDatasource>((ref) {
  return WeatherRemoteDatasourceImpl(ref.watch(weatherDioProvider));
});

final weatherLocalDatasourceProvider = Provider<WeatherLocalDatasource>((ref) {
  return WeatherLocalDatasourceImpl(ref.watch(weatherCacheBoxProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    remoteDatasource: ref.watch(weatherRemoteDatasourceProvider),
    localDatasource: ref.watch(weatherLocalDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getCurrentWeatherUseCaseProvider = Provider((ref) {
  return GetCurrentWeatherUseCase(ref.watch(weatherRepositoryProvider));
});

final getForecastUseCaseProvider = Provider((ref) {
  return GetForecastUseCase(ref.watch(weatherRepositoryProvider));
});

final getCachedWeatherListUseCaseProvider = Provider((ref) {
  return GetCachedWeatherListUseCase(ref.watch(weatherRepositoryProvider));
});

/// Ville actuellement sélectionnée/recherchée (pilote l'écran d'accueil).
final selectedCityProvider = StateProvider<String>((ref) => 'Lomé');

/// Météo actuelle pour la ville sélectionnée — se recharge à chaque
/// changement de [selectedCityProvider].
final currentWeatherProvider =
    FutureProvider.autoDispose<WeatherEntity>((ref) async {
  final city = ref.watch(selectedCityProvider);
  final result = await ref.watch(getCurrentWeatherUseCaseProvider).call(city);
  return result.match((failure) => throw failure, (weather) => weather);
});

/// Prévisions 5 jours pour la ville sélectionnée.
final forecastProvider =
    FutureProvider.autoDispose<List<ForecastEntity>>((ref) async {
  final city = ref.watch(selectedCityProvider);
  final result = await ref.watch(getForecastUseCaseProvider).call(city);
  return result.match((failure) => throw failure, (forecasts) => forecasts);
});

/// Liste des météos en cache (pour l'écran "hors-ligne" / recherches récentes).
final cachedWeatherListProvider =
    FutureProvider.autoDispose<List<WeatherEntity>>((ref) async {
  final result = await ref.watch(getCachedWeatherListUseCaseProvider).call();
  return result.match((failure) => throw failure, (list) => list);
});

/// Petit helper pour extraire un message d'erreur lisible d'un objet
/// AsyncError dont le `error` est un [Failure].
extension FailureMessage on Object {
  String readableMessage(BuildContext context) {
    if (this is Failure) return (this as Failure).message;
    return AppLocalizations.of(context).unknownError;
  }
}
