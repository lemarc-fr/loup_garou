import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/game_config.dart';
import '../models/game_progress.dart';
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
    _startRound(s, 'night', 1);
    s.phaseQueue = buildNightQueue(s);
    s.phaseIndex = 0;
    _goToPhase(s, s.phaseQueue[0]);
  }

  // ---------------------------------------------------------------------
  // Résumé "live" de la partie (nuits/jours + étapes) — voir game_progress.dart
  // ---------------------------------------------------------------------

  /// Phases purement transitoires, qui ne représentent aucune information
  /// utile pour le résumé (déjà représentées par le titre "Nuit X" / "Jour X",
  /// ou juste un écran neutre "tu peux te rendormir").
  static const _untrackedPhases = {
    GamePhase.nightIntro,
    GamePhase.nightGoBackToSleep,
  };

  void _startRound(GameState s, String wave, int number) {
    // Referme l'étape "current" laissée en suspens par le round précédent
    // (le dernier rôle de la nuit, le résultat du vote, ...) avant d'en
    // commencer un nouveau.
    if (s.rounds.isNotEmpty) {
      for (final step in s.rounds.last.steps) {
        if (step.status == StepStatus.current) step.status = StepStatus.done;
      }
    }
    s.rounds.add(RoundRecord(wave: wave, number: number));
  }

  /// Change la phase courante ET journalise l'étape dans le round en cours :
  /// l'étape précédemment "current" passe à "done", la nouvelle devient
  /// "current" (ou "done" directement pour la toute dernière, endGame).
  void _goToPhase(GameState s, GamePhase phase) {
    s.phase = phase;
    if (_untrackedPhases.contains(phase) || s.rounds.isEmpty) return;
    final round = s.rounds.last;
    for (final step in round.steps) {
      if (step.status == StepStatus.current) step.status = StepStatus.done;
    }
    round.steps.add(StepRecord(
      phase,
      phase == GamePhase.endGame ? StepStatus.done : StepStatus.current,
    ));
  }

  /// Journalise une étape de la file de nuit que [advance] saute sans
  /// jamais l'afficher (voir _shouldSkipPhase) — typiquement la Sorcière
  /// quand l'option correspondante l'empêche de jouer.
  void _logSkippedPhase(GameState s, GamePhase phase) {
    if (_untrackedPhases.contains(phase) || s.rounds.isEmpty) return;
    s.rounds.last.steps.add(StepRecord(phase, StepStatus.skipped));
  }

  // ---------------------------------------------------------------------
  // Construction de la file de nuit
  // ---------------------------------------------------------------------

  /// Construit la file des phases d'une nuit. Après chaque bloc "un rôle
  /// (ou un petit groupe de rôles liés) se réveille et agit", on insère
  /// une transition [GamePhase.nightGoBackToSleep] : un écran neutre,
  /// sans nom ni rôle, qui donne un point de fermeture clair avant que le
  /// téléphone ne parte vers le rôle suivant (lequel reste de toute façon
  /// protégé par son propre PassDeviceGate). Elle n'est PAS ajoutée après
  /// nightIntro (qui est déjà l'écran d'ouverture de la nuit) ni après le
  /// tout dernier bloc si la nuit ne comporte aucun rôle actif.
  List<GamePhase> buildNightQueue(GameState s) {
    final q = <GamePhase>[GamePhase.nightIntro];

    void addSleep() => q.add(GamePhase.nightGoBackToSleep);

    if (s.night == 1) {
      if (s.hasAliveRole(RoleId.voleur)) {
        q.add(GamePhase.nightVoleur);
        addSleep();
      }
      if (s.hasAliveRole(RoleId.cupidon)) {
        q.add(GamePhase.nightCupidon);
        addSleep();
      }
      if (s.hasAliveRole(RoleId.enfantSauvage)) {
        q.add(GamePhase.nightEnfantSauvage);
        addSleep();
      }
    } else if (s.hasAliveRole(RoleId.enfantSauvage)) {
      // Les nuits suivantes, l'Enfant Sauvage se réveille brièvement pour
      // confirmer qu'il est toujours humain. Si son modèle était mort, sa
      // mutation aurait déjà eu lieu instantanément (voir _applyDeath) et
      // son rôle ne serait plus enfantSauvage — donc hasAliveRole serait
      // déjà faux et cette phase ne serait pas ajoutée.
      q.add(GamePhase.nightEnfantSauvageCheck);
      addSleep();
    }

    if (s.hasAliveRole(RoleId.salvateur) && !_isAsleep(s, RoleId.salvateur)) {
      q.add(GamePhase.nightSalvateur);
      addSleep();
    }
    if (s.hasAliveRole(RoleId.voyante) && !_isAsleep(s, RoleId.voyante)) {
      q.add(GamePhase.nightVoyante);
      addSleep();
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
      // Un seul "tu peux te rendormir" pour tout le bloc des loups (et
      // des rôles qui se réveillent juste après eux) : ces sous-phases
      // s'enchaînent sans qu'on remette tout le monde à dormir entre
      // chacune.
      addSleep();
    }

    if (s.hasAliveRole(RoleId.renard) && !s.renardPowerLost) {
      q.add(GamePhase.nightRenard);
      addSleep();
    }
    if (s.hasAliveRole(RoleId.corbeau)) {
      q.add(GamePhase.nightCorbeau);
      addSleep();
    }

    final sorciereEncorePuissante = !s.sorciereVieUsed || !s.sorciereMortUsed;
    if (s.hasAliveRole(RoleId.sorciere) &&
        sorciereEncorePuissante &&
        s.aliveWolves.isNotEmpty &&
        !_isAsleep(s, RoleId.sorciere)) {
      q.add(GamePhase.nightSorciere);
      addSleep();
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
      _logSkippedPhase(s, s.phaseQueue[s.phaseIndex]);
      s.phaseIndex++;
    }
    if (s.phaseIndex < s.phaseQueue.length) {
      _goToPhase(s, s.phaseQueue[s.phaseIndex]);
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
      _goToPhase(s, s.phaseQueue[s.phaseIndex]);
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

  void confirmEnfantSauvageCheck(GameState s) => advance(s);

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
    _startRound(s, 'day', s.day);
    s.phaseQueue = [GamePhase.dayReveal];
    s.phaseIndex = 0;
    _goToPhase(s, GamePhase.dayReveal);
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
    _goToPhase(s, s.phaseQueue[1]);
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
      _goToPhase(s, GamePhase.endGame);
      return;
    }
    if (s.chasseurRevengeTargetId != null) {
      _goToPhase(s, GamePhase.chasseurRevange);
      return;
    }
    if (s.mayorSuccessionNeededFor != null) {
      _goToPhase(s, GamePhase.successionMaire);
      return;
    }
    if (s.enfantSauvageTransformedId != null) {
      _goToPhase(s, GamePhase.enfantsauvageReveal);
      return;
    }
    if (s.powerLossThisWave.isNotEmpty) {
      _goToPhase(s, GamePhase.villagePowerLoss);
      return;
    }
    if (s.servanteDevoueeOfferId != null) {
      _goToPhase(s, GamePhase.servanteDevouee);
      return;
    }
    if (s.boucEmissaireChoiceNeededId != null) {
      _goToPhase(s, GamePhase.boucEmissaire);
      return;
    }
    if (s.idiotDuVillageRevealId != null) {
      _goToPhase(s, GamePhase.idiotduvillageCivicRightLoss);
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
 