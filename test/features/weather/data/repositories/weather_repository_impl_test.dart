import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/core/network/network_info.dart';
import 'package:weather_app/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:weather_app/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/features/weather/data/models/weather_api_model.dart';
import 'package:weather_app/features/weather/data/models/weather_cache_model.dart';
import 'package:weather_app/features/weather/data/repositories/weather_repository_impl.dart';

class MockWeatherRemoteDatasource extends Mock implements WeatherRemoteDatasource {}

class MockWeatherLocalDatasource extends Mock implements WeatherLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDatasource mockRemote;
  late MockWeatherLocalDatasource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockWeatherRemoteDatasource();
    mockLocal = MockWeatherLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WeatherRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  final testApiModel = WeatherApiModel(
    cityName: 'Lomé',
    country: 'TG',
    temperature: 28.5,
    feelsLike: 31.0,
    tempMin: 26.0,
    tempMax: 30.0,
    humidity: 75,
    windSpeed: 3.5,
    description: 'ciel dégagé',
    iconCode: '01d',
    pressure: 1012,
  );

  final testCacheModel = WeatherCacheModel(
    cityName: 'Lomé',
    country: 'TG',
    temperature: 27.0,
    feelsLike: 29.0,
    tempMin: 25.0,
    tempMax: 29.0,
    humidity: 78,
    windSpeed: 3.0,
    description: 'nuageux',
    iconCode: '02d',
    pressure: 1010,
    fetchedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  group('getCurrentWeather - en ligne', () {
    test(
      'retourne les données fraîches de l\'API et les met en cache',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemote.getCurrentWeather(any()))
            .thenAnswer((_) async => testApiModel);
        when(() => mockLocal.cacheWeather(any(), any()))
            .thenAnswer((_) async {});

        // act
        final result = await repository.getCurrentWeather('Lomé');

        // assert
        expect(result.isRight(), true);
        result.match(
          (_) => fail('Ne devrait pas échouer'),
          (weather) {
            expect(weather.cityName, 'Lomé');
            expect(weather.temperature, 28.5);
            expect(weather.isFromCache, false);
          },
        );
        verify(() => mockLocal.cacheWeather('Lomé', testApiModel)).called(1);
      },
    );

    test(
      'si l\'API échoue (ex: ville introuvable) et qu\'un cache existe, '
      'retourne le cache avec isFromCache = true',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemote.getCurrentWeather(any()))
            .thenThrow(const ServerException('Ville introuvable.'));
        when(() => mockLocal.getCachedWeather(any()))
            .thenReturn(testCacheModel);

        // act
        final result = await repository.getCurrentWeather('Lomé');

        // assert
        expect(result.isRight(), true);
        result.match(
          (_) => fail('Ne devrait pas échouer'),
          (weather) {
            expect(weather.isFromCache, true);
            expect(weather.temperature, 27.0);
          },
        );
      },
    );

    test(
      'si l\'API échoue et qu\'aucun cache n\'existe, retourne un Failure',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemote.getCurrentWeather(any()))
            .thenThrow(const ServerException('Erreur serveur'));
        when(() => mockLocal.getCachedWeather(any())).thenReturn(null);

        // act
        final result = await repository.getCurrentWeather('VilleInconnue');

        // assert
        expect(result.isLeft(), true);
        result.match(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Ne devrait pas réussir'),
        );
      },
    );
  });

  group('getCurrentWeather - hors ligne', () {
    test(
      'sert directement le cache sans appeler l\'API quand hors-ligne',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocal.getCachedWeather(any()))
            .thenReturn(testCacheModel);

        // act
        final result = await repository.getCurrentWeather('Lomé');

        // assert
        expect(result.isRight(), true);
        result.match(
          (_) => fail('Ne devrait pas échouer'),
          (weather) => expect(weather.isFromCache, true),
        );
        verifyNever(() => mockRemote.getCurrentWeather(any()));
      },
    );

    test(
      'retourne NetworkFailure quand hors-ligne et sans cache disponible',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocal.getCachedWeather(any())).thenReturn(null);

        // act
        final result = await repository.getCurrentWeather('VilleJamaisVue');

        // assert
        expect(result.isLeft(), true);
        result.match(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Ne devrait pas réussir'),
        );
      },
    );
  });

  group('getCachedWeatherList', () {
    test('retourne la liste des météos en cache triées', () async {
      // arrange
      when(() => mockLocal.getAllCached()).thenReturn([testCacheModel]);

      // act
      final result = await repository.getCachedWeatherList();

      // assert
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Ne devrait pas échouer'),
        (list) => expect(list.length, 1),
      );
    });
  });
}
