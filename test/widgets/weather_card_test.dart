import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/features/weather/domain/entities/weather_entity.dart';
import 'package:weather_app/features/weather/presentation/widgets/weather_card.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  final weather = WeatherEntity(
    cityName: 'Lomé',
    country: 'TG',
    temperature: 28.4,
    feelsLike: 31.2,
    tempMin: 26.0,
    tempMax: 30.0,
    humidity: 75,
    windSpeed: 3.5,
    description: 'ciel dégagé',
    iconCode: '01d',
    pressure: 1012,
    fetchedAt: DateTime(2026, 1, 1),
  );

  testWidgets('affiche la ville, le pays et la température arrondie',
      (tester) async {
    await tester.pumpWidget(wrapForTest(WeatherCard(weather: weather)));

    expect(find.text('Lomé, TG'), findsOneWidget);
    expect(find.text('28°C'), findsOneWidget);
  });

  testWidgets('met en majuscule la première lettre de la description',
      (tester) async {
    await tester.pumpWidget(wrapForTest(WeatherCard(weather: weather)));

    expect(find.text('Ciel dégagé'), findsOneWidget);
  });

  testWidgets('affiche un badge "Cache" quand la donnée vient du cache',
      (tester) async {
    await tester.pumpWidget(
      wrapForTest(WeatherCard(weather: weather.copyWith(isFromCache: true))),
    );

    expect(find.text('Cache'), findsOneWidget);
  });

  testWidgets('n\'affiche pas de badge "Cache" quand la donnée est fraîche',
      (tester) async {
    await tester.pumpWidget(
      wrapForTest(WeatherCard(weather: weather.copyWith(isFromCache: false))),
    );

    expect(find.text('Cache'), findsNothing);
  });

  testWidgets('affiche les trois statistiques secondaires', (tester) async {
    await tester.pumpWidget(wrapForTest(WeatherCard(weather: weather)));

    expect(find.text('31°C'), findsOneWidget); // ressenti
    expect(find.text('75%'), findsOneWidget); // humidité
    expect(find.text('4 m/s'), findsOneWidget); // vent (arrondi de 3.5)
  });
}
