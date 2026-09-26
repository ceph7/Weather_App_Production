import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Contrat du repository d'authentification.
/// La couche presentation ne dépend que de cette abstraction, jamais
/// de l'implémentation concrète (inversion de dépendance).
abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  /// Tente de restaurer une session existante depuis le storage sécurisé.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Rafraîchit l'access token via le refresh token stocké.
  Future<Either<Failure, String>> refreshAccessToken();
}
