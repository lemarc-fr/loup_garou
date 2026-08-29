import 'package:flutter/foundation.dart';
import '../models/game_config.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
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

  void resolveSorciere({bool useVie = false, String? poisonTargetId}) {
    engine.resolveSorciere(state!,
        useVie: useVie, poisonTargetId: poisonTargetId);
    notifyListeners();
  }

  void advanceGeneric() {
    engine.advance(state!);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Actions différées
  // ---------------------------------------------------------------------

  void resolvePendingAction(
      {String? hunterTargetId, String? mayorSuccessorId}) {
    engine.resolvePendingAction(
      state!,
      hunterTargetId: hunterTargetId,
      mayorSuccessorId: mayorSuccessorId,
    );
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

  void confirmDebate() {
    engine.confirmDebate(state!);
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

  void confirmPowerLossReveal() {
    engine.confirmPowerLossReveal(state!);
    notifyListeners();
  }

  void confirmMayorReveal() {
    engine.confirmMayorReveal(state!);
    notifyListeners();
  }
  void confirmMayorElectionExplain() {
    engine.confirmMayorElectionExplain(state!);
    notifyListeners();
  }
  void setHunterTarget(String targetId) {}

  void setBoucEmissaireTarget(String id) {}

  void setSalvateurTarget(String id) {}

  void setCorbeauVictim(String id) {}

  void setLoupBlancVictim(String id) {}

  void setEnfantSauvageMentor(String id) {}

  void setInfectPereDesLoups(bool bool) {}

  void setJugeBegueTarget(String id) {}

  int getwolfbeside(String id) {}

  void setServanteDevoueeChoice(bool bool) {}

  void setRenardTarget(String id) {}
}
