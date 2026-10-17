import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_progress.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

import '../support/game_fixtures.dart';

/// Distribution des cartes, file de la nuit et rôles de nuit.
void main() {
  late GameEngine engine;
  setUp(() => engine = GameEngine(random: Random(7)));

  Map<RoleId, int> countRoles(Iterable<RoleId> roles) {
    final counts = <RoleId, int>{};
    for (final r in roles) {
      counts[r] = (counts[r] ?? 0) + 1;
    }
    return counts;
  }

  /// Termine le jour en éliminant [voted] : on arrive à l'intro de la nuit
  /// suivante.
  void toNextNight(GameState s, String voted) {
    engine.dayToVote(s);
    engine.resolveVillageVote(s, s.idOf(voted));
    engine.confirmVoteResult(s);
    expect(s.phase, GamePhase.nightIntro, reason: 'Une suite reste à jouer');
  }

  group('Distribution des cartes', () {
    const names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    test('chaque joueur reçoit une carte de la composition choisie', () {
      final roles = {
        RoleId.loupGarou: 2,
        RoleId.voyante: 1,
        RoleId.sorciere: 1,
        RoleId.chasseur: 1,
        RoleId.simpleVillageois: 3,
      };
      final s = engine.initGame(
          GameConfig(playerCount: 8, roleCounts: roles), names, GameSettings());

      expect(s.players.map((p) => p.name), names);
      expect(s.players.map((p) => p.id).toSet(), hasLength(8));
      expect(countRoles(s.players.map((p) => p.role)), roles);
      expect(s.voleurTableCards, isEmpty);
      expect(s.players.every((p) => p.alive && !p.isMayor && !p.isLover),
          isTrue);
    });

    test('avec le Voleur, deux cartes de plus restent sur la table', () {
      final roles = {
        RoleId.loupGarou: 2,
        RoleId.voleur: 1,
        RoleId.voyante: 1,
        RoleId.simpleVillageois: 6,
      };
      final s = engine.initGame(
          GameConfig(playerCount: 8, roleCounts: roles), names, GameSettings());

      expect(s.players, hasLength(8));
      expect(s.voleurTableCards, hasLength(2));
      expect(
          countRoles([...s.players.map((p) => p.role), ...s.voleurTableCards]),
          roles);
    });

    test('la même graine redonne la même distribution', () {
      List<RoleId> deal(int seed) => GameEngine(random: Random(seed))
          .initGame(GameConfig(playerCount: 8), names, GameSettings())
          .players
          .map((p) => p.role)
          .toList();
      expect(deal(3), deal(3));
    });

    test('Amoureux tirés au sort : deux joueurs liés l\'un à l\'autre', () {
      final s = engine.initGame(
          GameConfig(playerCount: 8, randomLovers: true), names, GameSettings());
      final lovers = s.players.where((p) => p.isLover).toList();
      expect(lovers, hasLength(2));
      expect(lovers[0].loverId, lovers[1].id);
      expect(lovers[1].loverId, lovers[0].id);
      expect(s.loversIds.toSet(), {lovers[0].id, lovers[1].id});
    });
  });

  group('File de la nuit', () {
    test('première nuit : chaque rôle est appelé, dans l\'ordre', () {
      final s = startedGame(engine, [
        ('Vol', RoleId.voleur),
        ('Cup', RoleId.cupidon),
        ('Enf', RoleId.enfantSauvage),
        ('Sal', RoleId.salvateur),
        ('Voy', RoleId.voyante),
        ('Lg', RoleId.loupGarou),
        ('Gml', RoleId.grandMechantLoup),
        ('Ipl', RoleId.infectPereDesLoups),
        ('Lb', RoleId.loupBlanc),
        ('Ren', RoleId.renard),
        ('Cor', RoleId.corbeau),
        ('Sor', RoleId.sorciere),
      ], tableCards: [RoleId.simpleVillageois, RoleId.simpleVillageois]);

      expect(s.phaseQueue, [
        GamePhase.nightIntro,
        GamePhase.nightVoleur,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightCupidon,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightLoversReveal,
        GamePhase.nightEnfantSauvage,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightSalvateur,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightVoyante,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightLoups,
        // Pas de Loup Blanc la première nuit.
        GamePhase.nightGrandMechantLoup,
        GamePhase.nightInfectPereDesLoups,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightRenard,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightCorbeau,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightSorciere,
        GamePhase.nightGoBackToSleep,
      ]);
    });

    test('les rôles de la première nuit ne sont plus appelés ensuite', () {
      final s = startedGame(engine, [
        ('Cup', RoleId.cupidon),
        ('Enf', RoleId.enfantSauvage),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 5; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightCupidon);
      engine.resolveCupidon(s, s.idOf('V1'), s.idOf('V2'));
      engine.skipTo(s, GamePhase.nightEnfantSauvage);
      engine.resolveEnfantSauvageMentor(s, s.idOf('V3'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V4'));
      engine.finishNight(s);
      toNextNight(s, 'V5');

      // Cupidon est vivant mais n'est plus appelé ; l'Enfant Sauvage ne fait
      // plus que confirmer qu'il est encore humain.
      expect(s.phaseQueue, [
        GamePhase.nightIntro,
        GamePhase.nightEnfantSauvageCheck,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightLoups,
        GamePhase.nightGoBackToSleep,
      ]);
    });

    test("l'Enfant Sauvage confirme chaque nuit qu'il est encore humain", () {
      final s = startedGame(engine, [
        ('Enf', RoleId.enfantSauvage),
        ('Lg', RoleId.loupGarou),
        ('V1', RoleId.simpleVillageois),
        ('V2', RoleId.simpleVillageois),
        ('V3', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightEnfantSauvage);
      engine.resolveEnfantSauvageMentor(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      engine.finishNight(s);
      toNextNight(s, 'V2');

      expect(s.phaseQueue.take(2),
          [GamePhase.nightIntro, GamePhase.nightEnfantSauvageCheck]);
    });

    test('le Loup Blanc se réveille seul une nuit sur deux (nuits paires)',
        () {
      final s = startedGame(engine, [
        ('Lb', RoleId.loupBlanc),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 7; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      bool callsLoupBlanc() => s.phaseQueue.contains(GamePhase.nightLoupBlanc);

      expect(callsLoupBlanc(), isFalse, reason: 'nuit 1');
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      toNextNight(s, 'V2');
      expect(callsLoupBlanc(), isTrue, reason: 'nuit 2');
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      engine.finishNight(s);
      toNextNight(s, 'V4');
      expect(callsLoupBlanc(), isFalse, reason: 'nuit 3');
    });

    test('le Loup Blanc, dernier loup en vie, chasse encore la nuit', () {
      final s = startedGame(engine, [
        ('Lb', RoleId.loupBlanc),
        ('V1', RoleId.simpleVillageois),
        ('V2', RoleId.simpleVillageois),
        ('V3', RoleId.simpleVillageois),
      ]);
      expect(s.wolfPackAwake, isTrue);
      expect(s.phaseQueue, contains(GamePhase.nightLoups));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      expect(s.phase, GamePhase.nightGoBackToSleep);
      engine.finishNight(s);
      expect(s.named('V1').alive, isFalse);
    });

    test('Grand Méchant Loup : plus de seconde victime dès qu\'un loup meurt',
        () {
      final s = startedGame(engine, [
        ('Gml', RoleId.grandMechantLoup),
        ('Lg', RoleId.loupGarou),
        for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      expect(s.phaseQueue, contains(GamePhase.nightGrandMechantLoup));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.resolveGrandMechantLoup(s, s.idOf('V2'));
      engine.finishNight(s);
      expect(s.deadNames, ['V1', 'V2']);
      expect(s.named('V2').deathCause, DeathCause.devoreParLesLoups);

      toNextNight(s, 'Lg');
      expect(s.wolfPackIntact, isFalse);
      expect(s.phaseQueue, isNot(contains(GamePhase.nightGrandMechantLoup)));
    });

    test('la Sorcière n\'est plus appelée une fois ses deux potions bues', () {
      final s = startedGame(engine, [
        ('Sor', RoleId.sorciere),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, useVie: true, poisonTargetId: s.idOf('Lg2'));
      engine.finishNight(s);
      toNextNight(s, 'V2');
      expect(s.phaseQueue, isNot(contains(GamePhase.nightSorciere)));
    });

    test('Sorcière dévorée : sautée si le réglage l\'interdit, notée « sautée »',
        () {
      final s = startedGame(
        engine,
        [
          ('Sor', RoleId.sorciere),
          ('Lg', RoleId.loupGarou),
          ('V1', RoleId.simpleVillageois),
          ('V2', RoleId.simpleVillageois),
          ('V3', RoleId.simpleVillageois),
        ],
        settings: settingsWith(
            {SettingId.allowWitchToPlayIfWerewolfDeathCause: false}),
      );
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Sor'));
      engine.advance(s); // « rendors-toi » des loups
      expect(s.phase, GamePhase.nightGoBackToSleep,
          reason: 'La Sorcière est sautée');
      final sorciereStep =
          s.rounds.last.steps.firstWhere((st) => st.phase == GamePhase.nightSorciere);
      expect(sorciereStep.status, StepStatus.skipped);
      engine.advance(s);
      expect(s.phase, GamePhase.dayReveal);
      expect(s.deadNames, ['Sor']);
    });
  });

  group('Voleur', () {
    List<Seat> seats() => [
          ('Vol', RoleId.voleur),
          ('Lg', RoleId.loupGarou),
          ('V1', RoleId.simpleVillageois),
          ('V2', RoleId.simpleVillageois),
          ('V3', RoleId.simpleVillageois),
        ];

    test('garde sa carte : rien ne change', () {
      final s = startedGame(engine, seats(),
          tableCards: [RoleId.voyante, RoleId.simpleVillageois]);
      engine.skipTo(s, GamePhase.nightVoleur);
      final queue = [...s.phaseQueue];
      engine.resolveVoleur(s, null);
      expect(s.named('Vol').role, RoleId.voleur);
      expect(s.voleurTableCards, [RoleId.voyante, RoleId.simpleVillageois]);
      expect(s.phaseQueue, queue);
    });

    test('prend la Voyante sur la table : elle joue dès cette nuit', () {
      final s = startedGame(engine, seats(),
          tableCards: [RoleId.voyante, RoleId.simpleVillageois]);
      expect(s.phaseQueue, isNot(contains(GamePhase.nightVoyante)));
      engine.skipTo(s, GamePhase.nightVoleur);
      engine.resolveVoleur(s, RoleId.voyante);

      expect(s.named('Vol').role, RoleId.voyante);
      expect(s.voleurTableCards, [RoleId.voleur, RoleId.simpleVillageois]);
      expect(s.phase, GamePhase.nightGoBackToSleep);
      engine.advance(s);
      expect(s.phase, GamePhase.nightVoyante);
      // Et le résumé live annonce bien la Voyante.
      expect(s.rounds.last.steps.map((st) => st.phase),
          contains(GamePhase.nightVoyante));
    });

    test('prend un Loup-Garou alors qu\'aucun joueur n\'en avait : la meute se '
        'réveille', () {
      final s = startedGame(engine, [
        ('Vol', RoleId.voleur),
        ('V1', RoleId.simpleVillageois),
        ('V2', RoleId.simpleVillageois),
        ('V3', RoleId.simpleVillageois),
        ('V4', RoleId.simpleVillageois),
      ], tableCards: [
        RoleId.loupGarou,
        RoleId.simpleVillageois,
      ]);
      expect(s.phaseQueue, isNot(contains(GamePhase.nightLoups)));
      engine.skipTo(s, GamePhase.nightVoleur);
      engine.resolveVoleur(s, RoleId.loupGarou);
      engine.advance(s);
      expect(s.phase, GamePhase.nightLoups);
    });
  });

  group('Loups et protections', () {
    List<Seat> seats() => [
          ('Lg', RoleId.loupGarou),
          ('Lg2', RoleId.loupGarou),
          ('Sal', RoleId.salvateur),
          for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
        ];

    test('la victime des loups meurt au matin', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('V6'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      expect(s.named('V1').alive, isTrue, reason: 'Pas avant le matin');
      engine.finishNight(s);

      expect(s.phase, GamePhase.dayReveal);
      expect(s.namesOf(s.deathsThisWave), ['V1']);
      final v1 = s.named('V1');
      expect(v1.deathCause, DeathCause.devoreParLesLoups);
      expect(v1.deathAtNight, 1);
      expect(v1.deathAtDay, isNull);
    });

    test('le Salvateur sauve la victime qu\'il protège', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      expect(s.deathsThisWave, isEmpty);
    });

    test('le Salvateur ne protège pas la même personne deux nuits de suite',
        () {
      final s = startedGame(engine, seats());
      expect(s.salvateurCanProtect(s.idOf('V1')), isTrue);
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V2'));
      engine.finishNight(s);
      toNextNight(s, 'V3');

      expect(s.salvateurCanProtect(s.idOf('V1')), isFalse);
      expect(s.salvateurCanProtect(s.idOf('Sal')), isTrue);
      engine.skipTo(s, GamePhase.nightSalvateur);
      engine.resolveSalvateur(s, s.idOf('Sal'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V4'));
      engine.finishNight(s);
      toNextNight(s, 'V5');
      expect(s.salvateurCanProtect(s.idOf('V1')), isTrue,
          reason: 'Possible à nouveau après une nuit');
      expect(s.salvateurCanProtect(s.idOf('Sal')), isFalse);
    });

    test('Loup Blanc : il élimine un autre loup, la nuit paire', () {
      final s = startedGame(engine, [
        ('Lb', RoleId.loupBlanc),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= 7; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      toNextNight(s, 'V2');
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      expect(s.phase, GamePhase.nightLoupBlanc);
      expect(s.aliveWolves.map((w) => w.name), ['Lg', 'Lg2'],
          reason: 'Ses cibles possibles : les autres loups');
      engine.resolveLoupBlanc(s, s.idOf('Lg'));
      engine.finishNight(s);

      expect(s.namesOf(s.deathsThisWave), ['V3', 'Lg']);
      expect(s.named('Lg').deathCause, DeathCause.tueParLoupBlanc);
    });
  });

  group('Sorcière', () {
    List<Seat> seats() => [
          ('Sor', RoleId.sorciere),
          ('Lg', RoleId.loupGarou),
          ('Lg2', RoleId.loupGarou),
          for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
        ];

    test('la potion de vie sauve la victime, une seule fois', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightSorciere);
      expect(s.finalNightVictimId, s.idOf('V1'), reason: 'Elle voit V1');
      engine.resolveSorciere(s, useVie: true);
      engine.finishNight(s);
      expect(s.deathsThisWave, isEmpty);
      expect(s.sorciereVieUsed, isTrue);

      toNextNight(s, 'V2');
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, useVie: true); // déjà bue : sans effet
      engine.finishNight(s);
      expect(s.namesOf(s.deathsThisWave), ['V3']);
    });

    test('la potion de mort tue sa cible au matin', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, poisonTargetId: s.idOf('Lg'));
      engine.finishNight(s);
      expect(s.namesOf(s.deathsThisWave), ['V1', 'Lg']);
      expect(s.named('Lg').deathCause, DeathCause.potionDeMort);
      expect(s.sorciereMortUsed, isTrue);
    });
  });

  group("L'Ancien", () {
    List<Seat> seats() => [
          ('Anc', RoleId.ancien),
          ('Lg', RoleId.loupGarou),
          ('Sor', RoleId.sorciere),
          ('Voy', RoleId.voyante),
          for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
        ];

    test('survit en silence à la première attaque des loups, pas à la seconde',
        () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Anc'));
      engine.finishNight(s);
      expect(s.named('Anc').alive, isTrue);
      expect(s.deathsThisWave, isEmpty, reason: 'Aucune mort annoncée');
      expect(s.ancienExtraLifeUsed, isTrue);

      toNextNight(s, 'V1');
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Anc'));
      engine.finishNight(s);
      expect(s.named('Anc').deathCause, DeathCause.devoreParLesLoups);
    });

    test('la potion de mort le tue même avec sa vie en réserve', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, poisonTargetId: s.idOf('Anc'));
      engine.finishNight(s);
      expect(s.named('Anc').deathCause, DeathCause.potionDeMort);
      expect(s.ancienExtraLifeUsed, isFalse);
    });
  });

  group('Infect Père des Loups', () {
    GameState voyanteInfected({required bool keepsPower}) {
      final s = startedGame(
        engine,
        [
          ('Ipl', RoleId.infectPereDesLoups),
          ('Lg', RoleId.loupGarou),
          ('Voy', RoleId.voyante),
          for (var i = 1; i <= 7; i++) ('V$i', RoleId.simpleVillageois),
        ],
        settings: settingsWith({SettingId.infectedKeepsPower: keepsPower}),
      );
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Voy'));
      engine.resolveInfectPereDesLoups(s, true);
      expect(s.named('Voy').camp, Camp.village,
          reason: 'Mutation au matin seulement');
      engine.finishNight(s);
      expect(s.deathsThisWave, isEmpty, reason: 'Infectée, pas dévorée');
      expect(s.named('Voy').camp, Camp.loups);
      expect(s.infectPereDesLoupsUsed, isTrue);
      toNextNight(s, 'V2');
      expect(s.phaseQueue, isNot(contains(GamePhase.nightInfectPereDesLoups)));
      return s;
    }

    test('l\'infectée garde son pouvoir (par défaut) et l\'apprend en secret',
        () {
      final s = voyanteInfected(keepsPower: true);
      final voy = s.named('Voy');
      expect(voy.role, RoleId.voyante);
      expect(voy.infected, isTrue);
      // Prévenue juste avant son premier réveil avec la meute, et toujours
      // Voyante.
      expect(s.phaseQueue, [
        GamePhase.nightIntro,
        GamePhase.nightVoyante,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightInfectedReveal,
        GamePhase.nightGoBackToSleep,
        GamePhase.nightLoups,
        GamePhase.nightGoBackToSleep,
      ]);
      engine.skipTo(s, GamePhase.nightInfectedReveal);
      engine.confirmInfectedReveal(s);
      expect(s.infectedRevealPendingId, isNull);
      // Les loups ne peuvent plus la viser quand ils ne s'entre-dévorent pas.
      expect(s.isWolfPackMember(voy), isTrue);
    });

    test('réglage désactivé : elle devient simple Loup-Garou', () {
      final s = voyanteInfected(keepsPower: false);
      final voy = s.named('Voy');
      expect(voy.role, RoleId.loupGarou);
      expect(voy.formerRole, RoleId.voyante);
      expect(s.phaseQueue, isNot(contains(GamePhase.nightVoyante)));
      expect(s.phaseQueue, contains(GamePhase.nightInfectedReveal));
    });
  });

  group('Renard', () {
    List<Seat> seats() => [
          ('V1', RoleId.simpleVillageois),
          ('Ren', RoleId.renard),
          ('V2', RoleId.simpleVillageois),
          ('V3', RoleId.simpleVillageois),
          ('Lb', RoleId.loupBlanc),
          ('Lg', RoleId.loupGarou),
          ('V4', RoleId.simpleVillageois),
        ];

    test('le trio est le joueur désigné et ses deux voisins, en boucle', () {
      final s = startedGame(engine, seats());
      expect(s.namesOf(s.renardTrioAround(s.idOf('V1'))), ['V4', 'V1', 'Ren']);
      expect(s.namesOf(s.renardTrioAround(s.idOf('V4'))), ['Lg', 'V4', 'V1']);
    });

    test('flaire un loup (le Loup Blanc compris) : garde son pouvoir', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightRenard);
      engine.resolveRenardCenter(s, s.idOf('V3')); // V2, V3, Lb
      expect(s.renardFoundWolfLastQuery, isTrue);
      expect(s.renardPowerLost, isFalse);
    });

    test('ne flaire aucun loup : perd définitivement son pouvoir', () {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V4'));
      engine.skipTo(s, GamePhase.nightRenard);
      engine.resolveRenardCenter(s, s.idOf('Ren')); // V1, Ren, V2
      expect(s.renardPowerLost, isTrue);
      engine.finishNight(s);
      toNextNight(s, 'V2');
      expect(s.phaseQueue, isNot(contains(GamePhase.nightRenard)));
    });
  });

  group("Montreur d'Ours", () {
    test('son ours grogne si un loup — Loup Blanc compris — est à côté de lui',
        () {
      final s = riggedGame(engine, [
        ('Lb', RoleId.loupBlanc),
        ('Ours', RoleId.montreurDours),
        ('V1', RoleId.simpleVillageois),
        ('V2', RoleId.simpleVillageois),
        ('Lg', RoleId.loupGarou),
        ('V3', RoleId.simpleVillageois),
      ]);
      expect(s.montreurDoursGrowls, isTrue);
      s.named('Lb').alive = false; // nouveaux voisins : V3 (en boucle) et V1
      expect(s.montreurDoursGrowls, isFalse);
      s.named('V3').alive = false; // voisin de gauche : Lg
      expect(s.montreurDoursGrowls, isTrue);
    });
  });

  group("Enfant Sauvage", () {
    List<Seat> seats() => [
          ('Enf', RoleId.enfantSauvage),
          ('Modele', RoleId.simpleVillageois),
          ('Lg', RoleId.loupGarou),
          ('Lg2', RoleId.loupGarou),
          for (var i = 1; i <= 6; i++) ('V$i', RoleId.simpleVillageois),
        ];

    GameState modelDiesFirstNight(GameSettings settings) {
      final s = startedGame(engine, seats(), settings: settings);
      engine.skipTo(s, GamePhase.nightEnfantSauvage);
      engine.resolveEnfantSauvageMentor(s, s.idOf('Modele'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('Modele'));
      engine.finishNight(s);
      return s;
    }

    test('son modèle mort, il devient Loup-Garou, annoncé à tous', () {
      final s = modelDiesFirstNight(
          settingsWith({SettingId.enfantSauvagePublicReveal: true}));
      final enfant = s.named('Enf');
      expect(enfant.role, RoleId.loupGarou);
      expect(enfant.formerRole, RoleId.enfantSauvage);
      expect(engine.upcomingStep(s), UpcomingStep.followUp);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.enfantsauvageReveal);
      engine.confirmEnfantSauvageReveal(s);
      expect(s.phase, GamePhase.mayorElectionExplain);
    });

    test('mutation secrète : il l\'apprend seul, la nuit suivante', () {
      final s = modelDiesFirstNight(
          settingsWith({SettingId.enfantSauvagePublicReveal: false}));
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.nightDeaths),
          UpcomingStep.dayStarts);
      toNextNight(s, 'V1');
      expect(s.phaseQueue.take(2), [
        GamePhase.nightIntro,
        GamePhase.nightEnfantSauvageMutation,
      ]);
      engine.skipTo(s, GamePhase.nightEnfantSauvageMutation);
      engine.confirmEnfantSauvageNightMutation(s);
      expect(s.enfantSauvageNightMutationId, isNull);
    });
  });
}
