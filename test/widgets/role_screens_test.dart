import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/screens/game/end_game_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/loup_blanc_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/salvateur_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/sorciere_screen.dart';
import 'package:thiercelieux/services/game_engine.dart';
import 'package:thiercelieux/widgets/phase_entrance.dart';
import 'package:thiercelieux/widgets/player_grid_selector.dart';

import '../support/game_fixtures.dart';
import '../support/screen_harness.dart';

/// Écrans de rôle dont le comportement suit une règle précise.
void main() {
  late GameProvider gp;


  GameState newGame(List<Seat> seats) {
    gp = GameProvider(engine: GameEngine(random: Random(1)));
    return gp.state = startedGame(gp.engine, seats);
  }

  Finder tile(String name) => find.descendant(
      of: find.byType(PlayerGridSelector), matching: find.text(name));

  Future<void> passDevice(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  group('Loup Blanc', () {
    GameState evenNight() {
      final s = newGame([
        ('Lb', RoleId.loupBlanc),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 7; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      final e = gp.engine;
      e.skipTo(s, GamePhase.nightLoups);
      e.setLoupsVictim(s, s.idOf('V1'));
      e.finishNight(s);
      e.dayToVote(s);
      e.resolveVillageVote(s, s.idOf('V2'));
      e.confirmVoteResult(s);
      e.skipTo(s, GamePhase.nightLoups);
      e.setLoupsVictim(s, s.idOf('V3'));
      expect(s.phase, GamePhase.nightLoupBlanc);
      return s;
    }

    testWidgets('ne propose que les autres loups', (tester) async {
      final s = evenNight();
      final loc = await pumpScreen(tester, gp, const LoupBlancScreen());
      await passDevice(tester, loc.passDeviceConfirmButton);

      final shown = tester
          .widget<PlayerGridSelector>(find.byType(PlayerGridSelector))
          .players
          .map((p) => p.name);
      expect(shown, ['Lg', 'Lg2']);
      await tester.tap(tile('Lg2'));
      await tester.pump();
      expect(s.loupBlancVictimId, s.idOf('Lg2'));
    });

    testWidgets('peut renoncer cette nuit', (tester) async {
      final s = evenNight();
      final loc = await pumpScreen(tester, gp, const LoupBlancScreen());
      await passDevice(tester, loc.passDeviceConfirmButton);
      await tester.tap(find.text(loc.skipPowerThisNightButton));
      await tester.pump();
      expect(s.loupBlancVictimId, isNull);
      expect(s.phase, isNot(GamePhase.nightLoupBlanc));
    });
  });

  testWidgets('Salvateur : le protégé de la veille ne peut pas être choisi',
      (tester) async {
    final s = newGame([
      ('Sal', RoleId.salvateur),
      ('Lg', RoleId.loupGarou),
      ('Lg2', RoleId.loupGarou),
      for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
    ]);
    final e = gp.engine;
    e.skipTo(s, GamePhase.nightSalvateur);
    e.resolveSalvateur(s, s.idOf('V1'));
    e.skipTo(s, GamePhase.nightLoups);
    e.setLoupsVictim(s, s.idOf('V2'));
    e.finishNight(s);
    e.dayToVote(s);
    e.resolveVillageVote(s, s.idOf('V3'));
    e.confirmVoteResult(s);
    e.skipTo(s, GamePhase.nightSalvateur);

    final loc = await pumpScreen(tester, gp, const SalvateurScreen());
    await passDevice(tester, loc.passDeviceConfirmButton);

    await tester.tap(tile('V1'));
    await tester.pump();
    expect(s.phase, GamePhase.nightSalvateur, reason: 'Tuile inactive');
    await tester.tap(tile('V4'));
    await tester.pump();
    expect(s.salvateurProtectedId, s.idOf('V4'));
  });

  testWidgets('Sorcière : sauver la victime et empoisonner un joueur',
      (tester) async {
    final s = newGame([
      ('Sor', RoleId.sorciere),
      ('Lg', RoleId.loupGarou),
      ('V1', RoleId.simpleVillageois),
      ('V2', RoleId.simpleVillageois),
      ('V3', RoleId.simpleVillageois),
    ]);
    gp.engine.skipTo(s, GamePhase.nightLoups);
    gp.engine.setLoupsVictim(s, s.idOf('V1'));
    gp.engine.skipTo(s, GamePhase.nightSorciere);

    final loc = await pumpScreen(tester, gp, const SorciereScreen());
    await passDevice(tester, loc.passDeviceConfirmButton);
    expect(find.text(loc.sorciereInstructionWithVictim('V1')), findsOneWidget);

    await tester.tap(find.text(loc.sorciereUseLifePotion('V1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(loc.sorciereUseDeathPotion));
    await tester.pumpAndSettle();
    expect(tile('Sor'), findsNothing, reason: 'Pas elle-même');
    await tester.ensureVisible(tile('Lg'));
    await tester.tap(tile('Lg'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(loc.confirmAndGoBackToSleepButton));
    await tester.tap(find.text(loc.confirmAndGoBackToSleepButton));
    await tester.pump();

    expect(s.sorciereSavedIdTonight, s.idOf('V1'));
    expect(s.sorciereKilledIdTonight, s.idOf('Lg'));
  });

  testWidgets('fin de partie sans survivant : « personne ne gagne »',
      (tester) async {
    final s =
        newGame([('Lg', RoleId.loupGarou), ('V1', RoleId.simpleVillageois)]);
    for (final p in s.players) {
      p
        ..alive = false
        ..deathCause = DeathCause.potionDeMort;
    }
    s.result = const GameResult(null, []);
    s.phase = GamePhase.endGame;

    final loc = await pumpScreen(tester, gp, const EndGameScreen());
    expect(find.text(loc.endGameWinnerNobody), findsOneWidget);
    expect(find.text(loc.roleName(RoleId.loupGarou)), findsOneWidget);
  });

  group('Entrée des écrans', () {
    testWidgets('le nouvel écran apparaît en fondu', (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: PhaseEntrance(child: Text('Nuit'))));
      double opacity() => tester
          .widget<FadeTransition>(find.descendant(
              of: find.byType(PhaseEntrance),
              matching: find.byType(FadeTransition)))
          .opacity
          .value;
      expect(opacity(), 0);
      await tester.pump(const Duration(milliseconds: 140));
      expect(opacity(), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(opacity(), 1);
    });

    testWidgets('sans animation si le téléphone les a désactivées',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: PhaseEntrance(child: Text('Nuit')),
        ),
      ));
      expect(
          find.descendant(
              of: find.byType(PhaseEntrance),
              matching: find.byType(FadeTransition)),
          findsNothing);
    });
  });
}
