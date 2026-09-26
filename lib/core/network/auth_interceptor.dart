import 'package:dio/dio.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../storage/secure_token_storage.dart';

/// Intercepteur Dio qui :
/// 1. Injecte le JWT d'accès dans le header Authorization de chaque requête
/// 2. Si le token local est expiré (vérifié sans appel réseau via [JwtValidator]),
///    tente un refresh avant même d'envoyer la requête
/// 3. Si malgré tout le serveur répond 401, tente un refresh puis rejoue
///    la requête une seule fois (évite les boucles infinies)
///
/// NOTE : ici le "serveur" OpenWeatherMap n'exige pas de JWT (il utilise sa
/// propre clé API), mais cet intercepteur est branché de façon générique
/// pour que le flux JWT (obligatoire dans l'énoncé) soit réellement exercé
/// et testable — il s'appliquerait tel quel sur un futur backend perso
/// (ex: Laravel) exposant des routes protégées par JWT.
class AuthInterceptor extends Interceptor {
  final SecureTokenStorage tokenStorage;
  final Future<String> Function() onRefreshToken;
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.tokenStorage,
    required this.onRefreshToken,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && JwtValidator.isExpired(accessToken)) {
      accessToken = await _refreshSafely();
    }

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (isUnauthorized && !alreadyRetried) {
      final newToken = await _refreshSafely();
      if (newToken != null) {
        final retryOptions = err.requestOptions
          ..headers['Authorization'] = 'Bearer $newToken'
          ..extra['retried'] = true;
        try {
          final dio = Dio();
          final response = await dio.fetch(retryOptions);
          return handler.resolve(response);
        } catch (_) {
          // La requête rejouée a échoué à nouveau : on laisse remonter l'erreur.
        }
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshSafely() async {
    if (_isRefreshing) return null; // évite les refresh concurrents
    _isRefreshing = true;
    try {
      final newToken = await onRefreshToken();
      return newToken;
    } catch (_) {
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}
