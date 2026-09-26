import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
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
  final DateTime fetchedAt;
  final bool isFromCache;

  const WeatherEntity({
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
    this.isFromCache = false,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  WeatherEntity copyWith({bool? isFromCache}) => WeatherEntity(
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
        isFromCache: isFromCache ?? this.isFromCache,
      );

  @override
  List<Object?> get props => [
        cityName,
        country,
        temperature,
        feelsLike,
        tempMin,
        tempMax,
        humidity,
        windSpeed,
        description,
        iconCode,
        pressure,
        fetchedAt,
        isFromCache,
      ];
}

/// Une prévision ponctuelle dans le futur (utilisée pour l'écran détail/prévisions).
class ForecastEntity extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String iconCode;

  const ForecastEntity({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  @override
  List<Object?> get props => [dateTime, temperature, description, iconCode];
}
