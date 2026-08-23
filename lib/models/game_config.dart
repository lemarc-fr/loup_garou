import 'role.dart';

class GameConfig {
  int playerCount;
  Map<RoleId, int> roleCounts;

  GameConfig({required this.playerCount, Map<RoleId, int>? roleCounts})
      : roleCounts = roleCounts ?? defaultRoleCounts(playerCount);

  bool get hasVoleur => (roleCounts[RoleId.voleur] ?? 0) > 0;

  /// Nombre de cartes à distribuer réellement aux joueurs (hors les 2 cartes
  /// supplémentaires posées sur la table pour le Voleur).
  int get cardsForPlayers =>
      roleCounts.entries.fold(0, (sum, e) => sum + e.value) -
      (hasVoleur ? 2 : 0);

  /// Total de cartes attendu dans la sélection (joueurs + 2 cartes "table" si Voleur).
  int get expectedTotalCards => playerCount + (hasVoleur ? 2 : 0);

  bool get isValid => cardsForPlayers == playerCount;

  /// Suggestion raisonnable de répartition selon le nombre de joueurs,
  /// proche des recommandations officielles du jeu.
  static Map<RoleId, int> defaultRoleCounts(int playerCount) {
    final wolves = (playerCount / 4).floor().clamp(1, 8);
    final counts = <RoleId, int>{for (final r in RoleId.values) r: 0};
    counts[RoleId.loupGarou] = wolves;
    int remaining = playerCount - wolves;

    void addIfRoom(RoleId id) {
      if (remaining > 0) {
        counts[id] = 1;
        remaining -= 1;
      }
    }

    if (playerCount >= 6) addIfRoom(RoleId.voyante);
    if (playerCount >= 7) addIfRoom(RoleId.sorciere);
    if (playerCount >= 8) addIfRoom(RoleId.chasseur);
    if (playerCount >= 9) addIfRoom(RoleId.cupidon);
    if (playerCount >= 11) addIfRoom(RoleId.petiteFille);

    counts[RoleId.simpleVillageois] = remaining.clamp(0, 999);
    return counts;
  }
}
