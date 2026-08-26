import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/game_config.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/role.dart';

class VoteTally {
  final String? winner;
  final List<String> tiedCandidates;
  const VoteTally({this.winner, required this.tiedCandidates});
  bool get isTie => winner == null && tiedCandidates.length > 1;
}

/// Toute la logique de partie vit ici, séparée de l'UI et du provider.
/// Chaque méthode mute le [GameState] passé en paramètre ; c'est au
/// GameProvider d'appeler notifyListeners() ensuite.
class GameEngine {
  final Random _rng = Random();
  static const uuid = Uuid();

  // ---------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------

  GameState initGame(
      GameConfig config,
      List<String> playerNames,
      GameSettings settings,
      ) {
    final pool = <RoleId>[];
    config.roleCounts.forEach((role, count) {
      for (var i = 0; i < count; i++) {
        pool.add(role);
      }
    });
    pool.shuffle(_rng);

    final hasVoleur = config.hasVoleur;
    final tableCards = hasVoleur ? pool.sublist(pool.length - 2) : <RoleId>[];
    final assignable = hasVoleur ? pool.sublist(0, pool.length - 2) : pool;

    final players = <Player>[
      for (var i = 0; i < playerNames.length; i++)
        Player(id: uuid.v4(), name: playerNames[i], role: assignable[i]),
    ];

    final state = GameState(
      id: uuid.v4(),
      startedAt: DateTime.now(),
      config: config,
      players: players,
      settings: settings,
      phase: GamePhase.roleReveal,
    );
    state.voleurTableCards = tableCards;
    return state;
  }

  void startFirstNight(GameState s) {
    s.night = 1;
    s.currentWave = 'night';
    _resetNightTempData(s);
    s.phaseQueue = buildNightQueue(s);
    s.phaseIndex = 0;
    s.phase = s.phaseQueue[0];
  }

  // ---------------------------------------------------------------------
  // Construction des files de phases
  // ---------------------------------------------------------------------

  List<GamePhase> buildNightQueue(GameState s) {
    final q = <GamePhase>[GamePhase.nightIntro];
    if (s.night == 1 &&
        s.gameHasRole(RoleId.voleur) &&
        s.hasAliveRole(RoleId.voleur)) {
      q.add(GamePhase.nightVoleur);
    }
    if (s.night == 1 &&
        s.gameHasRole(RoleId.cupidon) &&
        s.hasAliveRole(RoleId.cupidon)) {
      q.add(GamePhase.nightCupidon);
    }
    if (s.hasAliveRole(RoleId.voyante)) q.add(GamePhase.nightVoyante);
    if (s.hasAliveRole(RoleId.petiteFille) && s.aliveWolves.isNotEmpty) {
      q.add(GamePhase.nightPetiteFille);
    }
    if (s.aliveWolves.isNotEmpty) q.add(GamePhase.nightLoups);
    final sorciereEncorePuissante = !s.sorciereVieUsed || !s.sorciereMortUsed;
    if (s.hasAliveRole(RoleId.sorciere) &&
        sorciereEncorePuissante &&
        s.aliveWolves.isNotEmpty) {
      q.add(GamePhase.nightSorciere);
    }
    return q;
  }

  void _resetNightTempData(GameState s) {
    s.loupsVictimId = null;
    s.finalNightVictimId = null;
    s.petiteFilleTriedTonight = false;
    s.petiteFilleCaughtTonight = false;
    s.sorciereSavedIdTonight = null;
    s.sorciereKilledIdTonight = null;
    s.voleurSwapChoice = null;
    s.deathsThisWave = [];
  }

  // ---------------------------------------------------------------------
  // Progression générique dans la file de phases courante
  // ---------------------------------------------------------------------

