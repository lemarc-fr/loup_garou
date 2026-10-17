import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/player.dart';
import 'package:thiercelieux/models/role.dart';

import 'game_decisions.dart';
import 'game_fixtures.dart';

/// Une partie complète à 18 joueurs, écrite d'avance, qui fait jouer presque
/// tous les rôles et leurs interactions : Amoureux de camps opposés,
/// Salvateur, potions, Ancien qui survit puis est pendu (perte des pouvoirs),
/// Idiot gracié, malédiction du Corbeau, Juge Bègue, mutation publique de
/// l'Enfant Sauvage, Servante Dévouée, Bouc Émissaire, Loup Blanc, Grand
/// Méchant Loup, infection, flair du Renard, ours du Montreur, et quatre
/// successions de maire, égalité réglée par le Bouc Émissaire, infectée qui
/// garde sa carte. Le village gagne au jour 7.
///
/// Partagée par le test du moteur (test/services/full_game_scenario_test.dart)
/// et celui de l'interface (test/widgets/full_game_ui_test.dart) : les deux
/// doivent aboutir exactement au même état.
abstract final class VillageScenario {
  /// Ordre des places : il compte pour le Renard et le Montreur d'Ours.
  static const seats = <Seat>[
    ('Alice', RoleId.loupGarou),
    ('Bruno', RoleId.voyante),
    ('Chloé', RoleId.sorciere),
    ('David', RoleId.chasseur),
    ('Emma', RoleId.cupidon),
    ('Félix', RoleId.salvateur),
    ('Gaëlle', RoleId.grandMechantLoup),
    ('Hugo', RoleId.ancien),
    ('Inès', RoleId.idiotDuVillage),
    ('Jules', RoleId.enfantSauvage),
    ('Kim', RoleId.corbeau),
    ('Léo', RoleId.renard),
    ('Manon', RoleId.infectPereDesLoups),
    ('Nina', RoleId.servanteDevouee),
    ('Oscar', RoleId.jugeBegue),
    ('Paul', RoleId.montreurDours),
    ('Quentin', RoleId.loupBlanc),
    ('Rose', RoleId.boucEmissaire),
  ];

  static List<String> get names => [for (final s in seats) s.$1];
  static List<RoleId> get roles => [for (final s in seats) s.$2];

  /// File attendue au début de chaque nuit.
  static const nightQueues = <int, List<GamePhase>>{
    1: [
      GamePhase.nightIntro,
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
      GamePhase.nightGrandMechantLoup,
      GamePhase.nightInfectPereDesLoups,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightRenard,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightCorbeau,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightSorciere,
      GamePhase.nightGoBackToSleep,
    ],
    // Nuit paire : le Loup Blanc se réveille ; le Corbeau est mort.
    2: [
      GamePhase.nightIntro,
      GamePhase.nightEnfantSauvageCheck,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightSalvateur,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightVoyante,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightLoups,
      GamePhase.nightLoupBlanc,
      GamePhase.nightGrandMechantLoup,
      GamePhase.nightInfectPereDesLoups,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightRenard,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightSorciere,
      GamePhase.nightGoBackToSleep,
    ],
    // Nina est Voyante grâce à la Servante ; le Renard a perdu son flair,
    // la Sorcière ses deux potions.
    3: [
      GamePhase.nightIntro,
      GamePhase.nightVoyante,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightLoups,
      GamePhase.nightInfectPereDesLoups,
      GamePhase.nightGoBackToSleep,
    ],
    // Emma, infectée la nuit 3, l'apprend avant de rejoindre la meute.
    4: [
      GamePhase.nightIntro,
      GamePhase.nightVoyante,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightInfectedReveal,
      GamePhase.nightGoBackToSleep,
      GamePhase.nightLoups,
      GamePhase.nightGoBackToSleep,
    ],
    // Plus aucun pouvoir au village depuis la pendaison de l'Ancien.
    5: [GamePhase.nightIntro, GamePhase.nightLoups, GamePhase.nightGoBackToSleep],
    6: [GamePhase.nightIntro, GamePhase.nightLoups, GamePhase.nightGoBackToSleep],
    7: [GamePhase.nightIntro, GamePhase.nightLoups, GamePhase.nightGoBackToSleep],
  };

