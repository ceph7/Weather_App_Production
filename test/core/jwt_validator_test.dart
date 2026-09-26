import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  group('JwtValidator.isExpired', () {
    test('retourne false pour un token valide et non expiré', () {
      final token = JWT({'sub': '1'}).sign(
        SecretKey(AppConstants.jwtSecret),
        expiresIn: const Duration(minutes: 5),
      );

      expect(JwtValidator.isExpired(token), false);
    });

    test('retourne true pour un token expiré', () {
      final token = JWT({'sub': '1'}).sign(
        SecretKey(AppConstants.jwtSecret),
        expiresIn: const Duration(seconds: -1),
      );

      expect(JwtValidator.isExpired(token), true);
    });

    test('retourne true pour une chaîne qui n\'est pas un JWT valide', () {
      expect(JwtValidator.isExpired('pas-un-jwt'), true);
    });

    test('retourne true pour un token signé avec une autre clé', () {
      final token = JWT({'sub': '1'}).sign(
        SecretKey('une-autre-clé-totalement-différente'),
        expiresIn: const Duration(minutes: 5),
      );

      expect(JwtValidator.isExpired(token), true);
    });
  });
}
