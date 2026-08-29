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
///
/// Il n'y a plus de file générique d'actions en attente ("pending
/// actions"). À la place : chaque mort, dans [_applyDeath], pose un flag
/// précis sur le GameState (chasseurRevengeTargetId,
/// mayorSuccessionNeededFor, enfantSauvageTransformedId, ...) et
/// [_resolveFollowUps] regarde ces flags, dans un ordre fixe, pour
/// décider de la prochaine phase — un simple enchaînement de "if", pas de
/// queue générique à maintenir.
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
    s.salvateurLastProtectedId = null;
    s.phaseQueue = buildNightQueue(s);
    s.phaseIndex = 0;
    s.phase = s.phaseQueue[0];
  }

  // ---------------------------------------------------------------------
  // Construction de la file de nuit
  // ---------------------------------------------------------------------

  List<GamePhase> buildNightQueue(GameState s) {
    final q = <GamePhase>[GamePhase.nightIntro];

    if (s.night == 1) {
      if (s.hasAliveRole(RoleId.voleur)) q.add(GamePhase.nightVoleur);
      if (s.hasAliveRole(RoleId.cupidon)) q.add(GamePhase.nightCupidon);
      if (s.hasAliveRole(RoleId.enfantSauvage)) {
        q.add(GamePhase.nightEnfantSauvage);
      }
    }

    if (s.hasAliveRole(RoleId.salvateur) && !_isAsleep(s, RoleId.salvateur)) {
      q.add(GamePhase.nightSalvateur);
    }
    if (s.hasAliveRole(RoleId.voyante) && !_isAsleep(s, RoleId.voyante)) {
      q.add(GamePhase.nightVoyante);
    }

    if (s.aliveWolves.isNotEmpty) {
      q.add(GamePhase.nightLoups);
      // La Petite Fille espionne PENDANT le tour des loups : sa phase se
      // joue donc juste après, une fois la victime des loups connue.
      if (s.hasAliveRole(RoleId.petiteFille)) q.add(GamePhase.nightPetiteFille);
      if (s.hasAliveRole(RoleId.loupBlanc) && s.night > 1 && s.night.isEven) {
        q.add(GamePhase.nightLoupBlanc);
      }
      if (s.hasAliveRole(RoleId.grandMechantLoup) && s.wolfPackIntact) {
        q.add(GamePhase.nightGrandMechantLoup);
      }
      if (s.hasAliveRole(RoleId.infectPereDesLoups) &&
          !s.infectPereDesLoupsUsed) {
        q.add(GamePhase.nightInfectPereDesLoups);
      }
    }

    if (s.hasAliveRole(RoleId.renard) && !s.renardPowerLost) {
      q.add(GamePhase.nightRenard);
    }
    if (s.hasAliveRole(RoleId.corbeau)) q.add(GamePhase.nightCorbeau);

    final sorciereEncorePuissante = !s.sorciereVieUsed || !s.sorciereMortUsed;
    if (s.hasAliveRole(RoleId.sorciere) &&
        sorciereEncorePuissante &&
        s.aliveWolves.isNotEmpty &&
        !_isAsleep(s, RoleId.sorciere)) {
      q.add(GamePhase.nightSorciere);
    }

    return q;
  }

  /// Le Bouc Émissaire peut désigner un joueur qui "saute" la nuit
  /// suivante. Simplification assumée : seuls les rôles à pouvoir
  /// individuel (Salvateur, Voyante, Sorcière) peuvent ainsi être
  /// endormis pour une nuit — sauter le tour d'un seul Loup au sein du
  /// tour collectif des Loups demanderait une UI dédiée (voir TODO).
  bool _isAsleep(GameState s, RoleId role) {
    final skippedId = s.skippedNextNightPlayerId;
    if (skippedId == null) return false;
    final p = s.tryById(skippedId);
    return p != null && p.alive && p.role == role;
  }

  void _resetNightTempData(GameState s) {
    s.loupsVictimId = null;
    s.grandMechantLoupSecondVictimId = null;
    s.infectedTonightId = null;
    s.loupBlancVictimId = null;
    s.salvateurLastProtectedId = s.salvateurProtectedId;
    s.salvateurProtectedId = null;
    s.petiteFilleTriedTonight = false;
    s.petiteFilleCaughtTonight = false;
    s.finalNightVictimId = null;
    s.sorciereSavedIdTonight = null;
    s.sorciereKilledIdTonight = null;
    s.renardTargetIds = [];
    s.renardFoundWolfLastQuery = null;
    s.corbeauCursedId = null;
    s.deathsThisWave = [];
  }

  // ---------------------------------------------------------------------
  // Progression générique dans la file de phases de la nuit
  // ---------------------------------------------------------------------

  void advance(GameState s) {
    s.phaseIndex++;
    while (s.phaseIndex < s.phaseQueue.length &&
        _shouldSkipPhase(s, s.phaseQueue[s.phaseIndex])) {
      s.phaseIndex++;
    }
    if (s.phaseIndex < s.phaseQueue.length) {
      s.phase = s.phaseQueue[s.phaseIndex];
      return;
    }
    if (s.currentWave == 'night') {
      _finishNight(s);
    }
  }

  /// Avance simple dans la file du jour (mayorElectionExplain, debate,
  /// jugeBegueDecision, ...) — contrairement à [advance], ne déclenche
  /// jamais la fin de nuit.
  void advance2(GameState s) {
    s.phaseIndex++;
    if (s.phaseIndex < s.phaseQueue.length) {
      s.phase = s.phaseQueue[s.phaseIndex];
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

  /// L'Enfant Sauvage choisit son modèle. On se contente d'écrire l'id de
  /// l'Enfant Sauvage sur le champ [Player.mentorOf] du modèle choisi :
  /// c'est la seule donnée dont [_applyDeath] a besoin pour déclencher la
  /// mutation en Loup-Garou le jour où ce modèle meurt — pas besoin d'une
  /// file d'actions en attente pour ça, juste ce champ et un "if".
  void resolveEnfantSauvageMentor(GameState s, String modelId) {
    final enfant = s.alivePlayersWithRole(RoleId.enfantSauvage).first;
    s.byId(modelId).mentorOf = enfant.id;
    advance(s);
  }

  void resolveSalvateur(GameState s, String protectedId) {
    s.salvateurProtectedId = protectedId;
    advance(s);
  }

  /// La voyante n'altère aucun état — l'écran affiche juste le rôle en direct.
  void confirmVoyanteDone(GameState s) => advance(s);

  void setLoupsVictim(GameState s, String victimId) {
    s.loupsVictimId = victimId;
    s.finalNightVictimId =
    (victimId == s.salvateurProtectedId) ? null : victimId;
    advance(s);
  }

  /// [tried] = la petite fille a choisi d'entrouvrir les yeux cette nuit.
  /// Se joue après les Loups : si elle se fait surprendre, elle prend la
  /// place de la victime désignée, même si celle-ci avait été protégée
  /// par le Salvateur.
  void resolvePetiteFille(GameState s, {required bool tried}) {
    s.petiteFilleTriedTonight = tried;
    s.petiteFilleCaughtTonight = false;
    if (tried) {
      final caught = _rng.nextDouble() < 0.3; // 30% de risque d'être repérée
      s.petiteFilleCaughtTonight = caught;
      if (caught) {
        final pf = s.alivePlayersWithRole(RoleId.petiteFille).first;
        s.finalNightVictimId = pf.id;
      }
    }
    advance(s);
  }

  /// [targetId] == null si le Loup Blanc choisit de ne pas utiliser son
  /// pouvoir cette nuit-là.
  void resolveLoupBlanc(GameState s, String? targetId) {
    s.loupBlancVictimId = targetId;
    advance(s);
  }

  void resolveGrandMechantLoup(GameState s, String? secondVictimId) {
    s.grandMechantLoupSecondVictimId = secondVictimId;
    advance(s);
  }

  /// Convertit la victime des Loups en Loup-Garou au lieu de la tuer, si
  /// elle n'a pas déjà été sauvée ou remplacée entre-temps.
  void resolveInfectPereDesLoups(GameState s, bool infect) {
    if (infect && !s.infectPereDesLoupsUsed && s.loupsVictimId != null) {
      final victim = s.tryById(s.loupsVictimId);
      if (victim != null && victim.alive && victim.camp != Camp.loups) {
        s.infectPereDesLoupsUsed = true;
        s.infectedTonightId = victim.id;
        if (s.finalNightVictimId == victim.id) {
          s.finalNightVictimId = null;
        }
      }
    }
    advance(s);
  }

  void resolveRenard(GameState s, List<String> targetIds) {
    s.renardTargetIds = targetIds;
    final foundWolf = targetIds.any((id) {
      final p = s.tryById(id);
      return p != null && p.camp == Camp.loups;
    });
    s.renardFoundWolfLastQuery = foundWolf;
    if (!foundWolf) {
      // Variante classique : le flair se perd pour le reste de la partie
      // si aucun Loup-Garou n'est trouvé parmi les trois joueurs choisis.
      s.renardPowerLost = true;
    }
    advance(s);
  }

  void resolveCorbeau(GameState s, String targetId) {
    s.corbeauCursedId = targetId;
    advance(s);
  }

  void resolveSorciere(
      GameState s, {
        bool useVie = false,
        String? poisonTargetId,
      }) {
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

  // ---------------------------------------------------------------------
  // Fin de nuit → jour
  // ---------------------------------------------------------------------

  void _finishNight(GameState s) {
    if (s.finalNightVictimId != null) {
      _applyDeath(s, s.finalNightVictimId!, DeathCause.devoreParLesLoups);
    }
    if (s.grandMechantLoupSecondVictimId != null) {
      _applyDeath(
          s, s.grandMechantLoupSecondVictimId!, DeathCause.devoreParLesLoups);
    }
    if (s.loupBlancVictimId != null) {
      _applyDeath(s, s.loupBlancVictimId!, DeathCause.tueParLoupBlanc);
    }
    if (s.sorciereKilledIdTonight != null) {
      _applyDeath(s, s.sorciereKilledIdTonight!, DeathCause.potionDeMort);
    }
    if (s.infectedTonightId != null) {
      final infected = s.tryById(s.infectedTonightId);
      if (infected != null && infected.alive) {
        infected.role = RoleId.loupGarou;
      }
    }

    s.currentWave = 'day';
    s.day += 1;
    s.phaseQueue = [GamePhase.dayReveal];
    s.phaseIndex = 0;
    s.phase = GamePhase.dayReveal;
  }

  /// À appeler quand le groupe a fini de lire le récapitulatif des morts
  /// de la nuit.
  void confirmDayReveal(GameState s) {
    s.followUpOrigin = FollowUpOrigin.nightDeaths;
    _resolveFollowUps(s);
  }

  void _afterNightDeathsResolved(GameState s) {
    s.deathsThisWave = [];
    final rest = <GamePhase>[GamePhase.dayReveal];
    if (s.mayorId == null) {
      rest.addAll([
        GamePhase.mayorElectionExplain,
        GamePhase.mayorElection,
        GamePhase.mayorReveal,
      ]);
    }
    rest.add(GamePhase.debate);
    if (s.hasAliveRole(RoleId.jugeBegue) && !s.jugeBegueUsed) {
      rest.add(GamePhase.jugeBegueDecision);
    }
    rest.add(GamePhase.villageVote);
    s.phaseQueue = rest;
    s.phaseIndex = 1; // index 0 (dayReveal) déjà affiché
    s.phase = s.phaseQueue[1];
  }

  // ---------------------------------------------------------------------
  // Suites déclenchées par une mort
  // ---------------------------------------------------------------------

  /// Regarde, dans un ordre fixe, si une conséquence d'une mort est
  /// encore en attente (riposte du Chasseur, succession du maire,
  /// mutation de l'Enfant Sauvage, perte de pouvoirs du village, Servante
  /// Dévouée, Bouc Émissaire, Idiot du Village). S'il y en a une, bascule
  /// sur la phase correspondante et s'arrête là : c'est la méthode de
  /// résolution appelée ensuite par l'UI qui rappellera cette fonction
  /// pour vérifier la suivante. Sinon, poursuit le déroulé normal selon
  /// [GameState.followUpOrigin]. C'est l'unique remplaçant de l'ancienne
  /// file [pendingActions] : pas de queue, juste des flags et des "if".
  void _resolveFollowUps(GameState s) {
    final result = checkWinCondition(s);
    if (result != null) {
      s.result = result;
      s.phase = GamePhase.endGame;
      return;
    }
    if (s.chasseurRevengeTargetId != null) {
      s.phase = GamePhase.chasseurRevange;
      return;
    }
    if (s.mayorSuccessionNeededFor != null) {
      s.phase = GamePhase.successionMaire;
      return;
    }
    if (s.enfantSauvageTransformedId != null) {
      s.phase = GamePhase.enfantsauvageReveal;
      return;
    }
    if (s.powerLossThisWave.isNotEmpty) {
      s.phase = GamePhase.villagePowerLoss;
      return;
    }
    if (s.servanteDevoueeOfferId != null) {
      s.phase = GamePhase.servanteDevouee;
      return;
    }
    if (s.boucEmissaireChoiceNeededId != null) {
      s.phase = GamePhase.boucEmissaire;
      return;
    }
    if (s.idiotDuVillageRevealId != null) {
      s.phase = GamePhase.idiotduvillageCivicRightLoss;
      return;
    }

    switch (s.followUpOrigin) {
      case FollowUpOrigin.nightDeaths:
        _afterNightDeathsResolved(s);
        break;
      case FollowUpOrigin.voteDeaths:
        _afterVoteDeathsResolved(s);
        break;
      case null:
        break;
    }
  }

  void resolveChasseurRevenge(GameState s, String targetId) {
    s.chasseurRevengeTargetId = null;
    _applyDeath(s, targetId, DeathCause.vengeanceDuChasseur);
    _resolveFollowUps(s);
  }

  void resolveMayorSuccession(GameState s, String successorId) {
    s.mayorSuccessionNeededFor = null;
    s.mayorId = successorId;
    _resolveFollowUps(s);
  }

  void confirmEnfantSauvageReveal(GameState s) {
    s.enfantSauvageTransformedId = null;
    s.enfantSauvagePreviousRole = null;
    _resolveFollowUps(s);
  }

  void confirmPowerLossReveal(GameState s) {
    s.powerLossThisWave = [];
    _resolveFollowUps(s);
  }

  void resolveServanteDevouee(GameState s, bool takeRole) {
    final offerId = s.servanteDevoueeOfferId;
    s.servanteDevoueeOfferId = null;
    if (takeRole && offerId != null) {
      final dead = s.tryById(offerId);
      final servante = s.hasAliveRole(RoleId.servanteDevouee)
          ? s.alivePlayersWithRole(RoleId.servanteDevouee).first
          : null;
      if (dead != null && servante != null) {
        servante.role = dead.role;
      }
    }
    _resolveFollowUps(s);
  }

  void resolveBoucEmissaireChoice(GameState s, String skippedPlayerId) {
    s.boucEmissaireChoiceNeededId = null;
    s.skippedNextNightPlayerId = skippedPlayerId;
    _resolveFollowUps(s);
  }

  void confirmIdiotDuVillageReveal(GameState s) {
    final id = s.idiotDuVillageRevealId;
    s.idiotDuVillageRevealId = null;
    if (id != null) s.disenfranchisedPlayerIds.add(id);
    _resolveFollowUps(s);
  }

  // ---------------------------------------------------------------------
  // Jour
  // ---------------------------------------------------------------------

  void resolveMayorElection(GameState s, String winnerId) {
    s.mayorId = winnerId;
    advance2(s);
  }

  void confirmMayorElectionExplain(GameState s) => advance2(s);
  void confirmMayorReveal(GameState s) => advance2(s);
  void confirmDebate(GameState s) => advance2(s);

  void resolveJugeBegueDecision(GameState s, bool usePower) {
    if (usePower) {
      s.jugeBegueUsed = true;
      s.voteReplayPending = true;
    }
    advance2(s);
  }

  VoteTally tallyVotes(GameState s, Map<String, String> votes) {
    final counts = <String, int>{};
    votes.forEach((voterId, targetId) {
      final weight = (s.mayorId != null && voterId == s.mayorId) ? 2 : 1;
      counts[targetId] = (counts[targetId] ?? 0) + weight;
    });
    if (s.corbeauCursedId != null) {
      counts[s.corbeauCursedId!] = (counts[s.corbeauCursedId!] ?? 0) + 2;
    }
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
    s.corbeauCursedId = null; // la malédiction ne vaut que pour ce vote
    s.phase = GamePhase.voteResult;
  }

  void confirmVoteResult(GameState s) {
    s.followUpOrigin = FollowUpOrigin.voteDeaths;
    _resolveFollowUps(s);
  }

  void _afterVoteDeathsResolved(GameState s) {
    if (s.voteReplayPending) {
      // Pouvoir du Juge Bègue : on revote immédiatement, le même jour.
      s.voteReplayPending = false;
      s.phaseQueue = [GamePhase.villageVote];
      s.phaseIndex = 0;
      s.phase = GamePhase.villageVote;
      return;
    }
    _startNextNight(s);
  }

  void _startNextNight(GameState s) {
    s.night += 1;
    s.currentWave = 'night';
    _resetNightTempData(s);
    s.phaseQueue = buildNightQueue(s);
    s.skippedNextNightPlayerId = null;
    s.phaseIndex = 0;
    s.phase = s.phaseQueue[0];
  }

  // ---------------------------------------------------------------------
  // Morts en cascade
  // ---------------------------------------------------------------------

  void _applyDeath(GameState s, String playerId, DeathCause cause) {
    final p = s.byId(playerId);
    if (!p.alive) return; // déjà mort (ex. sauvé puis reciblé ailleurs)

    // L'Ancien résiste à une première attaque des Loups-Garous : il
    // survit en silence, sans qu'aucun mort ne soit annoncé cette nuit-là.
    if (p.role == RoleId.ancien &&
        cause == DeathCause.devoreParLesLoups &&
        !s.ancienExtraLifeUsed) {
      s.ancienExtraLifeUsed = true;
      return;
    }

    // L'Idiot du Village survit à un vote : démasqué, il perd son droit
    // de vote mais reste en vie. On s'arrête là pour ce joueur : ce n'est
    // pas une mort.
    if (p.role == RoleId.idiotDuVillage && cause == DeathCause.vote) {
      s.idiotDuVillageRevealId = p.id;
      return;
    }

    p.alive = false;
    p.deathCause = cause;
    p.deathAtNight = s.currentWave == 'night' ? s.night : null;
    p.deathAtDay = s.currentWave == 'day' ? s.day : null;
    s.deathsThisWave.add(playerId);

    // Chagrin d'amour : mort immédiate et inconditionnelle de l'autre
    // Amoureux. Pas besoin d'attendre un tour ou une confirmation : c'est
    // un "if" direct dans la cascade, comme demandé.
    final lover = s.tryById(p.loverId);
    if (lover != null && lover.alive) {
      _applyDeath(s, lover.id, DeathCause.chagrinDAmourCupidon);
    }

    // Enfant Sauvage : si le mort était son modèle (mentorOf pointe vers
    // lui), il devient Loup-Garou. La mutation du rôle a lieu tout de
    // suite — elle doit compter dès la prochaine phase des Loups — et un
    // flag est posé pour que la table en soit informée au bon moment
    // (voir GamePhase.enfantsauvageReveal dans _resolveFollowUps).
    if (p.mentorOf != null) {
      final enfant = s.tryById(p.mentorOf);
      if (enfant != null &&
          enfant.alive &&
          enfant.role == RoleId.enfantSauvage) {
        s.enfantSauvagePreviousRole = enfant.role;
        s.enfantSauvageTransformedId = enfant.id;
        enfant.role = RoleId.loupGarou;
      }
    }

    // Le Chasseur réplique quelle que soit l'heure de sa mort, sauf si le
    // réglage interdit la riposte après un empoisonnement par la
    // Sorcière.
    final blockedByWitchSetting = cause == DeathCause.potionDeMort &&
        !s.settings.allowHunterToShootAfterWitchDeathCause;
    if (p.role == RoleId.chasseur && !blockedByWitchSetting) {
      s.chasseurRevengeTargetId = p.id;
    }

    // Succession du maire, quelle que soit la cause de sa mort.
    if (p.isMayor) {
      p.isMayor = false;
      s.mayorSuccessionNeededFor = p.id;
    }

    // Bouc Émissaire éliminé par le vote : il désigne un joueur qui
    // sautera la nuit suivante.
    if (p.role == RoleId.boucEmissaire && cause == DeathCause.vote) {
      s.boucEmissaireChoiceNeededId = p.id;
    }

    // Servante Dévouée : peut reprendre le rôle d'un joueur mort au vote.
    if (cause == DeathCause.vote &&
        p.role != RoleId.servanteDevouee &&
        s.hasAliveRole(RoleId.servanteDevouee)) {
      s.servanteDevoueeOfferId = p.id;
    }

    // Le village a fait pendre l'Ancien par erreur : tous les villageois
    // à pouvoir perdent leur don pour le reste de la partie.
    if (p.role == RoleId.ancien && cause == DeathCause.vote) {
      _villageLosesPowers(s);
    }
  }

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
        return GameResult(Camp.amoureux, [a.id, b.id]);
      }
    }

    // Le Loup-Garou Blanc gagne seul s'il est le dernier survivant.
    if (alive.length == 1 && alive.first.role == RoleId.loupBlanc) {
      return GameResult(Camp.seul, [alive.first.id]);
    }

    final wolves = alive.where((p) => p.camp == Camp.loups).length;
    final others = alive
        .where((p) => p.camp != Camp.loups && p.role != RoleId.loupBlanc)
        .length;

    if (wolves == 0 && others == 0) {
      // Ne devrait arriver qu'avec le Loup Blanc seul, déjà géré au-dessus.
      return null;
    }
    if (wolves == 0) {
      return GameResult(Camp.village, alive.map((p) => p.id).toList());
    }
    if (wolves >= others) {
      return GameResult(
        Camp.loups,
        alive.where((p) => p.camp == Camp.loups).map((p) => p.id).toList(),
      );
    }
    return null;
  }
}