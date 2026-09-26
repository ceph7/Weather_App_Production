import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/core/storage/secure_token_storage.dart';
import 'package:weather_app/features/auth/data/datasources/mock_auth_datasource.dart';
import 'package:weather_app/features/auth/data/models/user_model.dart';
import 'package:weather_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthDatasourceImpl extends Mock implements AuthDatasource {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthDatasourceImpl mockDatasource;
  late MockSecureTokenStorage mockTokenStorage;

  setUp(() {
    mockDatasource = MockAuthDatasourceImpl();
    mockTokenStorage = MockSecureTokenStorage();
    repository = AuthRepositoryImpl(
      datasource: mockDatasource,
      tokenStorage: mockTokenStorage,
    );
  });

  final testUser = UserModel(
    id: '1',
    email: 'jean@test.com',
    name: 'Jean',
    passwordHash: 'hash',
    passwordSalt: 'salt',
  );

  group('login', () {
    test(
      'retourne une AuthSession et sauvegarde les tokens quand les '
      'identifiants sont corrects',
      () async {
        // arrange
        when(
          () => mockDatasource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => (
            user: testUser,
            accessToken: 'access123',
            refreshToken: 'refresh123',
          ),
        );
        when(
          () => mockTokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockTokenStorage.saveCurrentUserEmail(any()))
            .thenAnswer((_) async {});

        // act
        final result = await repository.login(
          email: 'jean@test.com',
          password: 'motdepasse',
        );

        // assert
        expect(result.isRight(), true);
        result.match(
          (_) => fail('Ne devrait pas échouer'),
          (session) {
            expect(session.user.email, 'jean@test.com');
            expect(session.accessToken, 'access123');
          },
        );
        verify(
          () => mockTokenStorage.saveTokens(
            accessToken: 'access123',
            refreshToken: 'refresh123',
          ),
        ).called(1);
      },
    );

    test(
      'retourne InvalidCredentialsFailure quand le datasource lève '
      'InvalidCredentialsException',
      () async {
        // arrange
        when(
          () => mockDatasource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const InvalidCredentialsException('Mot de passe incorrect'));

        // act
        final result = await repository.login(
          email: 'jean@test.com',
          password: 'mauvais',
        );

        // assert
        expect(result.isLeft(), true);
        result.match(
          (failure) {
            expect(failure, isA<InvalidCredentialsFailure>());
            expect(failure.message, 'Mot de passe incorrect');
          },
          (_) => fail('Ne devrait pas réussir'),
        );
        verifyNever(
          () => mockTokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        );
      },
    );
  });

  group('register', () {
    test(
      'retourne EmailAlreadyUsedFailure quand l\'email existe déjà',
      () async {
        // arrange
        when(
          () => mockDatasource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const EmailAlreadyUsedException());

        // act
        final result = await repository.register(
          name: 'Jean',
          email: 'jean@test.com',
          password: 'motdepasse',
        );

        // assert
        expect(result.isLeft(), true);
        result.match(
          (failure) => expect(failure, isA<EmailAlreadyUsedFailure>()),
          (_) => fail('Ne devrait pas réussir'),
        );
      },
    );
  });

  group('logout', () {
    test('efface les tokens et retourne Right(null)', () async {
      // arrange
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      // act
      final result = await repository.logout();

      // assert
      expect(result.isRight(), true);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });
  });

  group('getCurrentUser', () {
    test(
      'retourne AuthFailure quand aucun token n\'est stocké',
      () async {
        // arrange
        when(() => mockTokenStorage.getAccessToken())
            .thenAnswer((_) async => null);
        when(() => mockTokenStorage.getCurrentUserEmail())
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result.isLeft(), true);
        result.match(
          (failure) => expect(failure, isA<AuthFailure>()),
          (_) => fail('Ne devrait pas réussir'),
        );
      },
    );
  });
}
