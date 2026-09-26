import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Langue actuellement sélectionnée par l'utilisateur.
///
/// `null` = suivre la langue du système (si FR ou EN supportée, sinon FR).
/// Exposé comme provider pour rester testable et pour permettre un futur
/// sélecteur de langue dans les réglages sans toucher au reste de l'app.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLocale(Locale? locale) => state = locale;
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
