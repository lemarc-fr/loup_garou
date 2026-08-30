import 'package:flutter/foundation.dart';
import '../models/game_config.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../services/game_engine.dart';

/// Étape de l'assistant de création de partie, avant qu'un [GameState] existe.
enum SetupStep { playerCount, roles, names, reveal, done }

class GameProvider extends ChangeNotifier {
  final GameEngine engine = GameEngine();

  // --- Assistant de création (setup) ---
  SetupStep setupStep = SetupStep.playerCount;
  int draftPlayerCount = 8;
  GameConfig? draftConfig;
  List<String> draftNames = [];
  int revealIndex = 0; // index du joueur en cours de découverte de rôle
  bool revealCardVisible = false;

  // --- Partie en cours ---
  GameState? state;

  // --- Sélection en cours du Renard : il désigne trois joueurs d'un coup,
  // mais l'UI (PlayerGridSelector) ne renvoie qu'un id à la fois. On
  // accumule donc ici, un tap = ajoute/retire, jusqu'à en avoir trois.
  final List<String> renardDraftSelection = [];

  bool get hasActiveGame => state != null;

  // ---------------------------------------------------------------------
  // Setup : nombre de joueurs
  // ---------------------------------------------------------------------

  void setDraftPlayerCount(int count) {
    draftPlayerCount = count;
    draftConfig = GameConfig(playerCount: count);
    notifyListeners();
  }

