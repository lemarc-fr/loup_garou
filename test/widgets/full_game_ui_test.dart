import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/role.dart';

import '../support/app_harness.dart';
import '../support/game_fixtures.dart';
import '../support/ui_game_driver.dart';
import '../support/village_scenario.dart';

/// La partie à 18 joueurs de [VillageScenario], jouée dans l'application
/// complète, depuis l'accueil jusqu'au retour à l'accueil, en tapant sur
/// chaque écran (prénoms, répartition des rôles, chaque vote secret...).
/// Elle doit aboutir exactement au même état que la même partie jouée sur
/// le moteur seul (test/services/full_game_scenario_test.dart).
void main() {
  testWidgets('partie complète à 18 joueurs, écran par écran',
      (tester) async {
    final app = await AppHarness.start(tester);
    final driver = UiGameDriver(
      tester,
      app.game,
      VillageScenarioDecisions(),
      beforeStep: VillageScenario.checkpoint,
    );

    await driver.createGame(
      names: VillageScenario.names,
      roleCounts: {for (final role in VillageScenario.roles) role: 1},
      // La distribution est tirée au hasard : on impose les cartes du
      // scénario (même composition).
      rig: (s) => rigRoles(s, VillageScenario.roles),
    );
    await driver.playToEnd();

    final state = app.game.state!;
    VillageScenario.checkEnd(state);
    final loc = driver.loc;
    expect(find.text(loc.endGameWinnerVillage), findsOneWidget);

    // Statistiques : le village gagne en équipe, morts compris.
    await tester.pumpAndSettle();
    final wins = {for (final st in app.stats.stats) st.name: st.wins};
    expect(wins.length, 18);
    for (final p in state.players) {
      expect(wins[p.name], p.camp == Camp.village ? 1 : 0, reason: p.name);
    }

    await tapOnHome(tester, loc.endGameReturnHomeButton);
    expect(app.game.state, isNull);
    expect(find.text(loc.newGameButton), findsOneWidget);
  });
}
