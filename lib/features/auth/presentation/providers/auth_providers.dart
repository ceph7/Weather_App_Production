import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/mock_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return MockAuthDatasource(ref.watch(usersBoxProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: ref.watch(authDatasourceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

/// Dio final utilisé par tout le reste de l'app pour appeler OpenWeatherMap :
/// le Dio de base (core_providers) + l'intercepteur JWT qui sait comment
/// rafraîchir via le AuthRepository. C'est ICI que la dépendance circulaire
/// est résolue proprement (auth → core, jamais l'inverse).
final weatherDioProvider = Provider<Dio>((ref) {
  final dio = ref.watch(baseDioProvider);
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: ref.watch(secureTokenStorageProvider),
      onRefreshToken: () async {
        final result = await ref.read(authRepositoryProvider).refreshAccessToken();
        return result.match(
          (failure) => throw Exception(failure.message),
          (token) => token,
        );
      },
    ),
  );
  return dio;
});

/// --- État de session (AsyncNotifier) ---
///
/// Représente l'utilisateur actuellement connecté, ou null. Piloté par
/// login/register/logout et restauré au démarrage (voir build()).
class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final result = await ref.read(getCurrentUserUseCaseProvider).call();
    return result.match((_) => null, (user) => user);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(loginUseCaseProvider)
        .call(email: email, password: password);
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (session) => AsyncData(session.user),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(registerUseCaseProvider)
        .call(name: name, email: email, password: password);
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (session) => AsyncData(session.user),
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);

/// Raccourci pratique : true si un utilisateur est connecté.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider);
  return auth.maybeWhen(data: (user) => user != null, orElse: () => false);
});
