import 'package:flutter/material.dart';

import 'l10n_en.dart';
import 'l10n_fr.dart';

/// Fournit les chaînes traduites de l'application (FR + EN).
///
/// Implémentation volontairement simple (pas de génération de code via
/// `flutter gen-l10n`) : une map de chaînes par langue, chargée de façon
/// synchrone. Cela évite toute dépendance à un outil de build externe tout
/// en couvrant l'exigence d'internationalisation (FR + EN minimum).
///
/// Utilisation : `AppLocalizations.of(context).loginTitle`.
class AppLocalizations {
  final Locale locale;
  final Map<String, String> _strings;

  AppLocalizations(this.locale)
      : _strings = locale.languageCode == 'en' ? l10nEn : l10nFr;

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(
      localizations != null,
      'AppLocalizations.of() a été appelé sans MaterialApp.localizationsDelegates configuré.',
    );
    return localizations!;
  }

  static const supportedLocales = [Locale('fr'), Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _t(String key) => _strings[key] ?? l10nFr[key] ?? key;

  // --- Général ---
  String get appTitle => _t('appTitle');
  String get retry => _t('retry');
  String get cancel => _t('cancel');
  String get clear => _t('clear');
  String get unknownError => _t('unknownError');

  // --- Auth ---
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get email => _t('email');
  String get emailInvalid => _t('emailInvalid');
  String get password => _t('password');
  String get passwordTooShort => _t('passwordTooShort');
  String get login => _t('login');
  String get noAccountYet => _t('noAccountYet');
  String get createAccount => _t('createAccount');
  String get fullName => _t('fullName');
  String get nameRequired => _t('nameRequired');
  String get registerTitle => _t('registerTitle');
  String get genericLoginError => _t('genericLoginError');
  String get genericRegisterError => _t('genericRegisterError');
  String get logout => _t('logout');
  String greeting(String name) => '${_t('greetingPrefix')} $name';

  // --- Navigation ---
  String get navWeather => _t('navWeather');
  String get navSearch => _t('navSearch');
  String get navSaved => _t('navSaved');

  // --- Météo / Accueil ---
  String get weather => _t('weather');
  String get forecast5Days => _t('forecast5Days');
  String get favorite => _t('favorite');
  String get feelsLike => _t('feelsLike');
  String get humidity => _t('humidity');
  String get wind => _t('wind');
  String get cacheLabel => _t('cacheLabel');
  String get offlineBanner => _t('offlineBanner');
  String forecastTitle(String city) => '${_t('forecastTitlePrefix')} $city';
  String get noForecastAvailable => _t('noForecastAvailable');
  String get cacheLoadError => _t('cacheLoadError');

  // --- Recherche ---
  String get searchTitle => _t('searchTitle');
  String get searchHint => _t('searchHint');
  String get recentSearches => _t('recentSearches');
  String get searchEmptyState => _t('searchEmptyState');

  // --- Enregistrés ---
  String get savedTitle => _t('savedTitle');
  String get favoritesSection => _t('favoritesSection');
  String get offlineAvailableSection => _t('offlineAvailableSection');
  String get noCacheYet => _t('noCacheYet');

  // --- Accessibilité (semanticsLabel) ---
  String get semLogoutButton => _t('semLogoutButton');
  String get semFavoriteToggle => _t('semFavoriteToggle');
  String get semSearchField => _t('semSearchField');
  String get semTogglePasswordVisibility => _t('semTogglePasswordVisibility');
  String get semWeatherIcon => _t('semWeatherIcon');
  String get semClearHistory => _t('semClearHistory');
  String get semOfflineIndicator => _t('semOfflineIndicator');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
