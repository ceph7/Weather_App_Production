import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/providers/core_providers.dart';
import 'package:weather_app/features/weather/presentation/widgets/offline_banner.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  testWidgets('n\'affiche rien quand la connexion est active', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const OfflineBanner(),
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => Stream.value(true)),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('Hors ligne — affichage des données en cache'), findsNothing);
  });

  testWidgets('affiche le message hors-ligne quand la connexion est coupée',
      (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const OfflineBanner(),
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pump();

    expect(
      find.text('Hors ligne — affichage des données en cache'),
      findsOneWidget,
    );
  });
}
