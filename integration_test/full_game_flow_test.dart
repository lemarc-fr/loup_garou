// integration_test/full_game_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:thiercelieux/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('crée une partie à 5 joueurs et arrive à la nuit 1',
      (tester) async {
    await tester.pumpWidget(const ThiercelieuxApp());
    await tester.pumpAndSettle();

    // Accueil → Nouvelle partie
    await tester.tap(find.text('Nouvelle partie'));
    await tester.pumpAndSettle();

    // Choix du nombre de joueurs (par défaut 8, on le laisse) → Continuer
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // Répartition des rôles : on garde la config par défaut → Continuer
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // Saisie des prénoms
    final fields = find.byType(TextField);
    for (var i = 0; i < tester.widgetList(fields).length; i++) {
      await tester.enterText(fields.at(i), 'Joueur${i + 1}');
    }
    await tester.tap(find.text('Distribuer les rôles'));
    await tester.pumpAndSettle();

    // Révélation des rôles : passer chaque joueur (PassDeviceGate → révéler → masquer)
    for (var i = 0; i < 8; i++) {
      await tester.tap(find.text("C'est moi, j'ai le téléphone"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Révéler mon rôle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("J'ai vu, masquer mon rôle"));
      await tester.pumpAndSettle();
    }

    // On doit maintenant être sur l'intro de la nuit 1
    expect(find.text('La nuit tombe sur Thiercelieux'), findsOneWidget);
  });
}
