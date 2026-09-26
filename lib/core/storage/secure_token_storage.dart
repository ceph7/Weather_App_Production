import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Abstraction du stockage sécurisé des tokens (permet le mock en test).
abstract class SecureTokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveCurrentUserEmail(String email);
  Future<String?> getCurrentUserEmail();
}

class SecureTokenStorageImpl implements SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorageImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: accessToken,
    );
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.currentUserEmailKey);
  }

  @override
  Future<void> saveCurrentUserEmail(String email) =>
      _storage.write(key: AppConstants.currentUserEmailKey, value: email);

  @override
  Future<String?> getCurrentUserEmail() =>
      _storage.read(key: AppConstants.currentUserEmailKey);
}
