import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;
  final SecureTokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.datasource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await datasource.login(email: email, password: password);
      await tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await tokenStorage.saveCurrentUserEmail(result.user.email);
      return Right(
        AuthSession(
          user: result.user.toEntity(),
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
        ),
      );
    } on InvalidCredentialsException catch (e) {
      return Left(InvalidCredentialsFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await datasource.register(
        name: name,
        email: email,
        password: password,
      );
      await tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await tokenStorage.saveCurrentUserEmail(result.user.email);
      return Right(
        AuthSession(
          user: result.user.toEntity(),
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
        ),
      );
    } on EmailAlreadyUsedException catch (e) {
      return Left(EmailAlreadyUsedFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await tokenStorage.clearTokens();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('Impossible de te déconnecter.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();
      final email = await tokenStorage.getCurrentUserEmail();
      if (accessToken == null || email == null) {
        return const Left(AuthFailure('Aucune session active.'));
      }
      final user = datasource.getUserByEmail(email);
      if (user == null) {
        return const Left(AuthFailure('Utilisateur introuvable.'));
      }
      return Right(user.toEntity());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, String>> refreshAccessToken() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return const Left(TokenExpiredFailure('Aucun token à rafraîchir.'));
      }
      final newAccessToken = await datasource.refreshAccessToken(refreshToken);
      final currentRefresh = await tokenStorage.getRefreshToken();
      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: currentRefresh!,
      );
      return Right(newAccessToken);
    } on TokenExpiredException catch (e) {
      await tokenStorage.clearTokens();
      return Left(TokenExpiredFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

/// Utilitaire pour vérifier localement si un access token est encore valide
/// sans appel réseau (utilisé par l'intercepteur Dio).
class JwtValidator {
  static bool isExpired(String token) {
    try {
      JWT.verify(token, SecretKey(AppConstants.jwtSecret));
      return false;
    } on JWTExpiredException {
      return true;
    } catch (_) {
      return true;
    }
  }
}
