import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

import '../support/game_fixtures.dart';

/// Votes, maire, et suites d'une mort (Chasseur, succession, Servante...).
void main() {
  late GameEngine engine;
  setUp(() => engine = GameEngine(random: Random(7)));

  /// Nuit 1 où les loups dévorent [victim], puis réveil du village.
  GameState dayOne(List<Seat> seats,
      {String victim = 'V1', GameSettings? settings}) {
    final s = startedGame(engine, seats, settings: settings);
    engine.skipTo(s, GamePhase.nightLoups);
    engine.setLoupsVictim(s, s.idOf(victim));
    engine.finishNight(s);
    return s;
  }

  /// Bulletins secrets : votant → cible, par prénoms.
  Map<String, String> ballots(GameState s, Map<String, String> byName) => {
        for (final e in byName.entries) s.idOf(e.key): s.idOf(e.value),
      };

  List<Seat> village({int villagers = 6}) => [
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        for (var i = 1; i <= villagers; i++) ('V$i', RoleId.simpleVillageois),
      ];

  group('Dépouillement', () {
    test('la majorité l\'emporte ; une égalité désigne les ex aequo', () {
      final s = dayOne(village());
      engine.dayToVote(s, mayor: s.idOf('V6'));
      final majority = engine.tallyVotes(
          s, ballots(s, {'Lg': 'V2', 'Lg2': 'V2', 'V2': 'Lg', 'V3': 'V2'}));
      expect(majority.winner, s.idOf('V2'));
      expect(majority.isTie, isFalse);

      final tie = engine.tallyVotes(
          s, ballots(s, {'Lg': 'V2', 'Lg2': 'V3', 'V2': 'Lg', 'V3': 'V4'}));
      expect(tie.winner, isNull);
      expect(tie.isTie, isTrue);
      expect(s.namesOf(tie.tiedCandidates).toSet(), {'V2', 'V3', 'Lg', 'V4'});
    });

    test('la voix du maire compte double', () {
      final s = dayOne(village());
      engine.dayToVote(s, mayor: s.idOf('V6'));
      final tally = engine.tallyVotes(
          s, ballots(s, {'V6': 'Lg', 'Lg': 'V2', 'V2': 'V6'}));
      expect(tally.winner, s.idOf('Lg'));
    });
  });

  group('Maire', () {
    test('élu : il porte l\'écharpe et sa voix compte double', () {
      final s = dayOne(village());
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.mayorElectionExplain);
      engine.confirmMayorElectionExplain(s, VoteMode.secret);
      engine.resolveMayorElection(s, s.idOf('V2'));
      expect(s.phase, GamePhase.mayorReveal);
      expect(s.mayorId, s.idOf('V2'));
      expect(s.named('V2').isMayor, isTrue);
      expect(s.players.where((p) => p.isMayor), hasLength(1));
    });

    test('mort au vote : il désigne son successeur', () {
      final s = dayOne(village());
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('V2'));
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.voteDeaths),
          UpcomingStep.followUp);
      engine.confirmVoteResult(s);

      expect(s.phase, GamePhase.successionMaire);
      expect(s.mayorSuccessionNeededFor, s.idOf('V2'));
      engine.resolveMayorSuccession(s, s.idOf('V3'));
      expect(s.mayorId, s.idOf('V3'));
      expect(s.named('V3').isMayor, isTrue);
      expect(s.named('V2').isMayor, isFalse);
      expect(s.phase, GamePhase.nightIntro);
    });

    test('dévoré la nuit : la succession a lieu au réveil, sans réélection',
        () {
      final s = dayOne(village());
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('V3'));
      engine.confirmVoteResult(s);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V2'));
      engine.finishNight(s);

      expect(s.phaseQueue, isNot(contains(GamePhase.mayorElection)));
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.successionMaire);
      engine.resolveMayorSuccession(s, s.idOf('V4'));
      expect(s.phase, GamePhase.debate);
      expect(s.named('V4').isMayor, isTrue);
    });
  });

  group('Corbeau', () {
    List<Seat> seats() => [
          ('Cor', RoleId.corbeau),
          ...village(),
        ];

    GameState cursed(String target) {
      final s = startedGame(engine, seats());
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightCorbeau);
      engine.resolveCorbeau(s, s.idOf(target));
      engine.finishNight(s);
      return s;
    }

    test('sa cible part avec deux voix contre elle au vote du village', () {
      final s = cursed('V5');
      engine.dayToVote(s, mayor: s.idOf('Cor'));
      final tally = engine.tallyVotes(s,
          ballots(s, {'Lg': 'V2', 'V3': 'V2', 'V2': 'V5', 'Cor': 'V4'}));
      expect(tally.winner, s.idOf('V5'), reason: '1 + 2 contre 2');
    });

    test('la malédiction ne vaut pas pour l\'élection du maire', () {
      final s = cursed('V5');
      engine.confirmDayReveal(s);
      engine.confirmMayorElectionExplain(s, VoteMode.secret);
      final tally = engine.tallyVotes(
          s, ballots(s, {'Lg': 'V2', 'V3': 'V2', 'V2': 'V5'}));
      expect(tally.winner, s.idOf('V2'));
    });

    test('ne compte pas pour un joueur mort entre-temps', () {
      final s = cursed('V1'); // dévoré la même nuit
      engine.dayToVote(s, mayor: s.idOf('Cor'));
      final tally =
          engine.tallyVotes(s, ballots(s, {'Lg': 'V2', 'V3': 'V4', 'V2': 'V4'}));
      expect(tally.winner, s.idOf('V4'));
    });

    test('au second tour, ne compte que pour un ex aequo', () {
      final s = cursed('V5');
      engine.dayToVote(s, mayor: s.idOf('Cor'));
      final runoff = {s.idOf('V2'), s.idOf('V3')};
      final tally = engine.tallyVotes(s, ballots(s, {'Lg': 'V2', 'V4': 'V3'}),
          candidates: runoff);
      expect(tally.isTie, isTrue,
          reason: 'V5 n\'est pas candidat : ses deux voix ne comptent pas');
      expect(tally.tiedCandidates.toSet(), runoff);
    });

    test('ne vaut que pour le vote du jour', () {
      final s = cursed('V5');
      engine.dayToVote(s, mayor: s.idOf('Cor'));
      engine.resolveVillageVote(s, s.idOf('V2'));
      expect(s.corbeauCursedId, isNull);
    });
  });

  group('Juge Bègue', () {
    test('fait rejouer le vote le jour même ; chaque résultat montre son mort',
        () {
      final s = dayOne([('Juge', RoleId.jugeBegue), ...village()]);
      engine.confirmDayReveal(s);
      engine.confirmMayorElectionExplain(s, VoteMode.secret);
      engine.resolveMayorElection(s, s.idOf('Juge'));
      engine.confirmMayorReveal(s);
      engine.confirmDebate(s, VoteMode.collective);
      expect(s.phase, GamePhase.jugeBegueDecision);
      engine.resolveJugeBegueDecision(s, true);

      engine.resolveVillageVote(s, s.idOf('V2'));
      expect(s.namesOf(s.deathsThisWave), ['V2']);
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.voteDeaths),
          UpcomingStep.revote);
      engine.confirmVoteResult(s);

      expect(s.phase, GamePhase.villageVote);
      expect(s.voteMode, VoteMode.collective, reason: 'Même mode de vote');
      engine.resolveVillageVote(s, s.idOf('Lg'));
      expect(s.namesOf(s.deathsThisWave), ['Lg'],
          reason: 'V2 a déjà été annoncé au premier vote');
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.voteDeaths),
          UpcomingStep.nightFalls);
      engine.confirmVoteResult(s);
      expect(s.phase, GamePhase.nightIntro);
      expect(s.jugeBegueUsed, isTrue);
      expect(engine.buildDayQueue(s),
          isNot(contains(GamePhase.jugeBegueDecision)));
    });
  });

  group('Idiot du Village', () {
    test('survit au vote, perd son droit de vote, reste éligible', () {
      final s = dayOne([('Idiot', RoleId.idiotDuVillage), ...village()]);
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('Idiot'));

      expect(s.named('Idiot').alive, isTrue);
      expect(s.deathsThisWave, isEmpty);
      engine.confirmVoteResult(s);
      expect(s.phase, GamePhase.idiotduvillageCivicRightLoss);
      engine.confirmIdiotDuVillageReveal(s);
      expect(s.phase, GamePhase.nightIntro);
      expect(s.eligibleVoters.map((p) => p.name), isNot(contains('Idiot')));
      expect(s.alivePlayers.map((p) => p.name), contains('Idiot'));
    });
  });

  group('Bouc Émissaire', () {
    List<Seat> seats() => [
          ('Bouc', RoleId.boucEmissaire),
          ('Voy', RoleId.voyante),
          ...village(),
        ];

    /// Jour 1 : le vote finit à égalité, le Bouc meurt à la place.
    GameState scapegoated() {
      final s = dayOne(seats());
      engine.dayToVote(s, mayor: s.idOf('V2'));
      expect(engine.villageVoteTieRule(s), VoteTieRule.boucEmissaire,
          reason: 'Il passe avant le maire');
      engine.resolveVillageVoteTie(s);
      return s;
    }

    test('égalité : il est éliminé à la place des ex aequo', () {
      final s = scapegoated();
      expect(s.namesOf(s.deathsThisWave), ['Bouc']);
      expect(s.named('Bouc').deathCause, DeathCause.vote);
      expect(s.lastVoteTie, VoteTieRule.boucEmissaire);
      engine.confirmVoteResult(s);
      expect(s.phase, GamePhase.boucEmissaire);
    });

    test('il désigne les seuls votants du lendemain, et seulement eux', () {
      final s = scapegoated();
      engine.confirmVoteResult(s);
      engine.resolveBoucEmissaireChoice(
          s, {s.idOf('V2'), s.idOf('V3'), s.idOf('Voy')});
      expect(s.phase, GamePhase.nightIntro);
      expect(s.phaseQueue, contains(GamePhase.nightVoyante),
          reason: 'Il ne touche plus aux nuits (ancienne règle maison)');

      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      engine.finishNight(s);
      engine.dayToVote(s);
      expect(s.voteRestrictedByBouc, isTrue);
      expect(s.eligibleVoters.map((p) => p.name), ['Voy', 'V2'],
          reason: 'V3 est mort cette nuit');
      engine.resolveVillageVote(s, s.idOf('V4'));
      engine.confirmVoteResult(s);

      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V5'));
      engine.finishNight(s);
      engine.dayToVote(s);
      expect(s.voteRestrictedByBouc, isFalse, reason: 'Le lendemain seulement');
    });

    test('ses votants tous morts dans la nuit : tout le monde vote', () {
      final s = scapegoated();
      engine.confirmVoteResult(s);
      engine.resolveBoucEmissaireChoice(s, {s.idOf('V3')});
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V3'));
      engine.finishNight(s);
      engine.dayToVote(s);
      expect(s.eligibleVoters, hasLength(s.alivePlayers.length));
    });

    test('éliminé par un vote ordinaire : il meurt sans pouvoir', () {
      final s = dayOne(seats());
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('Bouc'));
      engine.confirmVoteResult(s);
      expect(s.phase, GamePhase.nightIntro);
    });
  });

  group('Égalité au vote du village', () {
    /// Jour 1 après l'élection du maire, avec les réglages [values].
    GameState voteDay([Map<SettingId, bool> values = const {}]) {
      final s = dayOne(village(), settings: settingsWith(values));
      engine.dayToVote(s, mayor: s.idOf('V2'));
      return s;
    }

    void killMayor(GameState s) => s.named('V2')
      ..alive = false
      ..deathCause = DeathCause.vengeanceDuChasseur
      ..isMayor = false;

    test('le maire tranche parmi les ex aequo (par défaut)', () {
      final s = voteDay();
      expect(engine.villageVoteTieRule(s), VoteTieRule.mayorDecides);
      engine.resolveVillageVoteTie(s, mayorChoiceId: s.idOf('Lg'));
      expect(s.namesOf(s.deathsThisWave), ['Lg']);
      expect(s.lastVoteTie, VoteTieRule.mayorDecides);
    });

    test('sans maire vivant : second tour (par défaut)', () {
      final s = voteDay();
      killMayor(s);
      expect(engine.villageVoteTieRule(s), VoteTieRule.runoff);
    });

    test('sans maire vivant, réglage « personne » : nul n\'est éliminé', () {
      final s = voteDay({SettingId.tieMeansNoElimination: true});
      killMayor(s);
      expect(engine.villageVoteTieRule(s), VoteTieRule.nobodyEliminated);
      engine.resolveVillageVoteTie(s);
      expect(s.deathsThisWave, isEmpty);
      expect(s.lastVoteTie, VoteTieRule.nobodyEliminated);
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.voteDeaths),
          UpcomingStep.nightFalls);
    });

    test('maire désactivé : la règle suivante s\'applique', () {
      expect(
          engine.villageVoteTieRule(
              voteDay({SettingId.mayorBreaksTies: false})),
          VoteTieRule.runoff);
    });
  });

  group('Servante Dévouée', () {
    test('peut reprendre le rôle du joueur éliminé par le vote', () {
      final s = dayOne([
        ('Serv', RoleId.servanteDevouee),
        ('Chas', RoleId.chasseur),
        ...village(),
      ]);
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('V3'));
      engine.confirmVoteResult(s);
      expect(s.phase, GamePhase.servanteDevouee);
      expect(s.servanteDevoueeOfferId, s.idOf('V3'));
      engine.resolveServanteDevouee(s, false);
      expect(s.named('Serv').role, RoleId.servanteDevouee);

      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V4'));
      engine.finishNight(s);
      engine.dayToVote(s);
      engine.resolveVillageVote(s, s.idOf('Chas'));
      engine.confirmVoteResult(s);
      // Le Chasseur tire d'abord, puis la Servante choisit.
      expect(s.phase, GamePhase.chasseurRevange);
      engine.resolveChasseurRevenge(s, s.idOf('Lg'));
      expect(s.phase, GamePhase.servanteDevouee);
      engine.resolveServanteDevouee(s, true);
      expect(s.named('Serv').role, RoleId.chasseur);
    });
  });

  group("Pendaison de l'Ancien", () {
    test('tous les villageois à pouvoir perdent leur don, en secret', () {
      final s = dayOne([
        ('Anc', RoleId.ancien),
        ('Voy', RoleId.voyante),
        ('Sor', RoleId.sorciere),
        ('Serv', RoleId.servanteDevouee),
        ...village(),
      ]);
      engine.dayToVote(s, mayor: s.idOf('V2'));
      engine.resolveVillageVote(s, s.idOf('Anc'));

      expect({
        for (final e in s.powerLossThisWave) s.byId(e.playerId).name: e.previousRole
      }, {
        'Voy': RoleId.voyante,
        'Sor': RoleId.sorciere,
        'Serv': RoleId.servanteDevouee,
      });
      expect(s.named('Voy').role, RoleId.simpleVillageois);
      expect(s.named('Lg').role, RoleId.loupGarou, reason: 'Les loups gardent');
      // La Servante a perdu son pouvoir : on ne lui propose rien.
      expect(s.servanteDevoueeOfferId, isNull);

      engine.confirmVoteResult(s);
      expect(s.phase, GamePhase.villagePowerLoss);
      engine.confirmPowerLossReveal(s);
      expect(s.phase, GamePhase.nightIntro);
      expect(s.phaseQueue, isNot(contains(GamePhase.nightVoyante)));
    });
  });

  group('Chasseur', () {
    test('mort la nuit, il tire au réveil', () {
      final s = dayOne([('Chas', RoleId.chasseur), ...village()],
          victim: 'Chas');
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.nightDeaths),
          UpcomingStep.followUp);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.chasseurRevange);
      engine.resolveChasseurRevenge(s, s.idOf('Lg'));
      expect(s.named('Lg').deathCause, DeathCause.vengeanceDuChasseur);
      expect(s.phase, GamePhase.mayorElectionExplain);
    });

    test('tire même quand sa mort semble décider de la partie', () {
      // 2 loups contre lui et un villageois : dévoré, il laisserait les
      // loups majoritaires. Il tire avant que la partie ne soit jugée.
      final s = dayOne([
        ('Chas', RoleId.chasseur),
        ('Lg', RoleId.loupGarou),
        ('Lg2', RoleId.loupGarou),
        ('V1', RoleId.simpleVillageois),
      ], victim: 'Chas');
      expect(engine.checkWinCondition(s)?.winner, Camp.loups);
      expect(engine.upcomingStep(s, origin: FollowUpOrigin.nightDeaths),
          UpcomingStep.followUp);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.chasseurRevange);

      engine.resolveChasseurRevenge(s, s.idOf('Lg'));
      expect(engine.checkWinCondition(s), isNull, reason: '1 loup contre 1');
      expect(s.phase, GamePhase.mayorElectionExplain);
    });

    test('empoisonné : ne tire pas si le réglage l\'interdit', () {
      final s = startedGame(
        engine,
        [('Chas', RoleId.chasseur), ('Sor', RoleId.sorciere), ...village()],
        settings: settingsWith(
            {SettingId.allowHunterToShootAfterWitchDeathCause: false}),
      );
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.skipTo(s, GamePhase.nightSorciere);
      engine.resolveSorciere(s, poisonTargetId: s.idOf('Chas'));
      engine.finishNight(s);
      expect(s.chasseurRevengeTargetId, isNull);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.mayorElectionExplain);
    });
  });

  group('Amoureux', () {
    test('quand l\'un meurt, l\'autre meurt de chagrin, aussitôt', () {
      final s = startedGame(engine, [('Cup', RoleId.cupidon), ...village()]);
      engine.skipTo(s, GamePhase.nightCupidon);
      engine.resolveCupidon(s, s.idOf('V1'), s.idOf('Lg'));
      expect(s.named('V1').loverId, s.idOf('Lg'));
      engine.skipTo(s, GamePhase.nightLoversReveal);
      engine.confirmLoversReveal(s);
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);

      expect(s.namesOf(s.deathsThisWave), ['V1', 'Lg']);
      expect(s.named('Lg').deathCause, DeathCause.chagrinDAmourCupidon);
    });

    test('le Chasseur qui meurt de chagrin tire quand même', () {
      final s = startedGame(engine, [
        ('Cup', RoleId.cupidon),
        ('Chas', RoleId.chasseur),
        ...village(),
      ]);
      engine.skipTo(s, GamePhase.nightCupidon);
      engine.resolveCupidon(s, s.idOf('V1'), s.idOf('Chas'));
      engine.skipTo(s, GamePhase.nightLoups);
      engine.setLoupsVictim(s, s.idOf('V1'));
      engine.finishNight(s);
      engine.confirmDayReveal(s);
      expect(s.phase, GamePhase.chasseurRevange);
    });
  });
}
