import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';

/// Encapsule toute la persistance locale. Aujourd'hui : SharedPreferences
/// avec une simple liste JSON. Si le volume de données grossit beaucoup
/// (des centaines de joueurs), on pourra migrer vers sqflite/Hive sans
/// changer l'API de cette classe.
class StorageService {
  static const _statsKey = 'thiercelieux.player_stats.v1';

  Future<List<PlayerStats>> loadAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => PlayerStats.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Données corrompues ou format d'une version antérieure : on repart propre
      // plutôt que de faire planter l'app.
      return [];
    }
  }

  Future<void> saveAllStats(List<PlayerStats> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(stats.map((s) => s.toJson()).toList());
    await prefs.setString(_statsKey, raw);
  }
}
