import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/player_stats.dart';
import '../services/storage_service.dart';

class StatsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<PlayerStats> _stats = [];
  bool loaded = false;

  List<PlayerStats> get stats =>
      List.unmodifiable(_stats..sort((a, b) => b.wins.compareTo(a.wins)));

  Future<void> load() async {
    _stats = await _storage.loadAllStats();
    loaded = true;
    notifyListeners();
  }

  PlayerStats _statsFor(String name) {
    final key = name.trim();
    return _stats.firstWhere(
      (s) => s.name.toLowerCase() == key.toLowerCase(),
      orElse: () {
        final created = PlayerStats(name: key);
        _stats.add(created);
        return created;
      },
    );
  }

  /// Enregistre le résultat d'une partie terminée pour chaque joueur.
  Future<void> recordGameResult(GameState finalState) async {
    final result = finalState.result;
    if (result == null) return;

    for (final player in finalState.players) {
      final won = result.winner == WinnerType.amoureux
          ? result.winningPlayerIds.contains(player.id)
          : player.camp.name ==
              (result.winner == WinnerType.village ? 'village' : 'loups');

      final entry = GameHistoryEntry(
        date: finalState.startedAt,
        role: player.role,
        won: won,
        playerCountInGame: finalState.players.length,
        deathCause: player.deathCause,
      );
      _statsFor(player.name).history.add(entry);
    }

    await _storage.saveAllStats(_stats);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _stats = [];
    await _storage.saveAllStats(_stats);
    notifyListeners();
  }
}
