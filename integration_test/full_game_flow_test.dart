// integration_test/full_game_flow_test.dart
//
// Sur un téléphone ou un émulateur :
//   flutter test integration_test -d <appareil>
//
// Rejoue, sur un vrai appareil, la partie complète à 18 joueurs de
// test/widgets/full_game_ui_test.dart : création de la partie depuis
// l'accueil, chaque rôle, chaque vote, jusqu'au retour à l'accueil.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/app_harness.dart';
import '../test/support/game_fixtures.dart';
import '../test/support/ui_game_driver.dart';
import '../test/support/village_scenario.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('partie complète à 18 joueurs sur un appareil', (tester) async {
    final app = await AppHarness.start(tester, simulatePhoneScreen: false);
    final driver = UiGameDriver(
      tester,
      app.game,
      VillageScenarioDecisions(),
      beforeStep: VillageScenario.checkpoint,
    );

    await driver.createGame(
      names: VillageScenario.names,
      roleCounts: {for (final role in VillageScenario.roles) role: 1},
      rig: (s) => rigRoles(s, VillageScenario.roles),
    );
    await driver.playToEnd();

    VillageScenario.checkEnd(app.game.state!);
    expect(find.text(driver.loc.endGameWinnerVillage), findsOneWidget);
    await tapOnHome(tester, driver.loc.endGameReturnHomeButton);
    expect(app.game.state, isNull);
    // Le village gagne en équipe : ses 14 joueurs de départ, moins Emma
    // (infectée) et Jules (Enfant Sauvage devenu loup).
    expect(app.stats.stats.where((st) => st.wins == 1), hasLength(12));
  });
}
