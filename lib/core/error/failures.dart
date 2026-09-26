import 'package:equatable/equatable.dart';

/// Représente un échec métier (couche domain/presentation).
/// On distingue les Failures (retournées, gérées proprement) des
/// Exceptions (levées côté data, catchées puis converties en Failure).
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur. Réessaie plus tard.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Pas de connexion internet. Affichage des données en cache.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Aucune donnée disponible en cache.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Échec de l\'authentification.']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    super.message = 'Email ou mot de passe incorrect.',
  ]);
}

class EmailAlreadyUsedFailure extends Failure {
  const EmailAlreadyUsedFailure([
    super.message = 'Un compte existe déjà avec cet email.',
  ]);
}

class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure([
    super.message = 'Session expirée, merci de te reconnecter.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
