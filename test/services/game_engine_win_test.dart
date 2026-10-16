import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_progress.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

import '../support/game_fixtures.dart';

/// Conditions de victoire, libellé du bouton « et ensuite ? », résumé live.
void main() {
  late GameEngine engine;
  setUp(() => engine = GameEngine(random: Random(7)));

  /// Partie où seuls [alive] sont encore en vie (le reste est mort), en
  /// journée.
  GameState tableWith(List<Seat> seats, List<String> alive) {
    final s = riggedGame(engine, seats);
    s.currentWave = 'day';
    for (final p in s.players) {
      if (!alive.contains(p.name)) {
        p.alive = false;
        p.deathCause = DeathCause.vote;
      }
    }
    return s;
  }

  const seats = <Seat>[
    ('Lg', RoleId.loupGarou),
    ('Lg2', RoleId.loupGarou),
    ('Lb', RoleId.loupBlanc),
    ('V1', RoleId.simpleVillageois),
    ('V2', RoleId.simpleVillageois),
    ('V3', RoleId.simpleVillageois),
  ];

  group('Victoire', () {
    test('du village quand tous les loups sont morts', () {
      final s = tableWith(seats, ['V1', 'V2']);
      final result = engine.checkWinCondition(s)!;
      expect(result.winner, Camp.village);
      expect(s.namesOf(result.winningPlayerIds), ['V1', 'V2']);
    });

    test('pas du village tant que le Loup Blanc vit', () {
      final s = tableWith(seats, ['Lb', 'V1', 'V2']);
      expect(engine.checkWinCondition(s), isNull);
    });

    test('du Loup Blanc, dernier survivant', () {
      final s = tableWith(seats, ['Lb']);
      final result = engine.checkWinCondition(s)!;
      expect(result.winner, Camp.seul);
      expect(s.namesOf(result.winningPlayerIds), ['Lb']);
    });

    test('des loups, majoritaires le jour', () {
      expect(
          engine.checkWinCondition(
              tableWith(seats, ['Lg', 'Lg2', 'V1', 'V2'])),
          isNull,
          reason: 'À égalité, le jour, le village peut encore voter');
      final s = tableWith(seats, ['Lg', 'Lg2', 'V1']);
      final result = engine.checkWinCondition(s)!;
      expect(result.winner, Camp.loups);
      expect(s.namesOf(result.winningPlayerIds).toSet(), {'Lg', 'Lg2'});
    });

    test('des Amoureux de camps opposés, derniers survivants', () {
      final s = tableWith(seats, ['Lg', 'V1']);
      s.named('Lg').loverId = s.idOf('V1');
      s.named('V1').loverId = s.idOf('Lg');
      final result = engine.checkWinCondition(s)!;
      expect(result.winner, Camp.amoureux);
      expect(s.namesOf(result.winningPlayerIds).toSet(), {'Lg', 'V1'});
    });

    test('de personne si plus personne n\'est en vie', () {
      final s = tableWith(seats, []);
      final result = engine.checkWinCondition(s)!;
      expect(result.winner, isNull);
      expect(result.winningPlayerIds, isEmpty);
    });

    test('match nul en jeu : la Sorcière empoisonne le loup qui la dévore', () {
      final s = startedGame(engine, [
        ('Lg', RoleId.loupGarou),
        ('Sor', RoleId.sorciere),
        ('V1', RoleId.simpleVillageois),
        ('V2', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      engine.dayToVote(s, mayor: s.idOf('Sor'));
      engine.resolveVillageVote(s, s.idOf('V2'));
      expect(engine.checkWinCondition(s), isNull, reason: '1 loup contre 1');
      engine.confirmVoteResult(s);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Sor'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, poisonTargetId: s.idOf('Lg'));
      engine.finishNight(s);

      expect(engine.upcomingStep(s, origin: FollowUpOrigin.nightDeaths),
          UpcomingStep.gameOver);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.endGame);
      expect(s.result!.winner, isNull);
    });
  });

  group('Bouton « et ensuite ? »', () {
    test('annonce le jour, puis la nuit, puis la fin de partie', () {
      final s = startedGame(engine, [
        ('Lg', RoleId.loupGarou),
        for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.nightDeaths),
          UpcomingStep.dayStarts);

      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('V3'));
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.voteDeaths),
          UpcomingStep.nightFalls);
      engine.confirmVoteResult(s);

      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V4'));
      engine.finishNight(s);
      engine.dayToVote(s);
      engine.resolveVillageVote(s, s.idOf('Lg'));
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.voteDeaths),
          UpcomingStep.gameOver);
      engine.confirmVoteResult(s);
      expect(s.phase, GamePhase.endGame);
      expect(s.result!.winner, Camp.village);
    });
  });

  group('Résumé live de la partie', () {
    test('les étapes de la nuit sont annoncées, puis cochées une à une', () {
      final s = startedGame(engine, [
        ('Voy', RoleId.voyante),
        ('Lg', RoleId.loupGarou),
        for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      List<(GamePhase, StepStatus)> steps() => [
            for (final st in s.rounds.last.steps) (st.phase, st.status),
          ];

      expect(s.rounds.single.wave, 'night');
      expect(steps(), [
        (GamePhase.nightVoyante, StepStatus.pending),
        (GamePhase.nightLoups, StepStatus.pending),
      ]);
      engine.skipTo(s, GamePhase.nightVoyante);
      expect(steps().first, (GamePhase.nightVoyante, StepStatus.current));
      engine.confirmVoyanteDone(s);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);

      expect(s.rounds, hasLength(2));
      expect(s.rounds.first.steps.map((st) => st.status),
          everyElement(StepStatus.done));
      expect(s.rounds.last.wave, 'day');
      expect(s.rounds.last.steps.first.phase, GamePhase.dayReveal);
      expect(s.rounds.last.steps.first.status, StepStatus.current);
    });

    test('la fin de partie retire les étapes qui n\'auront jamais lieu', () {
      final s = startedGame(engine, [
        ('Lg', RoleId.loupGarou),
        ('V1', RoleId.simpleVillageois),
        ('V2', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('Lg'));
      engine.confirmVoteResult(s);

      final steps = s.rounds.last.steps;
      expect(steps.last.phase, GamePhase.endGame);
      expect(steps.where((st) => st.status == StepStatus.pending), isEmpty);
    });
  });
}
