import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/screens/game/day_reveal_screen.dart';
import 'package:thiercelieux/services/game_engine.dart';
import 'package:thiercelieux/theme/app_theme.dart';

import '../support/game_fixtures.dart';
import '../support/screen_harness.dart';

void main() {
  late GameProvider gp;

  /// Nuit 1 : les loups dévorent Bob, voisin du Montreur d'Ours.
  void nightWhereBobDies() {
    gp = GameProvider(engine: GameEngine(random: Random(1)));
    gp.state = startedGame(gp.engine, [
      ('Alice', RoleId.loupGarou),
      ('Bob', RoleId.voyante),
      ('Chloé', RoleId.montreurDours),
      ('David', RoleId.simpleVillageois),
      ('Emma', RoleId.simpleVillageois),
    ]);
    final s = gp.state!;
    gp.engine.skipTo(s, GamePhase.nightLoups);
    gp.engine.setLoupsVictim(s, s.idOf('Bob'));
    gp.engine.finishNight(s);
  }

  testWidgets('annonce les morts de la nuit avec leur rôle et leur cause',
      (tester) async {
    nightWhereBobDies();
    final loc = await pumpScreen(tester, gp, const DayRevealScreen(),
        theme: AppTheme.day);

    expect(find.text(loc.dayRevealSingleDeath), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(
        find.text('${loc.roleName(RoleId.voyante)} — '
            '${loc.deathCauseDevoreParLesLoups}'),
        findsOneWidget);
    // Le Montreur (Chloé) a maintenant Alice, un loup, pour voisine.
    expect(find.text(loc.montreurDoursGrowlsText), findsOneWidget);
  });

  testWidgets('réglage : la cause de la mort peut rester secrète',
      (tester) async {
    nightWhereBobDies();
    gp.state!.settings.set(SettingId.revealDeathCause, false);
    final loc = await pumpScreen(tester, gp, const DayRevealScreen(),
        theme: AppTheme.day);

    expect(find.text('Bob'), findsOneWidget);
    expect(find.text(loc.roleName(RoleId.voyante)), findsOneWidget);
    expect(find.textContaining(loc.deathCauseDevoreParLesLoups), findsNothing);
  });

  testWidgets('le bouton lance la journée', (tester) async {
    nightWhereBobDies();
    final loc = await pumpScreen(tester, gp, const DayRevealScreen(),
        theme: AppTheme.day);

    await tester.tap(find.text(loc.villageWakesUpButton));
    await tester.pump();
    expect(gp.state!.phase, GamePhase.mayorElectionExplain);
  });

  testWidgets('nuit calme : aucune mort annoncée', (tester) async {
    gp = GameProvider(engine: GameEngine(random: Random(1)));
    gp.state = startedGame(gp.engine, [
      ('Alice', RoleId.loupGarou),
      ('Bob', RoleId.salvateur),
      ('Chloé', RoleId.simpleVillageois),
      ('David', RoleId.simpleVillageois),
    ]);
    final s = gp.state!;
    gp.engine.skipTo(s, GamePhase.nightSalvateur);
    gp.engine.resolveSalvateur(s, s.idOf('Chloé'));
    gp.engine.skipTo(s, GamePhase.nightLoups);
    gp.engine.setLoupsVictim(s, s.idOf('Chloé'));
    gp.engine.finishNight(s);

    final loc = await pumpScreen(tester, gp, const DayRevealScreen(),
        theme: AppTheme.day);
    expect(find.text(loc.dayRevealNoDeaths), findsOneWidget);
    expect(find.text('Chloé'), findsNothing);
  });
}
