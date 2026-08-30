import 'game_config.dart';
import 'game_settings.dart';
import 'player.dart';
import 'role.dart';

/// Toutes les phases possibles de la machine à états du jeu.
enum GamePhase {
  // Configuration (avant la partie)
  setupPlayerCount,
  setupRoles,
  setupNames,
  roleReveal,

  // Nuit
  nightIntro,
  nightVoleur,
  nightCupidon,
  nightEnfantSauvage,
  nightSalvateur,
  nightVoyante,
  nightLoups,
  nightPetiteFille,
  nightLoupBlanc,
  nightGrandMechantLoup,
  nightEnfantSauvageCheck,
  nightInfectPereDesLoups,
  nightRenard,
  nightCorbeau,
  nightSorciere,

  // Suites déclenchées par une mort. Il n'y a plus de file générique
  // d'actions en attente : chaque mort pose un flag précis sur le
  // GameState (chasseurRevengeTargetId, mayorSuccessionNeededFor,
  // enfantSauvageTransformedId, ...) et GameEngine._resolveFollowUps
  // regarde ces flags, dans un ordre fixe, pour savoir sur quelle phase
  // basculer. Voir game_engine.dart pour le détail.
  chasseurRevange,
  successionMaire,
  enfantsauvageReveal,

  // Jour
  dayReveal,
  mayorElectionExplain,
  mayorElection,
  mayorReveal,
  debate,
  jugeBegueDecision,
  villageVote,
  voteResult,

  villagePowerLoss,
  servanteDevouee,
  boucEmissaire,
  idiotduvillageCivicRightLoss,

  // Fin
  endGame,
}

/// D'où viennent les morts en cours de résolution (nuit ou vote) : permet
/// à [GameEngine._resolveFollowUps] de savoir quoi faire une fois que
/// tous les flags de suivi ont été traités.
enum FollowUpOrigin { nightDeaths, voteDeaths }

/// Un villageois qui vient de perdre son pouvoir suite à l'exécution
/// erronée de l'Ancien. On garde son ancien rôle pour l'animation de
/// révélation, même si Player.role a déjà basculé sur simpleVillageois.
class PowerLossEntry {
  final String playerId;
  final RoleId previousRole;
  const PowerLossEntry(this.playerId, this.previousRole);
}

class GameResult {
  final Camp winner;
  final List<String> winningPlayerIds;
  const GameResult(this.winner, this.winningPlayerIds);
}

class GameState {
  final String id;
  final DateTime startedAt;
  final GameConfig config;
  final List<Player> players;
  final GameSettings settings;

  int night = 1;
  int day = 0;
  GamePhase phase;
  String currentWave = 'night'; // 'night' ou 'day'

  List<GamePhase> phaseQueue = [];
  int phaseIndex = 0;

  String? mayorId;
  bool ancienExtraLifeUsed = false;
  List<PowerLossEntry> powerLossThisWave = [];

  // --- Loups ---
  String? loupsVictimId; // victime "officielle" désignée par les loups
  String? grandMechantLoupSecondVictimId;
  bool infectPereDesLoupsUsed = false;
  String? infectedTonightId;
  String? loupBlancVictimId;

  // --- Protections / substitutions ---
  String? salvateurProtectedId; // choix de cette nuit
  String? salvateurLastProtectedId; // choix de la nuit précédente
  bool petiteFilleTriedTonight = false;
  bool petiteFilleCaughtTonight = false;
  String? finalNightVictimId; // victime réelle, après protections/substitutions

  // --- Sorcière ---
  bool sorciereVieUsed = false;
  bool sorciereMortUsed = false;
  String? sorciereSavedIdTonight;
  String? sorciereKilledIdTonight;

  // --- Voleur / Cupidon ---
  List<RoleId> voleurTableCards = [];
  List<String> loversIds = []; // 0 ou 2 ids

