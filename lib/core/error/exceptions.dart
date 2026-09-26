/// Exceptions levées dans la couche data (datasources).
/// Elles sont catchées dans les repositories et converties en [Failure].
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Erreur serveur']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion internet']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Erreur de cache local']);
}

class InvalidCredentialsException implements Exception {
  final String message;
  const InvalidCredentialsException([this.message = 'Identifiants invalides']);
}

class EmailAlreadyUsedException implements Exception {
  final String message;
  const EmailAlreadyUsedException([this.message = 'Email déjà utilisé']);
}

class TokenExpiredException implements Exception {
  final String message;
  const TokenExpiredException([this.message = 'Token expiré']);
}