  /// Morts annoncées au lever de chaque jour, dans l'ordre.
  static const dawnDeaths = <int, List<String>>{
    1: ['Kim'],
    2: ['Paul', 'Alice', 'David', 'Gaëlle'],
    3: [],
    4: ['Oscar'],
    5: ['Nina'],
    6: ['Inès'],
    7: ['Chloé'],
  };

  /// Éliminés par le vote du village, jour par jour (deux votes le jour 2,
  /// rejoué à la demande du Juge Bègue). Inès, Idiot du Village, survit.
  static const votedOut = <int, List<String>>{
    1: [],
    2: ['Bruno', 'Rose'],
    3: ['Quentin'],
    4: ['Hugo'],
    5: ['Jules'],
    6: ['Manon'],
    7: ['Emma'],
  };

  static const expectedCauses = <String, DeathCause>{
    'Kim': DeathCause.devoreParLesLoups,
    'Paul': DeathCause.devoreParLesLoups,
    'Alice': DeathCause.tueParLoupBlanc,
    'David': DeathCause.chagrinDAmourCupidon,
    'Gaëlle': DeathCause.potionDeMort,
    'Félix': DeathCause.vengeanceDuChasseur,
    'Bruno': DeathCause.vote,
    'Rose': DeathCause.vote,
    'Quentin': DeathCause.vote,
    'Oscar': DeathCause.devoreParLesLoups,
    'Hugo': DeathCause.vote,
    'Nina': DeathCause.devoreParLesLoups,
    'Jules': DeathCause.vote,
    'Inès': DeathCause.devoreParLesLoups,
    'Manon': DeathCause.vote,
    'Chloé': DeathCause.devoreParLesLoups,
    'Emma': DeathCause.vote,
  };

