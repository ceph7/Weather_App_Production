import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';

/// Stratégie : "network-first avec fallback cache".
/// - En ligne : appelle l'API, met à jour le cache, retourne les données fraîches.
///   Si l'appel échoue quand même (ville inconnue, erreur serveur...), tente
///   le cache avant d'abandonner.
/// - Hors ligne : sert directement le cache s'il existe, sinon échoue proprement.
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDatasource remoteDatasource;
  final WeatherLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(String city) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final apiModel = await remoteDatasource.getCurrentWeather(city);
        await localDatasource.cacheWeather(city, apiModel);
        return Right(apiModel.toEntity());
      } on ServerException catch (e) {
        return _fallbackToCache(city, ServerFailure(e.message));
      } on NetworkException catch (e) {
        return _fallbackToCache(city, NetworkFailure(e.message));
      } catch (_) {
        return _fallbackToCache(city, const UnknownFailure());
      }
    } else {
      return _fallbackToCache(city, const NetworkFailure());
    }
  }

  Either<Failure, WeatherEntity> _fallbackToCache(
    String city,
    Failure originalFailure,
  ) {
    final cached = localDatasource.getCachedWeather(city);
    if (cached != null) {
      return Right(cached.toEntity(isFromCache: true));
    }
    return Left(originalFailure);
  }

  @override
  Future<Either<Failure, List<ForecastEntity>>> getForecast(String city) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(
        NetworkFailure('Les prévisions détaillées nécessitent une connexion.'),
      );
    }
    try {
      final forecasts = await remoteDatasource.getForecast(city);
      return Right(forecasts.map((f) => f.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<WeatherEntity>>> getCachedWeatherList() async {
    try {
      final cached = localDatasource.getAllCached();
      return Right(cached.map((c) => c.toEntity(isFromCache: true)).toList());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
