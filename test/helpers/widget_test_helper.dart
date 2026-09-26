import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/core/l10n/app_localizations.dart';

/// Enveloppe un widget avec tout le nécessaire pour un `pumpWidget` réaliste :
/// ProviderScope (avec d'éventuels overrides), MaterialApp + délégués de
/// localisation (indispensables dès qu'un widget appelle
/// `AppLocalizations.of(context)`).
Widget wrapForTest(
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('fr'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}
