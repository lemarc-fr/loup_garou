/// Identifiant unique de chaque option de jeu. Pour ajouter une nouvelle
/// option : ajoute une valeur ici, une entrée dans [kGameSettingDefinitions]
/// juste en dessous, puis son libellé et sa description dans les fichiers
/// .arb (voir l10n/setting_localizations.dart). L'écran d'options, la
/// persistance et l'accès via SettingsProvider suivent automatiquement.
enum SettingId {
  allowWerewolfToKillThemselves,
  allowHunterToShootAfterWitchDeathCause,
  allowWitchToPlayIfWerewolfDeathCause,
  allowWitchToSaveHerself,
  enfantSauvagePublicReveal,
  randomLoversInsteadOfCupidon,
}

/// Décrit une option pour l'affichage dans l'écran de réglages. Les textes
/// (libellé, description) sont traduits : voir l10n/setting_localizations.dart.
class GameSettingDefinition {
  final SettingId id;
  final bool defaultValue;

  const GameSettingDefinition({
    required this.id,
    this.defaultValue = false,
  });
}

/// Catalogue de toutes les options disponibles. L'ordre ici est l'ordre
/// d'affichage dans l'écran de réglages.
const List<GameSettingDefinition> kGameSettingDefinitions = [
  GameSettingDefinition(
    id: SettingId.allowWerewolfToKillThemselves,
    defaultValue: true,
  ),
  GameSettingDefinition(
    id: SettingId.allowHunterToShootAfterWitchDeathCause,
    defaultValue: true,
  ),
  GameSettingDefinition(
    id: SettingId.allowWitchToPlayIfWerewolfDeathCause,
    defaultValue: true,
  ),
  GameSettingDefinition(
    id: SettingId.allowWitchToSaveHerself,
    defaultValue: true,
  ),
  GameSettingDefinition(
    id: SettingId.enfantSauvagePublicReveal,
    defaultValue: true,
  ),
  // Deux façons de former les Amoureux : Cupidon (désactivé, par défaut)
  // ou un tirage au sort proposé à la répartition des rôles (activé).
  GameSettingDefinition(
    id: SettingId.randomLoversInsteadOfCupidon,
    defaultValue: false,
  ),
];

/// Valeurs courantes des options, avec repli sur la valeur par défaut du
/// catalogue si une option n'a jamais été sauvegardée (ex : après une
/// mise à jour de l'app qui ajoute une nouvelle option).
class GameSettings {
  final Map<SettingId, bool> _values;

  GameSettings({Map<SettingId, bool>? values})
      : _values = values ??
      {for (final d in kGameSettingDefinitions) d.id: d.defaultValue};

  bool get(SettingId id) =>
      _values[id] ??
          kGameSettingDefinitions.firstWhere((d) => d.id == id).defaultValue;

  void set(SettingId id, bool value) => _values[id] = value;

  bool get allowWerewolfToKillThemselves => get(SettingId.allowWerewolfToKillThemselves);
  bool get allowHunterToShootAfterWitchDeathCause => get(SettingId.allowHunterToShootAfterWitchDeathCause);
  bool get allowWitchToPlayIfWerewolfDeathCause => get(SettingId.allowWitchToPlayIfWerewolfDeathCause);
  bool get allowWitchToSaveHerself => get(SettingId.allowWitchToSaveHerself);
  bool get enfantSauvagePublicReveal => get(SettingId.enfantSauvagePublicReveal);
  bool get randomLoversInsteadOfCupidon => get(SettingId.randomLoversInsteadOfCupidon);

  Map<String, dynamic> toJson() => {
    for (final e in _values.entries) e.key.name: e.value,
  };

  static GameSettings fromJson(Map<String, dynamic> json) {
    final values = <SettingId, bool>{};
    for (final d in kGameSettingDefinitions) {
      final raw = json[d.id.name];
      values[d.id] = raw is bool ? raw : d.defaultValue;
    }
    return GameSettings(values: values);
  }
}