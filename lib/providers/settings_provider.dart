import 'package:flutter/widgets.dart';
import '../models/game_settings.dart';
import '../services/storage_service.dart';

/// Expose les options de jeu au reste de l'app et les persiste dès qu'une
/// valeur change. À utiliser partout où une règle de jeu doit être
/// consultée (écrans de nuit, moteur de jeu, etc.) via
/// `context.watch<SettingsProvider>().get(SettingId.xxx)`.
///
/// Porte aussi la langue de l'application ([locale]), qui n'est pas une
/// règle de jeu mais se règle depuis le même écran.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  GameSettings settings = GameSettings();
  bool loaded = false;

  /// Langue forcée par l'utilisateur, ou null pour suivre celle du
  /// téléphone.
  Locale? locale;

  Future<void> load() async {
    settings = await _storage.loadSettings();
    final code = await _storage.loadLocaleCode();
    locale = code == null ? null : Locale(code);
    loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? value) async {
    locale = value;
    notifyListeners();
    await _storage.saveLocaleCode(value?.languageCode);
  }

  bool get(SettingId id) => settings.get(id);

  Future<void> setValue(SettingId id, bool value) async {
    settings.set(id, value);
    notifyListeners();
    await _storage.saveSettings(settings);
  }

  bool get allowWerewolfToKillThemselves => settings.allowWerewolfToKillThemselves;
  bool get allowHunterToShootAfterWitchDeathCause => settings.allowHunterToShootAfterWitchDeathCause;
  bool get allowWitchToPlayIfWerewolfDeathCause => settings.allowWitchToPlayIfWerewolfDeathCause;
  bool get allowWitchToSaveHerself => settings.allowWitchToSaveHerself;
  bool get enfantSauvagePublicReveal => settings.enfantSauvagePublicReveal;
  bool get randomLoversInsteadOfCupidon => settings.randomLoversInsteadOfCupidon;
}