  /// Vérifications faites avant chaque action, selon le moment de la partie.
  static void checkpoint(GameState s) {
    Player p(String name) => s.named(name);

    switch (s.phase) {
      case GamePhase.nightIntro:
        expect(s.phaseQueue, nightQueues[s.night],
            reason: 'File de la nuit ${s.night}');
      case GamePhase.nightSalvateur when s.night == 2:
        // Emma, protégée la veille, ne peut pas l'être deux nuits de suite.
        expect(s.salvateurCanProtect(p('Emma').id), isFalse);
        expect(s.salvateurCanProtect(p('Chloé').id), isTrue);
      case GamePhase.nightLoupBlanc:
        // Il ne peut viser qu'un autre loup.
        expect(LegalChoices.loupBlancTargets(s).map((w) => w.name),
            ['Alice', 'Gaëlle', 'Manon']);
      case GamePhase.dayReveal:
        expect(s.namesOf(s.deathsThisWave), dawnDeaths[s.day],
            reason: 'Morts de la nuit ${s.night}');
        _dawn(s);
      case GamePhase.mayorReveal:
        // Le Corbeau avait maudit Inès : ses deux voix ne comptent pas pour
        // l'élection du maire (sinon Inès l'emporterait, 8 contre 7).
        expect(s.byId(s.mayorId!).name, 'Félix');
        expect(p('Félix').isMayor, isTrue);
      case GamePhase.voteResult:
        final voted = votedOut[s.day]!;
        if (voted.isEmpty) {
          // Les deux voix du Corbeau désignent Inès, qui survit.
          expect(s.deathsThisWave, isEmpty);
          expect(s.idiotDuVillageRevealId, p('Inès').id);
        } else {
          // Jour 2 : le premier vote est rejoué à la demande du Juge, et le
          // second finit à égalité : le Bouc Émissaire meurt à leur place.
          final name = s.voteReplayPending ? voted.first : voted.last;
          expect(s.namesOf(s.deathsThisWave), [name]);
          expect(s.lastVoteTie,
              name == 'Rose' ? VoteTieRule.boucEmissaire : isNull);
        }
      case GamePhase.boucEmissaire:
        expect(s.boucEmissaireChoiceNeededId, p('Rose').id);
      case GamePhase.villageVote when s.day == 3:
        expect(s.voteRestrictedByBouc, isTrue);
        expect(s.eligibleVoters.map((v) => v.name),
            ['Chloé', 'Hugo', 'Léo', 'Nina', 'Oscar']);
      case GamePhase.nightInfectedReveal:
        expect(s.infectedRevealPendingId, p('Emma').id);
      case GamePhase.chasseurRevange:
        expect(s.chasseurRevengeTargetId, p('David').id);
        expect(s.day, 2);
      case GamePhase.successionMaire:
        // C'est bien le maire en place qui vient de mourir.
        final dead = s.byId(s.mayorSuccessionNeededFor!);
        expect(dead.id, s.mayorId);
        expect(dead.alive, isFalse);
        expect(dead.isMayor, isFalse);
      case GamePhase.enfantsauvageReveal:
        expect(p('Jules').role, RoleId.loupGarou);
        expect(p('Jules').formerRole, RoleId.enfantSauvage);
      case GamePhase.servanteDevouee:
        expect(s.servanteDevoueeOfferId, p('Bruno').id);
      case GamePhase.villagePowerLoss:
        expect(
            {for (final e in s.powerLossThisWave) s.byId(e.playerId).name: e.previousRole},
            {
              'Chloé': RoleId.sorciere,
              'Inès': RoleId.idiotDuVillage,
              'Léo': RoleId.renard,
              'Nina': RoleId.voyante,
            });
        expect(p('Nina').isMayor, isTrue, reason: 'Succession avant la perte');
      default:
        break;
    }
  }

  static void _dawn(GameState s) {
    Player p(String name) => s.named(name);
    switch (s.day) {
      case 1:
        expect(p('Bruno').alive, isTrue, reason: 'Sauvé par la Sorcière');
        expect(s.sorciereVieUsed, isTrue);
        // Paul, Montreur d'Ours, a le Loup Blanc (Quentin) pour voisin.
        expect(s.montreurDoursGrowls, isTrue);
        expect(s.corbeauCursedId, p('Inès').id);
      case 2:
        expect(p('Hugo').alive, isTrue, reason: "L'Ancien survit une fois");
        expect(s.ancienExtraLifeUsed, isTrue);
        expect(s.renardPowerLost, isTrue, reason: 'Aucun loup près d\'Emma');
        expect(s.wolfPackIntact, isFalse);
      case 3:
        // Infectée, elle rejoint la meute en gardant sa carte (réglage
        // par défaut).
        expect(p('Emma').infected, isTrue);
        expect(p('Emma').camp, Camp.loups);
        expect(p('Emma').role, RoleId.cupidon);
        expect(s.infectPereDesLoupsUsed, isTrue);
      case 4:
        expect(s.namesOf(s.disenfranchisedPlayerIds), ['Inès']);
      default:
        break;
    }
  }

