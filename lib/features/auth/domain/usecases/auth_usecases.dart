import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Either<Failure, AuthSession>> call({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty || password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Email et mot de passe requis.')),
      );
    }
    return repository.login(email: email.trim(), password: password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<Either<Failure, AuthSession>> call({
    required String name,
    required String email,
    required String password,
  }) {
    if (name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Le nom est requis.')));
    }
    if (!email.contains('@')) {
      return Future.value(const Left(ValidationFailure('Email invalide.')));
    }
    if (password.length < 6) {
      return Future.value(
        const Left(
          ValidationFailure('Le mot de passe doit faire 6 caractères min.'),
        ),
      );
    }
    return repository.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
  }
}

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.logout();
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.getCurrentUser();
}
