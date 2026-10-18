// integration_test/screenshots_test.dart
//
// Captures d'écran de l'app, en français et en anglais, sur un simulateur
// iOS ou un émulateur Android :
//   SCREENSHOT_DIR=screenshots flutter drive -d <appareil> \
//     --driver=test_driver/screenshots.dart \
//     --target=integration_test/screenshots_test.dart
//
// Rejoue la partie à 18 joueurs de full_game_flow_test.dart et capture
// chaque écran de [screens] la première fois qu'il s'affiche. Les fichiers
// sont écrits par test_driver/screenshots.dart dans
// $SCREENSHOT_DIR/<langue>/<numéro>-<écran>.png.
// En CI : .github/workflows/screenshots.yml.
import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/app_harness.dart';
import '../test/support/game_fixtures.dart';
import '../test/support/ui_game_driver.dart';
import '../test/support/village_scenario.dart';

/// Écrans capturés, dans l'ordre des fichiers. Noms donnés par
/// UiGameDriver.onScreen (« .open » : l'écran du rôle, une fois le téléphone
/// passé).
const screens = [
  'home',
  'setupRoles',
  'setupNames',
  'roleReveal',
  'nightIntro',
  'nightCupidon.open',
  'nightVoyante',
  'nightVoyante.open',
  'nightLoups.open',
  'nightSorciere.open',
  'dayReveal',
  'mayorElection.open',
  'villageVote.open',
  'voteResult',
  'endGame',
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var surfaceConverted = false;

  for (final language in ['fr', 'en']) {
    testWidgets('captures d\'écran ($language)', (tester) async {
      final taken = <String>{};
      Future<void> capture(String screen) async {
        final index = screens.indexOf(screen);
        if (index < 0 || !taken.add(screen)) return;
        // Android : la surface Flutter doit d'abord devenir une image (une
        // fois pour toute l'exécution).
        if (Platform.isAndroid && !surfaceConverted) {
          await binding.convertFlutterSurfaceToImage();
          surfaceConverted = true;
        }
        await tester.pump();
        final number = '${index + 1}'.padLeft(2, '0');
        await binding.takeScreenshot('$language/$number-$screen');
      }

      final app = await AppHarness.start(tester,
          language: language, simulatePhoneScreen: false);
      // La scène de nuit de l'accueil apparaît en fondu.
      await tester.pump(const Duration(seconds: 2));
      await capture('home');

      final driver = UiGameDriver(
        tester,
        app.game,
        VillageScenarioDecisions(),
        onScreen: capture,
      );
      await driver.createGame(
        names: VillageScenario.names,
        roleCounts: {for (final role in VillageScenario.roles) role: 1},
        rig: (s) => rigRoles(s, VillageScenario.roles),
      );
      await driver.playToEnd();
      await capture('endGame');

      // Un écran renommé ou disparu doit se voir.
      expect(screens.where((s) => !taken.contains(s)), isEmpty,
          reason: 'Écrans jamais affichés');
    });
  }
}