  /// État final attendu.
  static void checkEnd(GameState s) {
    expect(s.phase, GamePhase.endGame);
    expect(s.night, 7);
    expect(s.day, 7);
    expect(s.result!.winner, Camp.village);
    expect(s.namesOf(s.result!.winningPlayerIds), ['Léo']);
    expect(s.aliveNames, ['Léo']);
    expect(s.byId(s.mayorId!).name, 'Léo');
    for (final entry in expectedCauses.entries) {
      expect(s.named(entry.key).deathCause, entry.value,
          reason: entry.key);
    }
    // Rôles en fin de partie : mutations, infection, Servante, perte des
    // pouvoirs.
    expect(s.named('Jules').role, RoleId.loupGarou);
    expect(s.named('Emma').role, RoleId.cupidon);
    expect(s.named('Emma').camp, Camp.loups);
    expect(s.named('Nina').role, RoleId.simpleVillageois);
    expect(s.named('Léo').role, RoleId.simpleVillageois);
    expect(s.named('Hugo').role, RoleId.ancien);
    expect(s.loversIds.map((id) => s.byId(id).name), ['David', 'Alice']);
  }
}

/// Les choix des joueurs pour [VillageScenario].
class VillageScenarioDecisions implements GameDecisions {
  String _id(GameState s, String name) => s.idOf(name);

  @override
  RoleId? voleur(GameState s) => throw StateError('Pas de Voleur');

  @override
  (String, String) cupidon(GameState s) =>
      (_id(s, 'David'), _id(s, 'Alice'));

  @override
  String enfantSauvageModel(GameState s) => _id(s, 'Bruno');

  @override
  String salvateur(GameState s) =>
      _id(s, s.night == 1 ? 'Emma' : 'Chloé');

  @override
  String voyante(GameState s) => _id(s, switch (s.night) {
        1 => 'Quentin',
        2 => 'Manon',
        _ => 'Emma',
      });

  @override
  String loups(GameState s) => _id(s, switch (s.night) {
        1 => 'Bruno',
        2 => 'Hugo',
        3 => 'Emma',
        4 => 'Oscar',
        5 => 'Nina',
        6 => 'Inès',
        _ => 'Chloé',
      });

  @override
  String? loupBlanc(GameState s) => _id(s, 'Alice');

  @override
  String? grandMechantLoup(GameState s) =>
      _id(s, s.night == 1 ? 'Kim' : 'Paul');

  @override
  bool infect(GameState s) => s.night == 3;

  @override
  String renardCenter(GameState s) => _id(s, s.night == 1 ? 'Bruno' : 'Emma');

  @override
  String? corbeau(GameState s) => _id(s, 'Inès');

  @override
  ({bool save, String? poison}) sorciere(GameState s) => s.night == 1
      ? (save: true, poison: null)
      : (save: false, poison: _id(s, 'Gaëlle'));

  @override
  String chasseur(GameState s) => _id(s, 'Félix');

  @override
  String mayorSuccessor(GameState s) {
    final dead = s.byId(s.mayorSuccessionNeededFor!).name;
    return _id(s, switch (dead) {
      'Félix' => 'Oscar',
      'Oscar' => 'Hugo',
      'Hugo' => 'Nina',
      'Nina' => 'Léo',
      _ => throw StateError('Succession imprévue de $dead'),
    });
  }

  @override
  bool servanteTakesRole(GameState s) => true;

  @override
  Set<String> boucEmissaire(GameState s) => {
        for (final name in const ['Chloé', 'Hugo', 'Léo', 'Nina', 'Oscar'])
          _id(s, name),
      };

  @override
  bool collectiveTie(GameState s) => false;

  @override
  String mayorTieBreak(GameState s, List<Player> tied) =>
      throw StateError("Pas d'égalité tranchée par le maire");

  @override
  VoteMode voteMode(GameState s, {required bool mayorElection}) =>
      !mayorElection && s.day == 6
          ? VoteMode.collective
          : VoteMode.secret;

  @override
  bool jugeBegue(GameState s) => s.day == 2;

  @override
  String collectiveVote(GameState s, {required bool mayorElection}) =>
      _id(s, 'Manon');

