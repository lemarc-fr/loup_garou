import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_settings.dart';

import '../support/app_harness.dart';
import '../support/engine_runner.dart';
import '../support/game_decisions.dart';
import '../support/random_setup.dart';
import '../support/ui_game_driver.dart';

/// Parties complètes dans l'application, en anglais, avec des compositions,
/// des réglages et des choix tirés au hasard (graine fixe : chaque partie se
/// rejoue à l'identique). Vérifie qu'aucun écran ne plante, ne se bloque ni
/// ne déborde, quelle que soit la combinaison de rôles.
void main() {
  // Graines choisies pour couvrir, entre elles : Voleur, Amoureux tirés au
  // sort et Cupidon, Loup Blanc, Ancien, Servante, mutation de l'Enfant
  // Sauvage publique et secrète.
  for (final seed in [0, 33, 39]) {
    testWidgets('partie au hasard n°$seed jouée dans l\'interface',
        (tester) async {
      final rng = Random(seed);
      final setup = RandomSetup(rng, minPlayers: 12, maxPlayers: 16);
      final app = await AppHarness.start(
        tester,
        language: 'en',
        seed: seed,
        preferences: {
          'thiercelieux.game_settings.v1': _settingsJson(setup.settings),
        },
      );
      final driver = UiGameDriver(tester, app.game, RandomDecisions(rng));

      await driver.createGame(
        names: setup.names,
        roleCounts: {
          for (final e in setup.config.roleCounts.entries)
            if (e.value > 0) e.key: e.value,
        },
        randomLovers: setup.config.randomLovers,
      );
      final state = app.game.state!;
      expect(state.loversIds, hasLength(setup.config.randomLovers ? 2 : 0));
      // Trace utile pour relire un échec.
      debugPrint('Graine $seed : ${setup.names.length} joueurs, '
          '${state.players.map((p) => p.role.name).toSet().join(', ')}'
          '${setup.config.randomLovers ? ', amoureux tirés au sort' : ''}');
      await driver.playToEnd();

      expectConsistentResult(app.game.state!);
      await tester.pumpAndSettle();
      expect(app.stats.stats, hasLength(setup.names.length));
    });
  }
}

String _settingsJson(GameSettings settings) {
  final entries = settings
      .toJson()
      .entries
      .map((e) => '"${e.key}":${e.value}')
      .join(',');
  return '{$entries}';
}
