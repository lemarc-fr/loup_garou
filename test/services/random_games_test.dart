import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

import '../support/engine_runner.dart';
import '../support/game_decisions.dart';
import '../support/random_setup.dart';

/// Des centaines de parties complètes, compositions, réglages et choix
/// tirés au hasard. Chaque graine rejoue exactement la même partie : en cas
/// d'échec, le message donne la graine et le journal des actions.
void main() {
  const games = 600;

  test('$games parties au hasard vont au bout sans casser une règle', () {
    final winners = <Object?, int>{};
    var longest = 0;
    for (var seed = 0; seed < games; seed++) {
      final rng = Random(seed);
      final setup = RandomSetup(rng);
      final engine = GameEngine(random: rng);
      final state = engine.initGame(setup.config, setup.names, setup.settings);
      engine.startFirstNight(state);
      final runner = EngineRunner(engine, state, RandomDecisions(rng));
      try {
        runner.playToEnd();
      } catch (e) {
        fail('Graine $seed (${setup.names.length} joueurs, '
            '${setup.config.roleCounts.entries.where((e) => e.value > 0).map((e) => '${e.key.name}×${e.value}').join(', ')}) :\n$e');
      }
      expect(state.phase, GamePhase.endGame);
      winners.update(state.result!.winner, (n) => n + 1, ifAbsent: () => 1);
      longest = max(longest, state.night);
    }
    // Les parties couvrent bien les différentes issues (la victoire des
    // Amoureux et le match nul, rares au hasard, ont leurs propres tests).
    expect(winners.keys, containsAll([Camp.village, Camp.loups, Camp.seul]),
        reason: 'Issues observées : $winners');
    expect(longest, lessThan(40));
  });
}
