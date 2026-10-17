import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

import '../support/game_decisions.dart';
import '../support/game_fixtures.dart';

/// Réglages de règles, et les anomalies corrigées lors de la revue des rôles.
void main() {
  late GameEngine engine;
  setUp(() => engine = GameEngine(random: Random(7)));

  group('Réglage « le Chasseur peut renverser une partie gagnée »', () {
    // Deux loups dévorent le Chasseur : à 2 contre 1, les loups gagnent...
    GameState hunterEaten(bool canOverturn) {
      final s = startedGame(
        engine,
        [
          ('Chas', RoleId.chasseur),
          ('Lg', RoleId.loupGarou),
          ('Lg2', RoleId.loupGarou),
          ('V1', RoleId.simpleVillageois),
        ],
        settings: settingsWith(
            {SettingId.hunterCanOverturnFinishedGame: canOverturn}),
      );
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Chas'));
      engine.finishNight(s);
      return s;
    }

    test('activé (par défaut) : il tire d\'abord', () {
      expect(GameSettings().hunterCanOverturnFinishedGame, isTrue);
      final s = hunterEaten(true);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.chasseurRevange);
    });

    test('désactivé : la partie se termine sans son tir', () {
      final s = hunterEaten(false);
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.nightDeaths),
          UpcomingStep.gameOver);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.endGame);
      expect(s.result!.winner, Camp.loups);
    });

    test('désactivé : il tire quand même si la partie n\'est pas finie', () {
      final s = startedGame(
        engine,
        [
          ('Chas', RoleId.chasseur),
          ('Lg', RoleId.loupGarou),
          for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
        ],
        settings:
            settingsWith({SettingId.hunterCanOverturnFinishedGame: false}),
      );
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Chas'));
      engine.finishNight(s);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.chasseurRevange);
    });
  });

  group('Réglage « le Voleur joue son nouveau rôle dès la première nuit »', () {
    GameState voleurTakesVoyante(bool firstNight) {
      final s = startedGame(
        engine,
        [
          ('Vol', RoleId.voleur),
          ('Lg', RoleId.loupGarou),
          for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
        ],
        tableCards: [RoleId.voyante, RoleId.simpleVillageois],
        settings:
            settingsWith({SettingId.voleurPlaysNewRoleFirstNight: firstNight}),
      );
      engine.skipTo(s, GamePhase.nightVoleur);
      engine.resolveVoleur(s, RoleId.voyante);
      expect(s.named('Vol').role, RoleId.voyante);
      return s;
    }

    test('activé (par défaut) : la Voyante est appelée cette nuit', () {
      expect(GameSettings().voleurPlaysNewRoleFirstNight, isTrue);
      final s = voleurTakesVoyante(true);
      expect(s.phaseQueue, contains(GamePhase.nightVoyante));
    });

    test('désactivé : elle ne joue qu\'à partir de la nuit suivante', () {
      final s = voleurTakesVoyante(false);
      expect(s.phaseQueue, isNot(contains(GamePhase.nightVoyante)));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      engine.dayToVote(s);
      engine.resolveVillageVote(s, s.idOf('V2'));
      engine.confirmVoteResult(s);
      expect(s.phaseQueue, contains(GamePhase.nightVoyante));
    });
  });

  group('Réglage « l\'Infect Père peut infecter une victime protégée »', () {
    GameState protectedVictimInfected(bool allowed) {
      final s = startedGame(
        engine,
        [
          ('Ipl', RoleId.infectPereDesLoups),
          ('Sal', RoleId.salvateur),
          for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
        ],
        settings:
            settingsWith({SettingId.infectCanInfectProtectedVictim: allowed}),
      );
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.resolveInfectPereDesLoups(s, true);
      engine.finishNight(s);
      return s;
    }

    test('désactivé (par défaut) : rien ne se passe, il garde son pouvoir',
        () {
      expect(GameSettings().infectCanInfectProtectedVictim, isFalse);
      final s = protectedVictimInfected(false);
      expect(s.named('V1').role, RoleId.simpleVillageois);
      expect(s.named('V1').alive, isTrue);
      expect(s.infectPereDesLoupsUsed, isFalse);
      engine.dayToVote(s);
      engine.resolveVillageVote(s, s.idOf('V2'));
      engine.confirmVoteResult(s);
      expect(s.phaseQueue, contains(GamePhase.nightInfectPereDesLoups));
    });

    test('activé : la victime protégée devient Loup-Garou', () {
      final s = protectedVictimInfected(true);
      expect(s.named('V1').role, RoleId.loupGarou);
      expect(s.infectPereDesLoupsUsed, isTrue);
    });

    test('ne peut pas infecter un loup, Loup Blanc compris', () {
      final s = startedGame(engine, [
        ('Ipl', RoleId.infectPereDesLoups),
        ('Lb', RoleId.loupBlanc),
        for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Lb'));
      engine.resolveInfectPereDesLoups(s, true);
      expect(s.infectPereDesLoupsUsed, isFalse);
    });
  });

  group('Salvateur', () {
    List<Seat> seats() => [
          ('Sal', RoleId.salvateur),
          ('Gml', RoleId.grandMechantLoup),
          ('Lb', RoleId.loupBlanc),
          ('Lg', RoleId.loupGarou),
          for (var i = 1; i <= 8; i++) ('V$i', RoleId.simpleVillageois),
        ];

    test('protège aussi de la seconde victime du Grand Méchant Loup', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('V2'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.resolveGrandMechantLoup(s, s.idOf('V2'));
      engine.finishNight(s);
      expect(s.namesOf(s.deathsThisWave), ['V1']);
    });

    test('protège aussi du Loup-Garou Blanc', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('V8'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      engine.dayToVote(s);
      engine.resolveVillageVote(s, s.idOf('V2'));
      engine.confirmVoteResult(s);
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('Lg'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      expect(s.phase, GamePhase.nightLoupBlanc);
      engine.resolveLoupBlanc(s, s.idOf('Lg'));
      engine.finishNight(s);
      expect(s.named('Lg').alive, isTrue);
    });
  });

  group('Loups qui ne peuvent pas se dévorer entre eux', () {
    test('le Loup Blanc fait partie de la meute protégée', () {
      final s = startedGame(
        engine,
        [
          ('Lg', RoleId.loupGarou),
          ('Gml', RoleId.grandMechantLoup),
          ('Lb', RoleId.loupBlanc),
          for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
        ],
        settings:
            settingsWith({SettingId.allowWerewolfToKillThemselves: false}),
      );
      expect(LegalChoices.loupsTargets(s).map((p) => p.name),
          everyElement(startsWith('V')));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      expect(LegalChoices.grandMechantLoupTargets(s).map((p) => p.name),
          everyElement(startsWith('V')));
    });
  });

  test('Corbeau : peut ne maudire personne', () {
    final s = startedGame(engine, [
      ('Cor', RoleId.corbeau),
      ('Lg', RoleId.loupGarou),
      for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
    ]);
    engine.skipTo(s, GamePhase.nightLoups);
    engine.setLoupsVictim(s, s.idOf('V1'));
    engine.skipTo(s, GamePhase.nightCorbeau);
    engine.resolveCorbeau(s, null);
    expect(s.corbeauCursedId, isNull);
    expect(s.phase, GamePhase.nightGoBackToSleep);
  });

  group('Suites annulées par une mort', () {
    test('la Servante abattue par le Chasseur ne choisit plus de rôle', () {
      final s = startedGame(engine, [
        ('Serv', RoleId.servanteDevouee),
        ('Chas', RoleId.chasseur),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 5; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('Chas'));
      expect(s.servanteDevoueeOfferId, s.idOf('Chas'));
      engine.confirmVoteResult(s);
      engine.resolveChasseurRevenge(s, s.idOf('Serv'));

      expect(s.servanteDevoueeOfferId, isNull);
      expect(s.phase, GamePhase.nightIntro);
    });

    test('l\'Enfant Sauvage tué juste après sa mutation n\'est pas annoncé',
        () {
      final s = startedGame(engine, [
        ('Enf', RoleId.enfantSauvage),
        ('Modele', RoleId.simpleVillageois),
        ('Sor', RoleId.sorciere),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightEnfantSauvage);
      engine.resolveEnfantSauvageMentor(s, s.idOf('Modele'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Modele'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, poisonTargetId: s.idOf('Enf'));
      engine.finishNight(s);

      expect(s.named('Enf').formerRole, RoleId.enfantSauvage);
      expect(s.enfantSauvageTransformedId, isNull);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.mayorElectionExplain);
    });
  });
}
