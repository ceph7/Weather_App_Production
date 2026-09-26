import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/features/auth/presentation/screens/login_screen.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  testWidgets('affiche les champs email/mot de passe et le bouton de connexion',
      (tester) async {
    await tester.pumpWidget(wrapForTest(const LoginScreen()));

    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
  });

  testWidgets('affiche une erreur de validation si l\'email est invalide',
      (tester) async {
    await tester.pumpWidget(wrapForTest(const LoginScreen()));

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'pas-un-email',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('Email invalide'), findsOneWidget);
  });

  testWidgets(
      'affiche une erreur de validation si le mot de passe est trop court',
      (tester) async {
    await tester.pumpWidget(wrapForTest(const LoginScreen()));

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'jean@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      '123',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('6 caractères minimum'), findsOneWidget);
  });

  testWidgets('masque le mot de passe par défaut et le révèle au tap',
      (tester) async {
    await tester.pumpWidget(wrapForTest(const LoginScreen()));

    final passwordField = tester.widget<TextFormField>(
      find.byKey(const Key('login_password_field')),
    );
    expect(passwordField.obscureText, true);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    final updatedField = tester.widget<TextFormField>(
      find.byKey(const Key('login_password_field')),
    );
    expect(updatedField.obscureText, false);
  });

  testWidgets('navigue vers l\'écran d\'inscription au tap sur le lien',
      (tester) async {
    await tester.pumpWidget(wrapForTest(const LoginScreen()));

    await tester.tap(find.byKey(const Key('go_to_register_button')));
    await tester.pumpAndSettle();

    expect(find.text('Créer un compte'), findsWidgets);
  });
}
