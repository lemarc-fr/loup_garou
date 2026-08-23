import 'role.dart';

class GameHistoryEntry {
  final DateTime date;
  final RoleId role;
  final bool won;
  final int playerCountInGame;
  final DeathCause? deathCause; // null si survivant à la fin

  GameHistoryEntry({
    required this.date,
    required this.role,
    required this.won,
    required this.playerCountInGame,
    this.deathCause,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'role': role.name,
        'won': won,
        'playerCountInGame': playerCountInGame,
        'deathCause': deathCause?.name,
      };

  static GameHistoryEntry fromJson(Map<String, dynamic> json) =>
      GameHistoryEntry(
        date: DateTime.parse(json['date'] as String),
        role: RoleId.values.byName(json['role'] as String),
        won: json['won'] as bool,
        playerCountInGame: json['playerCountInGame'] as int,
        deathCause: (json['deathCause'] as String?) == null
            ? null
            : DeathCause.values.byName(json['deathCause'] as String),
      );
}

class PlayerStats {
  final String name;
  List<GameHistoryEntry> history;

  PlayerStats({required this.name, List<GameHistoryEntry>? history})
      : history = history ?? [];

  int get gamesPlayed => history.length;
  int get wins => history.where((h) => h.won).length;
  int get losses => gamesPlayed - wins;
  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed;

  Map<RoleId, int> get roleCounts {
    final m = <RoleId, int>{};
    for (final h in history) {
      m[h.role] = (m[h.role] ?? 0) + 1;
    }
    return m;
  }

  RoleId? get favoriteRole {
    final counts = roleCounts;
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'history': history.map((h) => h.toJson()).toList(),
      };

  static PlayerStats fromJson(Map<String, dynamic> json) => PlayerStats(
        name: json['name'] as String,
        history: (json['history'] as List)
            .map((e) => GameHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
