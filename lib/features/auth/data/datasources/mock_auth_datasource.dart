import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Simule un backend d'authentification JWT.
///
/// Pourquoi un mock plutôt qu'un vrai backend ?
/// Le sujet demande une API "publique ou que tu crées" pour les DONNÉES
/// (ici OpenWeatherMap), l'authentification elle-même n'a pas besoin d'un
/// serveur dédié pour valider les exigences (JWT généré, stocké, injecté,
/// rafraîchi — tout le flux est bien réel, seul l'émetteur est local).
///
/// Pour brancher un vrai backend plus tard (ex: Laravel Sanctum) :
/// remplacer cette classe par un [RemoteAuthDatasource] qui fait des
/// appels Dio vers /api/login, /api/register, /api/refresh — l'interface
/// (AuthRepository) et tout le reste de l'app ne bougent pas.
abstract class AuthDatasource {
  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  });

  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String name,
    required String email,
    required String password,
  });

  Future<String> refreshAccessToken(String refreshToken);

  UserModel? getUserByEmail(String email);
}

class MockAuthDatasource implements AuthDatasource {
  final Box<UserModel> usersBox;
  final _random = Random.secure();

  MockAuthDatasource(this.usersBox);

  @override
  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    final user = getUserByEmail(email);
    if (user == null) {
      throw const InvalidCredentialsException();
    }
    final hashed = _hashPassword(password, user.passwordSalt);
    if (hashed != user.passwordHash) {
      throw const InvalidCredentialsException();
    }
    final tokens = _generateTokenPair(user);
    return (user: user, accessToken: tokens.access, refreshToken: tokens.refresh);
  }

  @override
  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (getUserByEmail(email) != null) {
      throw const EmailAlreadyUsedException();
    }
    final salt = _generateSalt();
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email.toLowerCase(),
      name: name,
      passwordHash: _hashPassword(password, salt),
      passwordSalt: salt,
    );
    await usersBox.put(user.email, user);
    final tokens = _generateTokenPair(user);
    return (user: user, accessToken: tokens.access, refreshToken: tokens.refresh);
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    try {
      final jwt = JWT.verify(refreshToken, SecretKey(AppConstants.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      if (payload['type'] != 'refresh') {
        throw const TokenExpiredException('Token invalide.');
      }
      final email = payload['email'] as String;
      final user = getUserByEmail(email);
      if (user == null) throw const TokenExpiredException();
      return _generateAccessToken(user);
    } on JWTExpiredException {
      throw const TokenExpiredException('Session expirée, reconnecte-toi.');
    } on JWTException {
      throw const TokenExpiredException('Token de rafraîchissement invalide.');
    }
  }

  @override
  UserModel? getUserByEmail(String email) =>
      usersBox.get(email.toLowerCase());

  // --- Helpers internes ---

  ({String access, String refresh}) _generateTokenPair(UserModel user) {
    return (
      access: _generateAccessToken(user),
      refresh: _generateRefreshToken(user),
    );
  }

  String _generateAccessToken(UserModel user) {
    final jwt = JWT(
      {
        'sub': user.id,
        'email': user.email,
        'name': user.name,
        'type': 'access',
      },
    );
    return jwt.sign(
      SecretKey(AppConstants.jwtSecret),
      expiresIn: AppConstants.accessTokenTtl,
    );
  }

  String _generateRefreshToken(UserModel user) {
    final jwt = JWT({'sub': user.id, 'email': user.email, 'type': 'refresh'});
    return jwt.sign(
      SecretKey(AppConstants.jwtSecret),
      expiresIn: AppConstants.refreshTokenTtl,
    );
  }

  String _generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$password:$salt');
    return sha256.convert(bytes).toString();
  }
}
