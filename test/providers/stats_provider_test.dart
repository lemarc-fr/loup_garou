import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/stats_provider.dart';
import 'package:thiercelieux/services/game_engine.dart';

import '../support/game_fixtures.dart';

/// Statistiques : qui a gagné, et persistance entre deux lancements.
void main() {
  late StatsProvider stats;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    stats = StatsProvider();
    await stats.load();
  });

  const seats = <Seat>[
    ('Loup', RoleId.loupGarou),
    ('Blanc', RoleId.loupBlanc),
    ('Voy', RoleId.voyante),
    ('Vil', RoleId.simpleVillageois),
  ];

  GameState finished(Camp? winner, List<String> winners,
      {List<String> dead = const []}) {
    final s = riggedGame(GameEngine(random: Random(1)), seats);
    for (final name in dead) {
      s.named(name)
        ..alive = false
        ..deathCause = DeathCause.vote;
    }
    s.result = GameResult(winner, [for (final n in winners) s.idOf(n)]);
    return s;
  }

  Map<String, int> wins() => {for (final st in stats.stats) st.name: st.wins};

  test('victoire du village : tout le camp gagne, morts compris', () async {
    await stats.recordGameResult(
        finished(Camp.village, ['Vil'], dead: ['Loup', 'Blanc', 'Voy']));
    expect(wins(), {'Voy': 1, 'Vil': 1, 'Loup': 0, 'Blanc': 0});
  });

  test('victoire des loups : le Loup Blanc, solitaire, a perdu', () async {
    await stats.recordGameResult(finished(Camp.loups, ['Loup']));
    expect(wins(), {'Loup': 1, 'Blanc': 0, 'Voy': 0, 'Vil': 0});
  });

  test('victoire du Loup Blanc : lui seul gagne, pas la meute', () async {
    await stats.recordGameResult(finished(Camp.seul, ['Blanc']));
    expect(wins(), {'Blanc': 1, 'Loup': 0, 'Voy': 0, 'Vil': 0});
  });

  test('victoire des Amoureux : seuls les deux Amoureux gagnent', () async {
    await stats.recordGameResult(finished(Camp.amoureux, ['Loup', 'Voy']));
    expect(wins(), {'Loup': 1, 'Voy': 1, 'Blanc': 0, 'Vil': 0});
  });

  test('personne en vie : personne ne gagne', () async {
    await stats.recordGameResult(finished(null, []));
    expect(wins().values, everyElement(0));
  });

  test('l\'historique est conservé entre deux lancements, prénoms sans casse',
      () async {
    await stats.recordGameResult(finished(Camp.village, ['Vil']));
    final reloaded = StatsProvider();
    await reloaded.load();
    expect(reloaded.stats, hasLength(4));

    final next = finished(Camp.village, ['Vil']);
    next.named('Vil').name = 'VIL';
    await reloaded.recordGameResult(next);
    final vil = reloaded.stats.firstWhere((st) => st.name == 'Vil');
    expect(vil.gamesPlayed, 2);
    expect(vil.wins, 2);
    expect(vil.favoriteRole, RoleId.simpleVillageois);

    await reloaded.clearAll();
    final empty = StatsProvider();
    await empty.load();
    expect(empty.stats, isEmpty);
  });
}