  // --- Renard / Corbeau / Juge Bègue ---
  List<String> renardTargetIds = [];
  bool? renardFoundWolfLastQuery;
  bool renardPowerLost = false;
  String? corbeauCursedId;
  bool jugeBegueUsed = false;
  bool voteReplayPending = false;

  // --- Bouc Émissaire / Idiot du Village ---
  String? skippedNextNightPlayerId;
  Set<String> disenfranchisedPlayerIds = {};

  // --- Morts de la vague en cours (nuit ou vote), pas encore révélées ---
  List<String> deathsThisWave = [];

  // --- Flags de suivi post-mort ---
  // C'est le cœur du remplacement de l'ancienne file "pendingActions" :
  // _applyDeath() pose ces flags dès qu'une mort a une conséquence
  // différée, et GameEngine._resolveFollowUps() les lit dans un ordre
  // fixe pour décider de la prochaine phase — un simple enchaînement de
  // "if", pas de queue générique.
  FollowUpOrigin? followUpOrigin;
  String? chasseurRevengeTargetId; // id du Chasseur qui doit tirer
  String? mayorSuccessionNeededFor; // id de l'ancien maire, mort
  String? enfantSauvageTransformedId; // id de l'Enfant Sauvage venant de muter
  RoleId? enfantSauvagePreviousRole; // pour l'animation de révélation
  String? servanteDevoueeOfferId; // id du joueur mort dont le rôle est disponible
  String? boucEmissaireChoiceNeededId; // id du Bouc Émissaire qui vient d'être voté
  String? idiotDuVillageRevealId; // id de l'Idiot qui vient d'être voté (survit)

  GameResult? result;

  GameState({
    required this.id,
    required this.startedAt,
    required this.config,
    required this.players,
    required this.settings,
    this.phase = GamePhase.roleReveal,
  });

  Player byId(String id) => players.firstWhere((p) => p.id == id);
  Player? tryById(String? id) =>
      id == null ? null : players.where((p) => p.id == id).firstOrNull;

  List<Player> get alivePlayers => players.where((p) => p.alive).toList();
  List<Player> alivePlayersWithRole(RoleId role) =>
      alivePlayers.where((p) => p.role == role).toList();
  bool hasAliveRole(RoleId role) => alivePlayersWithRole(role).isNotEmpty;
  bool gameHasRole(RoleId role) => players.any((p) => p.role == role);

  /// Joueurs vivants pouvant participer aux votes. L'Idiot du Village,
  /// une fois démasqué, en a perdu le droit — mais reste éligible en tant
  /// que candidat.
  List<Player> get eligibleVoters => alivePlayers
      .where((p) => !disenfranchisedPlayerIds.contains(p.id))
      .toList();

  List<Player> get aliveWolves =>
      alivePlayers.where((p) => p.camp == Camp.loups).toList();
  List<Player> get aliveVillagers =>
      alivePlayers.where((p) => p.camp == Camp.village).toList();

  /// Vrai tant qu'aucun membre du camp des Loups n'est mort — condition
  /// d'activation du pouvoir du Grand Méchant Loup.
  bool get wolfPackIntact =>
      players.where((p) => p.camp == Camp.loups).every((p) => p.alive);

  /// Vrai si un Loup-Garou se trouve parmi les voisins vivants (immédiats,
  /// dans l'ordre de la liste des joueurs) du Montreur d'Ours.
  bool get montreurDoursGrowls {
    if (!hasAliveRole(RoleId.montreurDours)) return false;
    final bear = alivePlayersWithRole(RoleId.montreurDours).first;
    final ordered = alivePlayers;
    final idx = ordered.indexOf(bear);
    if (idx == -1 || ordered.length < 2) return false;
    final left = ordered[(idx - 1 + ordered.length) % ordered.length];
    final right = ordered[(idx + 1) % ordered.length];
    return left.camp == Camp.loups || right.camp == Camp.loups;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}