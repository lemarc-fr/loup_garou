import 'game_config.dart';
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
  nightVoyante,
  nightPetiteFille,
  nightLoups,
  nightSorciere,

  // Actions différées déclenchées par une mort (chasseur / succession du maire)
  pendingAction,

  // Jour
  dayReveal,
  mayorElection,
  mayorReveal,
  debate,
  villageVote,
  voteResult,
  villagePowerLoss,

  // Fin
  endGame,
}

enum WinnerType { village, loups, amoureux }

/// Un villageois qui vient de perdre son pouvoir suite à l'exécution
/// erronée de l'Ancien. On garde son ancien rôle pour l'animation de
/// révélation, même si Player.role a déjà basculé sur simpleVillageois.
class PowerLossEntry {
  final String playerId;
  final RoleId previousRole;
  const PowerLossEntry(this.playerId, this.previousRole);
}

class GameResult {
  final WinnerType winner;
  final List<String> winningPlayerIds;
  const GameResult(this.winner, this.winningPlayerIds);
}

/// Une action différée à jouer (vengeance du chasseur, succession du maire)
/// avant de pouvoir révéler publiquement les morts.
class PendingAction {
  final String playerId; // le joueur mort qui doit encore agir
  final bool isHunterRevenge;
  final bool isMayorSuccession;
  const PendingAction({
    required this.playerId,
    this.isHunterRevenge = false,
    this.isMayorSuccession = false,
  });
}

class GameState {
  final String id;
  final DateTime startedAt;
  final GameConfig config;
  final List<Player> players;

  int night = 1;
  int day = 0;
  GamePhase phase;
  String currentWave =
      'night'; // 'night' ou 'day' — pilote la suite après les actions différées

  List<GamePhase> phaseQueue = [];
  int phaseIndex = 0;

  String? mayorId;
  bool ancienExtraLifeUsed =
      false; // vie supplémentaire de l'Ancien face aux Loups
  List<PowerLossEntry> powerLossThisWave = [];

  // --- Données temporaires de la nuit en cours ---
  String? loupsVictimId; // victime désignée par les loups, avant substitution
  String? finalNightVictimId; // victime finale après passage de la petite fille
  bool petiteFilleTriedTonight = false;
  bool petiteFilleCaughtTonight = false;

  bool sorciereVieUsed = false;
  bool sorciereMortUsed = false;
  String? sorciereSavedIdTonight;
  String? sorciereKilledIdTonight;

  String? voleurSwapChoice; // roleId.name choisi, ou 'keep'
  List<RoleId> voleurTableCards = [];

  List<String> loversIds = []; // 0 ou 2 ids

  // File d'actions différées (chasseur / succession maire) à traiter avant
  // de révéler publiquement les morts de cette vague (nuit ou vote).
  List<PendingAction> pendingActions = [];
  // Morts survenues pendant la vague en cours (nuit ou vote), pas encore révélées.
  List<String> deathsThisWave = [];

  GameResult? result;

  GameState({
    required this.id,
    required this.startedAt,
    required this.config,
    required this.players,
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

  List<Player> get aliveWolves =>
      alivePlayers.where((p) => p.camp == Camp.loups).toList();
  List<Player> get aliveVillagers =>
      alivePlayers.where((p) => p.camp == Camp.village).toList();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
