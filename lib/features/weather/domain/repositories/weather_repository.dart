import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  /// Récupère la météo actuelle pour une ville. Si hors ligne ou si l'appel
  /// réseau échoue, retourne la dernière version en cache si elle existe
  /// (avec [WeatherEntity.isFromCache] = true).
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(String city);

  /// Récupère les prévisions (5 jours / 3h) pour une ville.
  Future<Either<Failure, List<ForecastEntity>>> getForecast(String city);

  /// Retourne toutes les météos actuellement en cache (mode hors-ligne, écran liste).
  Future<Either<Failure, List<WeatherEntity>>> getCachedWeatherList();
}
