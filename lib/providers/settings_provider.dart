import 'package:flutter/foundation.dart';
import '../models/game_settings.dart';
import '../services/storage_service.dart';

/// Expose les options de jeu au reste de l'app et les persiste dès qu'une
/// valeur change. À utiliser partout où une règle de jeu doit être
/// consultée (écrans de nuit, moteur de jeu, etc.) via
/// `context.watch<SettingsProvider>().get(SettingId.xxx)`.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  GameSettings settings = GameSettings();
  bool loaded = false;

  Future<void> load() async {
    settings = await _storage.loadSettings();
    loaded = true;
    notifyListeners();
  }

  bool get(SettingId id) => settings.get(id);

  Future<void> setValue(SettingId id, bool value) async {
    settings.set(id, value);
    notifyListeners();
    await _storage.saveSettings(settings);
  }

  bool get allowWerewolfToKillThemselves =>
      settings.allowWerewolfToKillThemselves;
}