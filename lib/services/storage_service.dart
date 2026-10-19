import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';
import '../models/game_settings.dart';


/// Encapsule toute la persistance locale. Aujourd'hui : SharedPreferences
/// avec une simple liste JSON. Si le volume de données grossit beaucoup
/// (des centaines de joueurs), on pourra migrer vers sqflite/Hive sans
/// changer l'API de cette classe.
class StorageService {
  static const _statsKey = 'thiercelieux.player_stats.v1';
  static const _settingsKey = 'thiercelieux.game_settings.v1';
  static const _localeKey = 'thiercelieux.locale.v1';
  static const _narrationKey = 'thiercelieux.sound.narration.v1';
  static const _musicKey = 'thiercelieux.sound.music.v1';
  static const _musicVolumeKey = 'thiercelieux.sound.music_volume.v1';
  static const _sfxVolumeKey = 'thiercelieux.sound.sfx_volume.v1';


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

  Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return GameSettings();
    try {
      return GameSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Format corrompu ou d'une version antérieure : on repart des
      // valeurs par défaut plutôt que de faire planter l'app.
      return GameSettings();
    }
  }

  Future<void> saveSettings(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// Code de la langue choisie par l'utilisateur ('fr', 'en'...), ou null
  /// pour suivre la langue du téléphone.
  Future<String?> loadLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  Future<void> saveLocaleCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, code);
    }
  }

  /// Réglages du son : voix du narrateur et musique d'ambiance (activées
  /// par défaut), volume de la musique et des bruitages (de 0 à 1).
  Future<SoundSettings> loadSoundSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      narration: prefs.getBool(_narrationKey) ?? true,
      music: prefs.getBool(_musicKey) ?? true,
      musicVolume:
          prefs.getDouble(_musicVolumeKey) ?? SoundDefaults.musicVolume,
      sfxVolume: prefs.getDouble(_sfxVolumeKey) ?? SoundDefaults.sfxVolume,
    );
  }

  Future<void> saveSoundSettings(SoundSettings sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_narrationKey, sound.narration);
    await prefs.setBool(_musicKey, sound.music);
    await prefs.setDouble(_musicVolumeKey, sound.musicVolume);
    await prefs.setDouble(_sfxVolumeKey, sound.sfxVolume);
  }
}

typedef SoundSettings = ({
  bool narration,
  bool music,
  double musicVolume,
  double sfxVolume,
});

/// Volumes par défaut (de 0 à 1). La musique reste discrète : elle ne doit
/// pas couvrir la voix du narrateur.
abstract final class SoundDefaults {
  static const musicVolume = 0.35;
  static const sfxVolume = 1.0;
}