  void goToRoleSelection() {
    draftConfig ??= GameConfig(playerCount: draftPlayerCount);
    setupStep = SetupStep.roles;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Setup : sélection des rôles
  // ---------------------------------------------------------------------

  void setRoleCount(RoleId role, int count) {
    if (draftConfig == null) return;
    draftConfig!.roleCounts[role] = count.clamp(0, 99);
    notifyListeners();
  }

  void incrementRole(RoleId role, {int by = 1}) {
    if (draftConfig == null) return;
    final current = draftConfig!.roleCounts[role] ?? 0;
    final cap = role.info.unique ? 1 : 99;
    final next = (current + by).clamp(0, cap);
    draftConfig!.roleCounts[role] = next;
    notifyListeners();
  }

  bool get draftConfigValid => draftConfig?.isValid ?? false;

  void goToNames() {
    draftNames = List.generate(draftConfig!.cardsForPlayers, (_) => '');
    setupStep = SetupStep.names;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Setup : prénoms
  // ---------------------------------------------------------------------

  void setPlayerName(int index, String name) {
    if (index < 0 || index >= draftNames.length) return;
    draftNames[index] = name;
    notifyListeners();
  }

  bool get namesValid =>
      draftNames.length == draftConfig!.cardsForPlayers &&
          draftNames.every((n) => n.trim().isNotEmpty) &&
          draftNames.map((n) => n.trim().toLowerCase()).toSet().length ==
              draftNames.length;

  void confirmNamesAndDeal(GameSettings settings) {
    state = engine.initGame(
      draftConfig!,
      draftNames.map((n) => n.trim()).toList(),
      settings,
    );
    setupStep = SetupStep.reveal;
    revealIndex = 0;
    revealCardVisible = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Setup : révélation des rôles (un joueur à la fois, écran passé de main en main)
  // ---------------------------------------------------------------------

  void showRevealCard() {
    revealCardVisible = true;
    notifyListeners();
  }

  void confirmRevealSeen() {
    revealCardVisible = false;
    if (revealIndex < state!.players.length - 1) {
      revealIndex++;
    } else {
      setupStep = SetupStep.done;
      engine.startFirstNight(state!);
    }
    notifyListeners();
  }

  /// Recommence tout depuis le début (retour à l'accueil).
  void abandonGame() {
    state = null;
    setupStep = SetupStep.playerCount;
    draftConfig = null;
    draftNames = [];
    revealIndex = 0;
    revealCardVisible = false;
    renardDraftSelection.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Actions de nuit — délèguent au moteur puis notifient
  // ---------------------------------------------------------------------

  void resolveVoleur(RoleId? chosen) {
    engine.resolveVoleur(state!, chosen);
    notifyListeners();
  }

  void resolveCupidon(String id1, String id2) {
    engine.resolveCupidon(state!, id1, id2);
    notifyListeners();
  }

  void setEnfantSauvageMentor(String modelId) {
    engine.resolveEnfantSauvageMentor(state!, modelId);
    notifyListeners();
  }

  void setSalvateurTarget(String protectedId) {
    engine.resolveSalvateur(state!, protectedId);
    notifyListeners();
  }

  void confirmVoyanteDone() {
    engine.confirmVoyanteDone(state!);
    notifyListeners();
  }

  void setLoupsVictim(String victimId) {
    engine.setLoupsVictim(state!, victimId);
    notifyListeners();
  }

  void resolvePetiteFille({required bool tried}) {
    engine.resolvePetiteFille(state!, tried: tried);
    notifyListeners();
  }

  /// [targetId] == null si le Loup Blanc renonce à utiliser son pouvoir
  /// cette nuit-là.
  void setLoupBlancVictim(String? targetId) {
    engine.resolveLoupBlanc(state!, targetId);
    notifyListeners();
  }

  /// [secondVictimId] == null si le Grand Méchant Loup renonce à sa
  /// seconde victime cette nuit-là.
  void resolveGrandMechantLoup(String? secondVictimId) {
    engine.resolveGrandMechantLoup(state!, secondVictimId);
    notifyListeners();
  }

  void setInfectPereDesLoups(bool infect) {
    engine.resolveInfectPereDesLoups(state!, infect);
    notifyListeners();
  }

  /// Le Renard désigne trois joueurs d'un coup. Chaque appel ajoute ou
  /// retire [id] de la sélection en cours ; dès que trois joueurs sont
  /// choisis, le pouvoir est résolu automatiquement et on avance de phase.
  void setRenardTarget(String id) {
    if (renardDraftSelection.contains(id)) {
      renardDraftSelection.remove(id);
    } else if (renardDraftSelection.length < 3) {
      renardDraftSelection.add(id);
    }
    if (renardDraftSelection.length == 3) {
      engine.resolveRenard(state!, List.of(renardDraftSelection));
      renardDraftSelection.clear();
    }
    notifyListeners();
  }

  /// Nombre de Loups-Garous trouvés parmi les trois dernières cibles du
  /// Renard, à afficher tant que la nuit n'est pas terminée.
  int get wolvesFoundByRenard {
    final s = state;
    if (s == null) return 0;
    return s.renardTargetIds.where((id) {
      final p = s.tryById(id);
      return p != null && p.camp == Camp.loups;
    }).length;
  }

  void setCorbeauVictim(String targetId) {
    engine.resolveCorbeau(state!, targetId);
    notifyListeners();
  }

  void resolveSorciere({bool useVie = false, String? poisonTargetId}) {
    engine.resolveSorciere(state!,
        useVie: useVie, poisonTargetId: poisonTargetId);
    notifyListeners();
  }

  /// Le Montreur d'Ours n'a aucune action à jouer : son résultat se lit
  /// directement sur l'état. Exposé ici pour éviter à l'UI de dépendre de
  /// GameState directement.
  bool get montreurDoursGrowls => state?.montreurDoursGrowls ?? false;

  void advanceGeneric() {
    engine.advance(state!);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Suites déclenchées par une mort
  // ---------------------------------------------------------------------
  // Il n'y a plus de file générique d'actions en attente côté moteur :
  // chaque flag (chasseurRevengeTargetId, mayorSuccessionNeededFor, ...)
  // a maintenant sa propre méthode de résolution dédiée dans GameEngine.

  void setHunterTarget(String targetId) {
    engine.resolveChasseurRevenge(state!, targetId);
    notifyListeners();
  }

  void resolveMayorSuccession(String successorId) {
    engine.resolveMayorSuccession(state!, successorId);
    notifyListeners();
  }

  void confirmEnfantSauvageReveal() {
    engine.confirmEnfantSauvageReveal(state!);
    notifyListeners();
  }

  void confirmPowerLossReveal() {
    engine.confirmPowerLossReveal(state!);
    notifyListeners();
  }

  /// Joueur dont le rôle est proposé à la Servante Dévouée (celui qui
  /// vient d'être éliminé par le vote), pour affichage côté écran.
  Player? get servanteDevoueeOfferedPlayer =>
      state?.tryById(state!.servanteDevoueeOfferId);

  void setServanteDevoueeChoice(bool takeRole) {
    engine.resolveServanteDevouee(state!, takeRole);
    notifyListeners();
  }

  void setBoucEmissaireTarget(String skippedPlayerId) {
    engine.resolveBoucEmissaireChoice(state!, skippedPlayerId);
    notifyListeners();
  }

  void confirmIdiotDuVillageReveal() {
    engine.confirmIdiotDuVillageReveal(state!);
    notifyListeners();
  }

  void confirmEnfantSauvageCheck() {
    engine.confirmEnfantSauvageCheck(state!);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Jour
  // ---------------------------------------------------------------------

  void confirmDayReveal() {
    engine.confirmDayReveal(state!);
    notifyListeners();
  }

  void resolveMayorElection(String winnerId) {
    engine.resolveMayorElection(state!, winnerId);
    notifyListeners();
  }

  void confirmMayorElectionExplain() {
    engine.confirmMayorElectionExplain(state!);
    notifyListeners();
  }

  void confirmMayorReveal() {
    engine.confirmMayorReveal(state!);
    notifyListeners();
  }

  void confirmDebate() {
    engine.confirmDebate(state!);
    notifyListeners();
  }

  /// [usePower] : le Juge Bègue décide (ou non) que le vote du village
  /// sera rejoué immédiatement. Ce n'est pas un choix de joueur.
  void resolveJugeBegueDecision(bool usePower) {
    engine.resolveJugeBegueDecision(state!, usePower);
    notifyListeners();
  }

  VoteTally tallyVotes(Map<String, String> votes) =>
      engine.tallyVotes(state!, votes);

  void resolveVillageVote(String eliminatedId) {
    engine.resolveVillageVote(state!, eliminatedId);
    notifyListeners();
  }

  void confirmVoteResult() {
    engine.confirmVoteResult(state!);
    notifyListeners();
  }
}