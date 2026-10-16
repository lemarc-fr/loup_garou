import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/services/game_engine.dart';

import '../support/engine_runner.dart';
import '../support/game_fixtures.dart';
import '../support/village_scenario.dart';

/// La partie à 18 joueurs de [VillageScenario], jouée sur le moteur seul.
/// Le même scénario est rejoué écran par écran dans
/// test/widgets/full_game_ui_test.dart.
void main() {
  test('partie complète à 18 joueurs : le village gagne au jour 7', () {
    final engine = GameEngine();
    final state = startedGame(engine, VillageScenario.seats);
    final phases = <GamePhase>{};
    final runner = EngineRunner(
      engine,
      state,
      VillageScenarioDecisions(),
      beforeStep: (s) {
        phases.add(s.phase);
        VillageScenario.checkpoint(s);
      },
    );

    runner.playToEnd();

    VillageScenario.checkEnd(state);
    // Le scénario passe bien par tous ces écrans.
    expect(
        phases,
        containsAll([
          GamePhase.nightCupidon,
          GamePhase.nightLoversReveal,
          GamePhase.nightEnfantSauvage,
          GamePhase.nightEnfantSauvageCheck,
          GamePhase.nightSalvateur,
          GamePhase.nightVoyante,
          GamePhase.nightLoups,
          GamePhase.nightLoupBlanc,
          GamePhase.nightGrandMechantLoup,
          GamePhase.nightInfectPereDesLoups,
          GamePhase.nightRenard,
          GamePhase.nightCorbeau,
          GamePhase.nightSorciere,
          GamePhase.dayReveal,
          GamePhase.mayorElectionExplain,
          GamePhase.mayorElection,
          GamePhase.mayorReveal,
          GamePhase.debate,
          GamePhase.jugeBegueDecision,
          GamePhase.villageVote,
          GamePhase.voteResult,
          GamePhase.chasseurRevange,
          GamePhase.successionMaire,
          GamePhase.enfantsauvageReveal,
          GamePhase.villagePowerLoss,
          GamePhase.servanteDevouee,
          GamePhase.boucEmissaire,
          GamePhase.idiotduvillageCivicRightLoss,
        ]));
  });
}
