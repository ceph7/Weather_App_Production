import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeatherUseCase {
  final WeatherRepository repository;
  const GetCurrentWeatherUseCase(this.repository);

  Future<Either<Failure, WeatherEntity>> call(String city) {
    if (city.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Merci de saisir un nom de ville.')),
      );
    }
    return repository.getCurrentWeather(city.trim());
  }
}

class GetForecastUseCase {
  final WeatherRepository repository;
  const GetForecastUseCase(this.repository);

  Future<Either<Failure, List<ForecastEntity>>> call(String city) {
    return repository.getForecast(city.trim());
  }
}

class GetCachedWeatherListUseCase {
  final WeatherRepository repository;
  const GetCachedWeatherListUseCase(this.repository);

  Future<Either<Failure, List<WeatherEntity>>> call() {
    return repository.getCachedWeatherList();
  }
}