  @override
  String secretVote(GameState s, Player voter, List<Player> candidates,
      {required bool mayorElection}) {
    final ballots = mayorElection
        ? _mayorBallots
        : switch (s.day) {
            1 => _day1,
            2 => s.voteReplayPending ? _day2a : _day2b,
            3 => _day3,
            4 => _day4,
            5 => _day5,
            7 => _day7,
            _ => throw StateError('Pas de vote secret le jour ${s.day}'),
          };
    final target = ballots[voter.name];
    if (target == null) {
      throw StateError('${voter.name} ne devrait pas voter (jour ${s.day})');
    }
    return _id(s, target);
  }

  /// Félix 7, Inès 6, Hugo 4 : Inès gagnerait avec les voix du Corbeau.
  static const _mayorBallots = {
    'Bruno': 'Félix', 'Chloé': 'Félix', 'David': 'Félix', 'Emma': 'Félix',
    'Félix': 'Félix', 'Hugo': 'Félix', 'Léo': 'Félix', //
    'Inès': 'Inès', 'Jules': 'Inès', 'Nina': 'Inès', 'Oscar': 'Inès',
    'Paul': 'Inès', 'Rose': 'Inès', //
    'Alice': 'Hugo', 'Gaëlle': 'Hugo', 'Manon': 'Hugo', 'Quentin': 'Hugo',
  };

  /// Rose 4 ; Inès 3 + 2 voix du Corbeau = 5 (Félix, maire, compte double).
  static const _day1 = {
    'Alice': 'Inès', 'Gaëlle': 'Inès', 'Manon': 'Inès', //
    'Bruno': 'Rose', 'Chloé': 'Rose', 'Emma': 'Rose', 'Quentin': 'Rose', //
    'Félix': 'Quentin', 'David': 'Quentin', //
    'Inès': 'Hugo', 'Jules': 'Hugo', 'Léo': 'Hugo', //
    'Nina': 'Paul', 'Oscar': 'Paul', 'Hugo': 'Paul', //
    'Paul': 'Alice', 'Rose': 'Alice',
  };

  /// Bruno 6 (Oscar, maire, compte double). Inès ne vote plus.
  static const _day2a = {
    'Manon': 'Bruno', 'Quentin': 'Bruno', 'Rose': 'Bruno', 'Jules': 'Bruno',
    'Oscar': 'Bruno', //
    'Bruno': 'Manon', 'Chloé': 'Manon', 'Emma': 'Manon', //
    'Hugo': 'Rose', 'Léo': 'Rose', 'Nina': 'Rose',
  };

  /// Vote rejoué (Juge Bègue) : Jules 4, Manon 4, Hugo 3. Égalité : Rose,
  /// le Bouc Émissaire, meurt à leur place.
  static const _day2b = {
    'Chloé': 'Jules', 'Léo': 'Jules', 'Oscar': 'Jules', //
    'Emma': 'Manon', 'Nina': 'Manon', 'Hugo': 'Manon', 'Rose': 'Manon', //
    'Manon': 'Hugo', 'Jules': 'Hugo', 'Quentin': 'Hugo',
  };

  /// Seuls votent ceux qu'a désignés le Bouc Émissaire : Quentin 6.
  static const _day3 = {
    'Chloé': 'Quentin', 'Hugo': 'Quentin', 'Léo': 'Quentin',
    'Nina': 'Quentin', 'Oscar': 'Quentin',
  };

  /// Hugo, l'Ancien et maire, est pendu : 4 contre 3.
  static const _day4 = {
    'Emma': 'Hugo', 'Jules': 'Hugo', 'Manon': 'Hugo', 'Léo': 'Hugo', //
    'Hugo': 'Jules', 'Nina': 'Jules', //
    'Chloé': 'Emma',
  };

  /// Jules 4 (Léo, maire, compte double).
  static const _day5 = {
    'Léo': 'Jules', 'Chloé': 'Jules', 'Emma': 'Jules', //
    'Jules': 'Chloé', 'Manon': 'Chloé',
  };

  /// Léo, maire, l'emporte 2 voix contre 1.
  static const _day7 = {'Léo': 'Emma', 'Emma': 'Léo'};
}
