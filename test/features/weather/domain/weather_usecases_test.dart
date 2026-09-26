import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/features/weather/domain/entities/weather_entity.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather/domain/usecases/weather_usecases.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockRepository;
  late GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  late GetForecastUseCase getForecastUseCase;
  late GetCachedWeatherListUseCase getCachedWeatherListUseCase;

  setUp(() {
    mockRepository = MockWeatherRepository();
    getCurrentWeatherUseCase = GetCurrentWeatherUseCase(mockRepository);
    getForecastUseCase = GetForecastUseCase(mockRepository);
    getCachedWeatherListUseCase = GetCachedWeatherListUseCase(mockRepository);
  });

  final testWeather = WeatherEntity(
    cityName: 'Lomé',
    country: 'TG',
    temperature: 28.0,
    feelsLike: 30.0,
    tempMin: 26.0,
    tempMax: 29.0,
    humidity: 70,
    windSpeed: 3.0,
    description: 'ciel dégagé',
    iconCode: '01d',
    pressure: 1012,
    fetchedAt: DateTime(2026, 1, 1),
  );

  group('GetCurrentWeatherUseCase', () {
    test('rejette une ville vide sans appeler le repository', () async {
      final result = await getCurrentWeatherUseCase('   ');

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Ne devrait pas réussir'),
      );
      verifyNever(() => mockRepository.getCurrentWeather(any()));
    });

    test('délègue au repository en retirant les espaces superflus', () async {
      when(() => mockRepository.getCurrentWeather(any()))
          .thenAnswer((_) async => Right(testWeather));

      final result = await getCurrentWeatherUseCase('  Lomé  ');

      expect(result.isRight(), true);
      verify(() => mockRepository.getCurrentWeather('Lomé')).called(1);
    });
  });

  group('GetForecastUseCase', () {
    test('délègue directement au repository', () async {
      when(() => mockRepository.getForecast(any()))
          .thenAnswer((_) async => const Right([]));

      final result = await getForecastUseCase('Paris');

      expect(result.isRight(), true);
      verify(() => mockRepository.getForecast('Paris')).called(1);
    });
  });

  group('GetCachedWeatherListUseCase', () {
    test('retourne la liste fournie par le repository', () async {
      when(() => mockRepository.getCachedWeatherList())
          .thenAnswer((_) async => Right([testWeather]));

      final result = await getCachedWeatherListUseCase();

      expect(result.isRight(), true);
      result.match(
        (_) => fail('Ne devrait pas échouer'),
        (list) => expect(list.single.cityName, 'Lomé'),
      );
    });
  });
}
