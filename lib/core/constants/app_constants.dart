/// Constantes globales de l'application.
///
/// IMPORTANT : ne jamais committer une vraie clé API en dur dans un repo public.
/// Ici la clé est lue depuis --dart-define (voir README pour la configuration).
class AppConstants {
  AppConstants._();

  // --- OpenWeatherMap ---
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String geoBaseUrl =
      'https://api.openweathermap.org/geo/1.0';

  /// Récupérée via `--dart-define=OWM_API_KEY=xxx` (voir README).
  static const String owmApiKey = String.fromEnvironment(
    'OWM_API_KEY',
    defaultValue: '',
  );

  // --- Auth mock (JWT signé localement, cf README pour les limites) ---
  static const String jwtSecret = String.fromEnvironment(
    'JWT_SECRET',
    defaultValue: 'dev-only-insecure-secret-change-me',
  );
  static const Duration accessTokenTtl = Duration(minutes: 15);
  static const Duration refreshTokenTtl = Duration(days: 7);

  // --- Hive box names ---
  static const String weatherCacheBox = 'weather_cache_box';
  static const String favoritesBox = 'favorites_box';
  static const String searchHistoryBox = 'search_history_box';
  static const String usersBox = 'users_box'; // comptes "enregistrés" localement

  // --- Secure storage keys ---
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String currentUserEmailKey = 'current_user_email';

  // --- Cache policy ---
  static const Duration weatherCacheValidity = Duration(minutes: 30);
}
