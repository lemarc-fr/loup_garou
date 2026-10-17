import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/screens/game/role_screens/bouc_emissaire_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/infected_reveal_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/loups_screen.dart';
import 'package:thiercelieux/screens/game/village_vote_screen.dart';
import 'package:thiercelieux/screens/game/vote_result_screen.dart';
import 'package:thiercelieux/services/game_engine.dart';
import 'package:thiercelieux/theme/app_theme.dart';
import 'package:thiercelieux/widgets/player_grid_selector.dart';

import '../support/game_fixtures.dart';
import '../support/screen_harness.dart';

/// Écrans des règles d'égalité, du Bouc Émissaire et de l'infection.
void main() {
  late GameProvider gp;

  GameState newGame(List<Seat> seats, {Map<SettingId, bool> settings = const {}}) {
    gp = GameProvider(engine: GameEngine(random: Random(1)));
    return gp.state =
        startedGame(gp.engine, seats, settings: settingsWith(settings));
  }

  Finder tile(String name) => find.descendant(
      of: find.byType(PlayerGridSelector), matching: find.text(name));

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Jour 1, au vote du village, maire V1 élu.
  GameState voteDay(List<Seat> seats, VoteMode mode,
      {Map<SettingId, bool> settings = const {}}) {
    final s = newGame(seats, settings: settings);
    final e = gp.engine;
    e.skipTo(s, GamePhase.nightLoups);
    e.setLoupsVictim(s, s.idOf('V4'));
    e.finishNight(s);
    e.confirmDayReveal(s);
    e.confirmMayorElectionExplain(s, VoteMode.secret);
    e.resolveMayorElection(s, s.idOf('V1'));
    e.confirmMayorReveal(s);
    e.confirmDebate(s, mode);
    expect(s.phase, GamePhase.villageVote);
    return s;
  }

  const fourVillagers = <Seat>[
    ('Lg', RoleId.loupGarou),
    ('V1', RoleId.simpleVillageois),
    ('V2', RoleId.simpleVillageois),
    ('V3', RoleId.simpleVillageois),
    ('V4', RoleId.simpleVillageois),
  ];

  testWidgets('vote secret à égalité : le maire tranche, en public',
      (tester) async {
    final s = voteDay(fourVillagers, VoteMode.secret);
    final loc = await pumpScreen(tester, gp, const VillageVoteScreen(),
        theme: AppTheme.day);

    final ballots = {'Lg': 'V2', 'V1': 'Lg', 'V2': 'V2', 'V3': 'V3'};
    for (final voter in s.eligibleVoters) {
      await tap(tester, find.text(loc.passDeviceConfirmButton));
      // Chaque votant voit la règle d'égalité.
      expect(find.text(loc.voteTieRuleMayor), findsOneWidget);
      await tap(tester, tile(ballots[voter.name]!));
    }
    // Lg : 2 (maire), V2 : 2, V3 : 1 → égalité Lg / V2.
    expect(find.text(loc.voteTieMayorInstruction('V1')), findsOneWidget);
    expect(tester.widget<PlayerGridSelector>(find.byType(PlayerGridSelector))
        .players.map((p) => p.name), unorderedEquals(['Lg', 'V2']));
    await tap(tester, tile('Lg'));
    expect(s.phase, GamePhase.voteResult);
    expect(s.namesOf(s.deathsThisWave), ['Lg']);
    expect(s.lastVoteTie, VoteTieRule.mayorDecides);
  });

  testWidgets('vote public : « Égalité » élimine le Bouc Émissaire',
      (tester) async {
    final s = voteDay(
        [('Bouc', RoleId.boucEmissaire), ...fourVillagers], VoteMode.collective);
    final loc = await pumpScreen(tester, gp, const VillageVoteScreen(),
        theme: AppTheme.day);
    expect(find.text(loc.voteTieRuleBouc), findsOneWidget);
    await tap(tester, find.text(loc.voteTieButton));
    expect(s.namesOf(s.deathsThisWave), ['Bouc']);
    expect(s.lastVoteTie, VoteTieRule.boucEmissaire);
  });

  testWidgets('vote public, règle « second tour » : pas de bouton Égalité',
      (tester) async {
    voteDay(fourVillagers, VoteMode.collective,
        settings: {SettingId.mayorBreaksTies: false});
    final loc = await pumpScreen(tester, gp, const VillageVoteScreen(),
        theme: AppTheme.day);
    expect(find.text(loc.voteTieRuleRunoff), findsOneWidget);
    expect(find.text(loc.voteTieButton), findsNothing);
  });

  testWidgets('le résultat annonce comment l\'égalité a été réglée',
      (tester) async {
    final s = voteDay(
        [('Bouc', RoleId.boucEmissaire), ...fourVillagers], VoteMode.secret);
    gp.engine.resolveVillageVoteTie(s);
    final loc = await pumpScreen(tester, gp, const VoteResultScreen(),
        theme: AppTheme.day);
    expect(find.text(loc.voteResultTieBouc), findsOneWidget);
    expect(find.text('Bouc'), findsOneWidget);
  });

  testWidgets('le Bouc Émissaire choisit les votants du lendemain',
      (tester) async {
    final s = voteDay(
        [('Bouc', RoleId.boucEmissaire), ...fourVillagers], VoteMode.secret);
    gp.engine.resolveVillageVoteTie(s);
    gp.engine.confirmVoteResult(s);
    expect(s.phase, GamePhase.boucEmissaire);

    final loc = await pumpScreen(tester, gp, const BoucEmissaireScreen(),
        theme: AppTheme.day);
    // Tout le monde (4 vivants) est coché ; il retire Lg et V2.
    expect(find.text(loc.boucEmissaireConfirmVoters(4)), findsOneWidget);
    await tap(tester, tile('Lg'));
    await tap(tester, tile('V2'));
    await tap(tester, find.text(loc.boucEmissaireConfirmVoters(2)));

    expect(s.namesOf(s.boucAllowedVoterIds).toSet(), {'V1', 'V3'});
    expect(s.boucVoteRestrictionDay, 2);
    expect(s.phase, GamePhase.nightIntro);
  });

  testWidgets("l'infectée l'apprend en secret, avec son pouvoir gardé",
      (tester) async {
    final s = newGame([
      ('Ipl', RoleId.infectPereDesLoups),
      ('Voy', RoleId.voyante),
      for (var i = 1; i <= 5; i++) ('V$i', RoleId.simpleVillageois),
    ]);
    final e = gp.engine;
    e.skipTo(s, GamePhase.nightLoups);
    e.setLoupsVictim(s, s.idOf('Voy'));
    e.resolveInfectPereDesLoups(s, true);
    e.finishNight(s);
    e.dayToVote(s);
    e.resolveVillageVote(s, s.idOf('V1'));
    e.confirmVoteResult(s);
    e.skipTo(s, GamePhase.nightInfectedReveal);

    final loc = await pumpScreen(tester, gp, const InfectedRevealScreen());
    expect(find.text('Voy'), findsOneWidget, reason: 'Le téléphone va à Voy');
    await tap(tester, find.text(loc.passDeviceConfirmButton));
    expect(find.text(loc.infectedRevealInstruction), findsOneWidget);
    expect(
        find.text(loc.infectedRevealKeepsPower(loc.roleName(RoleId.voyante))),
        findsOneWidget);
    await tap(tester, find.text(loc.goBackToSleepButton));
    expect(s.infectedRevealPendingId, isNull);
    expect(loc.playerRoleLabel(s.named('Voy')),
        loc.roleInfected(loc.roleName(RoleId.voyante)));
  });

  testWidgets('les loups seuls entre eux : « aucune victime possible »',
      (tester) async {
    final s = newGame([
      ('Lg', RoleId.loupGarou),
      ('Lb', RoleId.loupBlanc),
      ('V1', RoleId.simpleVillageois),
    ], settings: {SettingId.allowWerewolfToKillThemselves: false});
    s.named('V1')
      ..alive = false
      ..deathCause = DeathCause.vote;
    gp.engine.skipTo(s, GamePhase.nightLoups);

    final loc = await pumpScreen(tester, gp, const LoupsScreen());
    await tap(tester, find.text(loc.passDeviceConfirmButton));
    await tap(tester, find.text(loc.loupsNoPossibleVictimButton));
    expect(s.loupsVictimId, isNull);
    expect(s.phase, isNot(GamePhase.nightLoups));
  });
}
