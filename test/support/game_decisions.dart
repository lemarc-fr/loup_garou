import 'dart:math';

import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/player.dart';
import 'package:thiercelieux/models/role.dart';

/// Les choix des joueurs, pour jouer une partie entière sans intervention.
/// La même implémentation pilote le moteur directement (EngineRunner) ou
/// l'interface en tapant sur les écrans (UiGameDriver) : les deux doivent
/// aboutir à la même partie.
abstract class GameDecisions {
  /// null : le Voleur garde sa carte.
  RoleId? voleur(GameState s);
  (String, String) cupidon(GameState s);
  String enfantSauvageModel(GameState s);
  String salvateur(GameState s);
  String voyante(GameState s);
  String loups(GameState s);

  /// null : il renonce cette nuit.
  String? loupBlanc(GameState s);

  /// null : il renonce à sa seconde victime.
  String? grandMechantLoup(GameState s);
  bool infect(GameState s);
  String renardCenter(GameState s);

  /// null : il ne maudit personne cette nuit.
  String? corbeau(GameState s);
  ({bool save, String? poison}) sorciere(GameState s);
  String chasseur(GameState s);
  String mayorSuccessor(GameState s);
  bool servanteTakesRole(GameState s);
  /// Les seuls joueurs qui pourront voter demain (au moins un).
  Set<String> boucEmissaire(GameState s);
  VoteMode voteMode(GameState s, {required bool mayorElection});
  bool jugeBegue(GameState s);

  /// Vote secret de [voter] parmi [candidates] (les ex aequo au second
  /// tour).
  String secretVote(GameState s, Player voter, List<Player> candidates,
      {required bool mayorElection});

  /// Vote collectif : résultat saisi par la table.
  String collectiveVote(GameState s, {required bool mayorElection});

  /// Vote collectif du village : la table se déclare à égalité (seulement
  /// demandé quand une règle d'égalité autre que le second tour s'applique).
  bool collectiveTie(GameState s);

  /// Le maire tranche une égalité parmi [tied].
  String mayorTieBreak(GameState s, List<Player> tied);
}

/// Ce que chaque écran propose réellement (mêmes filtres que l'UI).
abstract final class LegalChoices {
  static List<Player> loupsTargets(GameState s) {
    if (s.settings.allowWerewolfToKillThemselves) return s.alivePlayers;
    return s.alivePlayers.where((p) => !s.isWolfPackMember(p)).toList();
  }

  static List<Player> grandMechantLoupTargets(GameState s) => s.alivePlayers
      .where((p) => p.id != s.loupsVictimId)
      .where((p) =>
          s.settings.allowWerewolfToKillThemselves || !s.isWolfPackMember(p))
      .toList();

  static List<Player> loupBlancTargets(GameState s) => s.aliveWolves;

  static List<Player> salvateurTargets(GameState s) =>
      s.alivePlayers.where((p) => s.salvateurCanProtect(p.id)).toList();

  static List<Player> enfantSauvageModels(GameState s) {
    final enfant = s.alivePlayersWithRole(RoleId.enfantSauvage).first;
    return s.alivePlayers.where((p) => p.id != enfant.id).toList();
  }

  static Player? sorciereVictim(GameState s) =>
      s.tryById(s.sorciereSeesVictimId);

  static bool sorciereCanSave(GameState s) {
    final victim = sorciereVictim(s);
    if (victim == null || s.sorciereVieUsed) return false;
    final isHerself = victim.role == RoleId.sorciere;
    return !isHerself || s.settings.allowWitchToSaveHerself;
  }

  static bool sorciereCanPoison(GameState s) => !s.sorciereMortUsed;

  static List<Player> poisonTargets(GameState s) =>
      s.alivePlayers.where((p) => p.role != RoleId.sorciere).toList();

  /// Le Voleur doit prendre une carte si les deux sont des Loups-Garous.
  static bool voleurForced(GameState s) =>
      s.voleurTableCards.isNotEmpty &&
      s.voleurTableCards.every((c) => c == RoleId.loupGarou);
}

/// Des choix au hasard parmi les options légales, reproductibles avec la
/// même graine.
class RandomDecisions implements GameDecisions {
  final Random rng;
  RandomDecisions(this.rng);

  T _pick<T>(List<T> options) => options[rng.nextInt(options.length)];
  bool _chance(double p) => rng.nextDouble() < p;

  @override
  RoleId? voleur(GameState s) {
    final cards = s.voleurTableCards;
    if (!LegalChoices.voleurForced(s) && _chance(0.4)) return null;
    return _pick(cards);
  }

  @override
  (String, String) cupidon(GameState s) {
    final players = [...s.alivePlayers]..shuffle(rng);
    return (players[0].id, players[1].id);
  }

  @override
  String enfantSauvageModel(GameState s) =>
      _pick(LegalChoices.enfantSauvageModels(s)).id;

  @override
  String salvateur(GameState s) => _pick(LegalChoices.salvateurTargets(s)).id;

  @override
  String voyante(GameState s) => _pick(s.alivePlayers).id;

  @override
  String loups(GameState s) {
    final targets = LegalChoices.loupsTargets(s);
    // Le plus souvent un non-loup, pour que les parties avancent.
    final prey = targets.where((p) => p.camp != Camp.loups).toList();
    return _pick(prey.isNotEmpty && _chance(0.9) ? prey : targets).id;
  }

  @override
  String? loupBlanc(GameState s) {
    final targets = LegalChoices.loupBlancTargets(s);
    if (targets.isEmpty || _chance(0.5)) return null;
    return _pick(targets).id;
  }

  @override
  String? grandMechantLoup(GameState s) {
    final targets = LegalChoices.grandMechantLoupTargets(s);
    if (targets.isEmpty || _chance(0.5)) return null;
    return _pick(targets).id;
  }

  @override
  bool infect(GameState s) => _chance(0.35);

  @override
  String renardCenter(GameState s) => _pick(s.alivePlayers).id;

  @override
  String? corbeau(GameState s) =>
      _chance(0.2) ? null : _pick(s.alivePlayers).id;

  @override
  ({bool save, String? poison}) sorciere(GameState s) {
    final save = LegalChoices.sorciereCanSave(s) && _chance(0.5);
    final targets = LegalChoices.poisonTargets(s);
    final poison =
        LegalChoices.sorciereCanPoison(s) && targets.isNotEmpty && _chance(0.3)
            ? _pick(targets).id
            : null;
    return (save: save, poison: poison);
  }

  @override
  String chasseur(GameState s) => _pick(s.alivePlayers).id;

  @override
  String mayorSuccessor(GameState s) => _pick(s.alivePlayers).id;

  @override
  bool servanteTakesRole(GameState s) => _chance(0.5);

  @override
  Set<String> boucEmissaire(GameState s) {
    final allowed = {
      for (final p in s.alivePlayers)
        if (_chance(0.7)) p.id,
    };
    return allowed.isEmpty ? {_pick(s.alivePlayers).id} : allowed;
  }

  @override
  VoteMode voteMode(GameState s, {required bool mayorElection}) =>
      _chance(0.5) ? VoteMode.secret : VoteMode.collective;

  @override
  bool jugeBegue(GameState s) => _chance(0.4);

  @override
  String secretVote(GameState s, Player voter, List<Player> candidates,
          {required bool mayorElection}) =>
      _pick(candidates).id;

  @override
  String collectiveVote(GameState s, {required bool mayorElection}) =>
      _pick(s.alivePlayers).id;

  @override
  bool collectiveTie(GameState s) => _chance(0.2);

  @override
  String mayorTieBreak(GameState s, List<Player> tied) => _pick(tied).id;
}
