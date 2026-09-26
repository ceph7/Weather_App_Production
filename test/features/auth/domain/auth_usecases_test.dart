import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/features/auth/domain/entities/user_entity.dart';
import 'package:weather_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:weather_app/features/auth/domain/usecases/auth_usecases.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    registerUseCase = RegisterUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('retourne ValidationFailure si email vide, sans appeler le repo', () async {
      final result = await loginUseCase(email: '', password: 'password123');

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Ne devrait pas réussir'),
      );
      verifyNever(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('appelle le repository quand les champs sont valides', () async {
      const session = AuthSession(
        user: UserEntity(id: '1', email: 'a@a.com', name: 'A'),
        accessToken: 'token',
        refreshToken: 'refresh',
      );
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(session));

      final result = await loginUseCase(email: 'a@a.com', password: 'password123');

      expect(result.isRight(), true);
      verify(() => mockRepository.login(email: 'a@a.com', password: 'password123'))
          .called(1);
    });
  });

  group('RegisterUseCase', () {
    test('rejette un mot de passe trop court sans appeler le repo', () async {
      final result = await registerUseCase(
        name: 'Jean',
        email: 'jean@test.com',
        password: '123',
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Ne devrait pas réussir'),
      );
      verifyNever(
        () => mockRepository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('rejette un email invalide sans appeler le repo', () async {
      final result = await registerUseCase(
        name: 'Jean',
        email: 'pas-un-email',
        password: 'password123',
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Ne devrait pas réussir'),
      );
    });
  });
}
