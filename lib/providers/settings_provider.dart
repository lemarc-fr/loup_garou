import 'package:flutter/widgets.dart';
import '../models/game_settings.dart';
import '../services/storage_service.dart';

/// Expose les options de jeu au reste de l'app et les persiste dès qu'une
/// valeur change. À utiliser partout où une règle de jeu doit être
/// consultée (écrans de nuit, moteur de jeu, etc.) via
/// `context.watch<SettingsProvider>().get(SettingId.xxx)`.
///
/// Porte aussi la langue de l'application ([locale]) et les réglages du son
/// ([narrationEnabled], [musicEnabled], [musicVolume], [sfxVolume]), qui ne
/// sont pas des règles de jeu mais se règlent depuis le même écran.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  GameSettings settings = GameSettings();
  bool loaded = false;

  /// Langue forcée par l'utilisateur, ou null pour suivre celle du
  /// téléphone.
  Locale? locale;

  /// Voix du narrateur pendant la nuit (voir NarrationHost).
  bool narrationEnabled = true;

  /// Musique d'ambiance pendant la nuit.
  bool musicEnabled = true;

  /// Volume de la musique d'ambiance, de 0 à 1.
  double musicVolume = SoundDefaults.musicVolume;

  /// Volume des bruitages (hurlement des loups, chant du coq), de 0 à 1 :
  /// à 0, ils ne sont plus joués.
  double sfxVolume = SoundDefaults.sfxVolume;

  Future<void> load() async {
    settings = await _storage.loadSettings();
    final code = await _storage.loadLocaleCode();
    locale = code == null ? null : Locale(code);
    final sound = await _storage.loadSoundSettings();
    narrationEnabled = sound.narration;
    musicEnabled = sound.music;
    musicVolume = sound.musicVolume;
    sfxVolume = sound.sfxVolume;
    loaded = true;
    notifyListeners();
  }

  Future<void> setNarrationEnabled(bool value) async {
    narrationEnabled = value;
    notifyListeners();
    await _saveSound();
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    notifyListeners();
    await _saveSound();
  }

  /// Appelé à chaque mouvement du curseur : la valeur est appliquée tout
  /// de suite, mais n'est enregistrée qu'au lâcher ([saveSound]).
  void setMusicVolume(double value) {
    musicVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setSfxVolume(double value) {
    sfxVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> saveSound() => _saveSound();

  Future<void> _saveSound() => _storage.saveSoundSettings((
        narration: narrationEnabled,
        music: musicEnabled,
        musicVolume: musicVolume,
        sfxVolume: sfxVolume,
      ));

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

  /// Remet toutes les règles du jeu à leur valeur par défaut (pas la
  /// langue ni le son).
  Future<void> resetRules() async {
    settings.resetToDefaults();
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