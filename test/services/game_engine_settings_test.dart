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

    test('activé : la victime protégée rejoint la meute', () {
      final s = protectedVictimInfected(true);
      expect(s.named('V1').camp, Camp.loups);
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

  group('Réglage « l\'Idiot du Village n\'est gracié qu\'une fois »', () {
    GameState idiotVotedTwice(bool diesSecondTime) {
      final s = startedGame(
        engine,
        [
          ('Idiot', RoleId.idiotDuVillage),
          ('Lg', RoleId.loupGarou),
          ('Lg2', RoleId.loupGarou),
          for (var i = 1; i <= 7; i++) ('V$i', RoleId.simpleVillageois),
        ],
        settings:
            settingsWith({SettingId.idiotDiesOnSecondVote: diesSecondTime}),
      );
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('Idiot'));
      engine.confirmVoteResult(s);
      engine.confirmIdiotDuVillageReveal(s);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      engine.finishNight(s);
      engine.dayToVote(s);
      engine.resolveVillageVote(s, s.idOf('Idiot'));
      return s;
    }

    test('désactivé (par défaut) : il survit encore', () {
      expect(GameSettings().idiotDiesOnSecondVote, isFalse);
      final s = idiotVotedTwice(false);
      expect(s.named('Idiot').alive, isTrue);
    });

    test('activé : démasqué, il meurt cette fois', () {
      final s = idiotVotedTwice(true);
      expect(s.named('Idiot').deathCause, DeathCause.vote);
      expect(s.namesOf(s.deathsThisWave), ['Idiot']);
    });
  });

  group('Réglage « le Loup Blanc empêche la victoire des loups »', () {
    // Il ne reste que la meute (dont le Loup Blanc) et un villageois.
    GameState packAlmostAlone(Map<SettingId, bool> values) {
      final s = riggedGame(
        engine,
        [
          ('Lg', RoleId.loupGarou),
          ('Lg2', RoleId.loupGarou),
          ('Lb', RoleId.loupBlanc),
          ('V1', RoleId.simpleVillageois),
          ('V2', RoleId.simpleVillageois),
        ],
        settings: settingsWith(values),
      );
      s.currentWave = 'day';
      s.named('V2')
        ..alive = false
        ..deathCause = DeathCause.vote;
      return s;
    }

    test('activé (par défaut) : la partie continue tant qu\'il vit', () {
      expect(GameSettings().loupBlancMustBeLastSurvivor, isTrue);
      expect(engine.checkWinCondition(packAlmostAlone({})), isNull);
    });

    test('désactivé : les loups gagnent, sans lui', () {
      final result = engine.checkWinCondition(packAlmostAlone(
          {SettingId.loupBlancMustBeLastSurvivor: false}))!;
      expect(result.winner, Camp.loups);
    });

    test('seule la meute reste, sans s\'entre-dévorer : pas de victime', () {
      final s = startedGame(
        engine,
        [
          ('Lg', RoleId.loupGarou),
          ('Lb', RoleId.loupBlanc),
          ('V1', RoleId.simpleVillageois),
          ('V2', RoleId.simpleVillageois),
        ],
        settings:
            settingsWith({SettingId.allowWerewolfToKillThemselves: false}),
      );
      for (final name in ['V1', 'V2']) {
        s.named(name)
          ..alive = false
          ..deathCause = DeathCause.vote;
      }
      engine.skipTo(s, GamePhase.nightLoups);
      expect(LegalChoices.loupsTargets(s), isEmpty);
      engine.setLoupsVictim(s, null);
      engine.finishNight(s);
      expect(s.deathsThisWave, isEmpty);
      expect(engine.checkWinCondition(s), isNull);
    });
  });

  group('Réglage « l\'Ancien tué par un villageois »', () {
    GameState ancienPoisoned(bool anyVillager) {
      final s = startedGame(
        engine,
        [
          ('Anc', RoleId.ancien),
          ('Sor', RoleId.sorciere),
          ('Voy', RoleId.voyante),
          ('Lg', RoleId.loupGarou),
          ('Lg2', RoleId.loupGarou),
          for (var i = 1; i <= 5; i++) ('V$i', RoleId.simpleVillageois),
        ],
        settings: settingsWith(
            {SettingId.ancienPowerLossByAnyVillager: anyVillager}),
      );
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, poisonTargetId: s.idOf('Anc'));
      engine.finishNight(s);
      return s;
    }

    test('activé (par défaut) : empoisonné, il coûte leurs pouvoirs', () {
      expect(GameSettings().ancienPowerLossByAnyVillager, isTrue);
      final s = ancienPoisoned(true);
      expect(s.named('Voy').role, RoleId.simpleVillageois);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.villagePowerLoss);
    });

    test('abattu par le Chasseur : idem', () {
      final s = startedGame(engine, [
        ('Anc', RoleId.ancien),
        ('Chas', RoleId.chasseur),
        ('Voy', RoleId.voyante),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 5; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Chas'));
      engine.finishNight(s);
      engine.confirmDayReveal(s);
      engine.resolveChasseurRevenge(s, s.idOf('Anc'));
      expect(s.phase, GamePhase.villagePowerLoss);
      expect(s.named('Voy').role, RoleId.simpleVillageois);
    });

    test('désactivé : seulement s\'il est pendu', () {
      final s = ancienPoisoned(false);
      expect(s.named('Voy').role, RoleId.voyante);
      expect(s.powerLossThisWave, isEmpty);
    });
  });

  group('Sorcière', () {
    test('voit la victime désignée même protégée, et peut gâcher sa potion',
        () {
      final s = startedGame(engine, [
        ('Sor', RoleId.sorciere),
        ('Sal', RoleId.salvateur),
        ('Lg', RoleId.loupGarou),
        for (var i = 1; i <= 5; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightSorciere);
      expect(LegalChoices.sorciereVictim(s)?.name, 'V1');
      engine.resolveSorciere(s, useVie: true);
      expect(s.sorciereVieUsed, isTrue, reason: 'Potion gâchée');
      engine.finishNight(s);
      expect(s.deathsThisWave, isEmpty);
    });

    test('ne voit pas de victime quand elle a été infectée', () {
      final s = startedGame(engine, [
        ('Sor', RoleId.sorciere),
        ('Ipl', RoleId.infectPereDesLoups),
        for (var i = 1; i <= 5; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.resolveInfectPereDesLoups(s, true);
      engine.skipTo(s, GamePhase.nightSorciere);
      expect(LegalChoices.sorciereVictim(s), isNull);
    });
  });
}
