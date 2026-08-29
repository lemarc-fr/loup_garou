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

  //premiere nuit
  nightVoleur,
  nightCupidon,
  nightEnfantSauvage,

  nightSalvateur,
  nightVoyante,
  nightPetiteFille,
  nightLoups,
  nightLoupBlanc,
  nightGrandMechantLoup,
  nightInfectPereDesLoups,
  nightSorciere,
  nightRenard,

  chasseurRevange,
  successionMaire,
  enfantsauvageReveal,

  // Jour
  dayReveal,

  mayorElectionExplain,
  mayorElection,
  mayorReveal,

  debate,
  villageVote,
  voteResult,

  villagePowerLoss,
  servanteDevouee,
  boucEmissaire,
  idiotduvillageCivicRightLoss,
  // successionMaire si tué par le vote

  // Fin
  endGame,
}


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

  bool sorciereVieUsed = false;
  bool sorciereMortUsed = false;
  String? sorciereSavedIdTonight;
  String? sorciereKilledIdTonight;

  String? voleurSwapChoice; // roleId.name choisi, ou 'keep'
  List<RoleId> voleurTableCards = [];

  List<String> loversIds = []; // 0 ou 2 ids

  // Morts survenues pendant la vague en cours (nuit ou vote), pas encore révélées.
  List<String> deathsThisWave = [];

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

  List<Player> get aliveWolves =>
      alivePlayers.where((p) => p.camp == Camp.loups).toList();
  List<Player> get aliveVillagers =>
      alivePlayers.where((p) => p.camp == Camp.village).toList();

  get deathbyvillagevote => null;

  String get renardTarget => null;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
