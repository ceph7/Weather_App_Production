import 'package:hive/hive.dart';
import '../../domain/entities/weather_entity.dart';
import 'weather_api_model.dart';

part 'weather_cache_model.g.dart';

@HiveType(typeId: 1)
class WeatherCacheModel extends HiveObject {
  @HiveField(0)
  final String cityName;

  @HiveField(1)
  final String country;

  @HiveField(2)
  final double temperature;

  @HiveField(3)
  final double feelsLike;

  @HiveField(4)
  final double tempMin;

  @HiveField(5)
  final double tempMax;

  @HiveField(6)
  final int humidity;

  @HiveField(7)
  final double windSpeed;

  @HiveField(8)
  final String description;

  @HiveField(9)
  final String iconCode;

  @HiveField(10)
  final int pressure;

  @HiveField(11)
  final DateTime fetchedAt;

  WeatherCacheModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
    required this.pressure,
    required this.fetchedAt,
  });

  factory WeatherCacheModel.fromApiModel(WeatherApiModel api) =>
      WeatherCacheModel(
        cityName: api.cityName,
        country: api.country,
        temperature: api.temperature,
        feelsLike: api.feelsLike,
        tempMin: api.tempMin,
        tempMax: api.tempMax,
        humidity: api.humidity,
        windSpeed: api.windSpeed,
        description: api.description,
        iconCode: api.iconCode,
        pressure: api.pressure,
        fetchedAt: DateTime.now(),
      );

  WeatherEntity toEntity({bool isFromCache = true}) => WeatherEntity(
        cityName: cityName,
        country: country,
        temperature: temperature,
        feelsLike: feelsLike,
        tempMin: tempMin,
        tempMax: tempMax,
        humidity: humidity,
        windSpeed: windSpeed,
        description: description,
        iconCode: iconCode,
        pressure: pressure,
        fetchedAt: fetchedAt,
        isFromCache: isFromCache,
      );

  bool isStillValid(Duration validity) =>
      DateTime.now().difference(fetchedAt) < validity;
}
