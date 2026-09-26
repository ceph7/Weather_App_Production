import '../../domain/entities/weather_entity.dart';

/// Parse la réponse JSON de `GET /weather` (OpenWeatherMap Current Weather API).
class WeatherApiModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String iconCode;
  final int pressure;

  WeatherApiModel({
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
  });

  factory WeatherApiModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList.first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};

    return WeatherApiModel(
      cityName: json['name'] as String? ?? 'Inconnu',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      description: weather['description'] as String? ?? '',
      iconCode: weather['icon'] as String? ?? '01d',
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
    );
  }

  WeatherEntity toEntity({bool isFromCache = false}) => WeatherEntity(
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
        fetchedAt: DateTime.now(),
        isFromCache: isFromCache,
      );
}

/// Parse la réponse JSON de `GET /forecast` (5 day / 3 hour forecast).
class ForecastApiModel {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String iconCode;

  ForecastApiModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory ForecastApiModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList.first as Map<String, dynamic>;

    return ForecastApiModel(
      dateTime: DateTime.parse(json['dt_txt'] as String),
      temperature: (main['temp'] as num).toDouble(),
      description: weather['description'] as String? ?? '',
      iconCode: weather['icon'] as String? ?? '01d',
    );
  }

  ForecastEntity toEntity() => ForecastEntity(
        dateTime: dateTime,
        temperature: temperature,
        description: description,
        iconCode: iconCode,
      );
}