  void advance(GameState s) {
    if (s.pendingActions.isNotEmpty) {
      s.phase = GamePhase.pendingAction;
      return;
    }
    s.phaseIndex++;
    while (s.phaseIndex < s.phaseQueue.length &&
        _shouldSkipPhase(s, s.phaseQueue[s.phaseIndex])) {
      s.phaseIndex++;
    }
    if (s.phaseIndex < s.phaseQueue.length) {
      s.phase = s.phaseQueue[s.phaseIndex];
      return;
    }
    // La file est épuisée : on vient de finir la nuit.
    if (s.currentWave == 'night') {
      _finishNight(s);
    }
  }
  
  bool _shouldSkipPhase(GameState s, GamePhase phase) {
    if (phase == GamePhase.nightSorciere &&
        !s.settings.allowWitchToPlayIfWerewolfDeathCause &&
        s.hasAliveRole(RoleId.sorciere)) {
      final sorciere = s.alivePlayersWithRole(RoleId.sorciere).first;
      return s.finalNightVictimId == sorciere.id;
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // Actions de nuit
  // ---------------------------------------------------------------------

  void resolveVoleur(GameState s, RoleId? chosenTableCard) {
    if (chosenTableCard != null) {
      final voleur = s.alivePlayersWithRole(RoleId.voleur).first;
      final idx = s.voleurTableCards.indexOf(chosenTableCard);
      if (idx != -1) {
        s.voleurTableCards[idx] = RoleId.voleur;
        voleur.role = chosenTableCard;
      }
    }
    advance(s);
  }

  void resolveCupidon(GameState s, String playerId1, String playerId2) {
    s.loversIds = [playerId1, playerId2];
    s.byId(playerId1).loverId = playerId2;
    s.byId(playerId2).loverId = playerId1;
    advance(s);
  }

  /// La voyante n'altère aucun état — l'écran affiche juste le rôle en direct.
  void confirmVoyanteDone(GameState s) => advance(s);

  void setLoupsVictim(GameState s, String victimId) {
    s.loupsVictimId = victimId;
    s.finalNightVictimId = victimId;
    advance(s);
  }

  /// [tried] = la petite fille a choisi d'entrouvrir les yeux cette nuit.
  void resolvePetiteFille(GameState s, {required bool tried}) {
    s.petiteFilleTriedTonight = tried;
    s.petiteFilleCaughtTonight = false;
    if (tried) {
      final caught = _rng.nextDouble() < 0.3; // 30% de risque d'être repérée
      s.petiteFilleCaughtTonight = caught;
      if (caught) {
        final pf = s.alivePlayersWithRole(RoleId.petiteFille).first;
        s.finalNightVictimId =
            pf.id; // elle prend la place de la victime prévue
      }
    }
    advance(s);
  }

  void resolveSorciere(GameState s,
      {bool useVie = false, String? poisonTargetId}) {
    if (useVie && !s.sorciereVieUsed) {
      s.sorciereVieUsed = true;
      s.sorciereSavedIdTonight = s.finalNightVictimId;
      s.finalNightVictimId = null;
    }
    if (poisonTargetId != null && !s.sorciereMortUsed) {
      s.sorciereMortUsed = true;
      s.sorciereKilledIdTonight = poisonTargetId;
    }
    advance(s);
  }

  void _finishNight(GameState s) {
    if (s.finalNightVictimId != null) {
      _applyDeath(s, s.finalNightVictimId!, DeathCause.devoreParLesLoups);
    }
    if (s.sorciereKilledIdTonight != null) {
      _applyDeath(s, s.sorciereKilledIdTonight!, DeathCause.potionDeMort);
    }
    if (s.pendingActions.isNotEmpty) {
      s.phase = GamePhase.pendingAction;
      return;
    }
    _goToDayReveal(s);
  }

  void _goToDayReveal(GameState s) {
    s.day += 1;
    s.currentWave = 'day';
    s.phaseQueue = [GamePhase.dayReveal];
    s.phaseIndex = 0;
    s.phase = GamePhase.dayReveal;
  }

  // ---------------------------------------------------------------------
  // Actions différées (vengeance du chasseur / succession du maire)
  // ---------------------------------------------------------------------

  void resolvePendingAction(GameState s,
      {String? hunterTargetId, String? mayorSuccessorId}) {
    if (s.pendingActions.isEmpty) return;
    final action = s.pendingActions.removeAt(0);
    if (action.isHunterRevenge && hunterTargetId != null) {
      _applyDeath(s, hunterTargetId, DeathCause.vengeanceDuChasseur);
    }
    if (action.isMayorSuccession) {
      s.mayorId = mayorSuccessorId;
    }
    if (s.pendingActions.isNotEmpty) {
      s.phase = GamePhase.pendingAction;
      return;
    }
    if (s.currentWave == 'night') {
      _goToDayReveal(s);
    } else {
      s.phase = GamePhase.voteResult;
    }
  }

  // ---------------------------------------------------------------------
  // Phase de jour
  // ---------------------------------------------------------------------

  /// À appeler quand le groupe a fini de lire le récapitulatif des morts de la nuit.
  void confirmDayReveal(GameState s) {
    final result = checkWinCondition(s);
    if (result != null) {
      s.result = result;
      s.phase = GamePhase.endGame;
      return;
    }
    // On repart d'une liste vierge pour la vague "jour" : les morts de la
    // nuit viennent d'être révélées, on ne veut pas les revoir mélangées
    // aux morts du vote qui va suivre (cf. VoteResultScreen).
    s.deathsThisWave = [];
    final rest = <GamePhase>[GamePhase.dayReveal];
    if (s.mayorId == null) {
      rest.add(GamePhase.mayorElectionExplain);
      rest.add(GamePhase.mayorElection);
      rest.add(GamePhase.mayorReveal);
    }
    rest.add(GamePhase.debate);
    rest.add(GamePhase.villageVote);
    s.phaseQueue = rest;
    s.phaseIndex = 1;
    s.phase = s.phaseQueue[1];
  }

  void resolveMayorElection(GameState s, String winnerId) {
    s.mayorId = winnerId;
    advance2(s);
  }

  /// La file de jour ne passe pas par [advance] classique (qui gère la fin
  /// de nuit) : on avance simplement l'index sans re-déclencher `_finishNight`.
  void advance2(GameState s) {
    s.phaseIndex++;
    if (s.phaseIndex < s.phaseQueue.length) {
      s.phase = s.phaseQueue[s.phaseIndex];
    }
  }
  void confirmMayorElectionExplain(GameState s) => advance2(s);
  void confirmDebate(GameState s) => advance2(s);
  void confirmMayorReveal(GameState s) => advance2(s);

  VoteTally tallyVotes(GameState s, Map<String, String> votes) {
    final counts = <String, int>{};
    votes.forEach((voterId, targetId) {
      final weight = (s.mayorId != null && voterId == s.mayorId) ? 2 : 1;
      counts[targetId] = (counts[targetId] ?? 0) + weight;
    });
    if (counts.isEmpty) return const VoteTally(tiedCandidates: []);
    final maxVotes = counts.values.reduce(max);
    final tied = counts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();
    if (tied.length == 1) {
      return VoteTally(winner: tied.first, tiedCandidates: const []);
    }
    return VoteTally(tiedCandidates: tied);
  }

  void resolveVillageVote(GameState s, String eliminatedId) {
    _applyDeath(s, eliminatedId, DeathCause.vote);
    if (s.pendingActions.isNotEmpty) {
      s.phase = GamePhase.pendingAction;
      return;
    }
    s.phase = GamePhase.voteResult;
  }

  /// À appeler quand le groupe a fini de lire le résultat du vote.
  /// À appeler quand le groupe a fini de lire le résultat du vote.
  void confirmVoteResult(GameState s) {
    final result = checkWinCondition(s);
    if (result != null) {
      s.result = result;
      s.phase = GamePhase.endGame;
      return;
    }
    if (s.powerLossThisWave.isNotEmpty) {
      s.phase = GamePhase.villagePowerLoss;
      return;
    }
    _startNextNight(s);
  }

  /// À appeler quand le groupe a fini de lire la révélation de perte de pouvoirs.
  void confirmPowerLossReveal(GameState s) {
    s.powerLossThisWave = [];
    _startNextNight(s);
  }

  void _startNextNight(GameState s) {
    s.night += 1;
    s.currentWave = 'night';
    _resetNightTempData(s);
    s.phaseQueue = buildNightQueue(s);
    s.phaseIndex = 0;
    s.phase = s.phaseQueue[0];
  }

  // ---------------------------------------------------------------------
  // Morts en cascade
  // ---------------------------------------------------------------------

  void _applyDeath(GameState s, String playerId, DeathCause cause) {
    final p = s.byId(playerId);
    if (!p.alive) return; // déjà mort (ex. sauvé puis reciblé ailleurs)

    // L'Ancien résiste à une première attaque des Loups-Garous : il survit
    // en silence, sans qu'aucun mort ne soit annoncé cette nuit-là.
    if (p.role == RoleId.ancien &&
        cause == DeathCause.devoreParLesLoups &&
        !s.ancienExtraLifeUsed) {
      s.ancienExtraLifeUsed = true;
      return;
    }

    p.alive = false;
    p.deathCause = cause;
    p.deathAtNight = s.currentWave == 'night' ? s.night : null;
    p.deathAtDay = s.currentWave == 'day' ? s.day : null;
    s.deathsThisWave.add(playerId);

    // Chagrin d'amour : mort immédiate et inconditionnelle de l'autre Amoureux.
    final lover = s.tryById(p.loverId);
    if (lover != null && lover.alive) {
      _applyDeath(s, lover.id, DeathCause.chagrinDAmour);
    }

    final hunterRevengeCauses = <DeathCause>{
      DeathCause.devoreParLesLoups,
      DeathCause.vote,
      if (s.settings.allowHunterToShootAfterWitchDeathCause)
        DeathCause.potionDeMort,
    };
    if (p.role == RoleId.chasseur && hunterRevengeCauses.contains(cause)) {
      s.pendingActions
          .add(PendingAction(playerId: p.id, isHunterRevenge: true));
    }

    // Succession du maire, quelle que soit la cause de sa mort.
    if (p.isMayor) {
      p.isMayor = false;
      s.pendingActions
          .add(PendingAction(playerId: p.id, isMayorSuccession: true));
    }

    // Le village a fait pendre l'Ancien par erreur : tous les villageois à
    // pouvoir perdent leur don pour le reste de la partie.
    if (p.role == RoleId.ancien && cause == DeathCause.vote) {
      _villageLosesPowers(s);
    }
  }

  /// Rétrograde tous les villageois à pouvoir en simples villageois (les
  /// Loups ne sont pas concernés). Déclenché quand le village exécute
  /// l'Ancien par erreur.
  void _villageLosesPowers(GameState s) {
    for (final p in s.alivePlayers) {
      if (p.camp == Camp.village && p.role != RoleId.simpleVillageois) {
        s.powerLossThisWave.add(PowerLossEntry(p.id, p.role));
        p.role = RoleId.simpleVillageois;
      }
    }
  }

  // ---------------------------------------------------------------------
  // Condition de victoire
  // ---------------------------------------------------------------------

  GameResult? checkWinCondition(GameState s) {
    final alive = s.alivePlayers;

    if (alive.length == 2) {
      final a = alive[0], b = alive[1];
      if (a.loverId == b.id && b.loverId == a.id && a.camp != b.camp) {
        return GameResult(WinnerType.amoureux, [a.id, b.id]);
      }
    }

    final wolves = alive.where((p) => p.camp == Camp.loups).length;
    final villagers = alive.length - wolves;

    if (wolves == 0) {
      return GameResult(WinnerType.village, alive.map((p) => p.id).toList());
    }
    if (wolves >= villagers) {
      return GameResult(WinnerType.loups,
          alive.where((p) => p.camp == Camp.loups).map((p) => p.id).toList());
    }
    return null;
  }
}
