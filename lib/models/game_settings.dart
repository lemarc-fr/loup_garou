/// Identifiant unique de chaque option de jeu. Pour ajouter une nouvelle
/// option : ajoute une valeur ici, puis une entrée dans
/// [kGameSettingDefinitions] juste en dessous. C'est tout — l'écran
/// d'options, la persistance et l'accès via SettingsProvider suivent
/// automatiquement.
enum SettingId {
  allowWerewolfToKillThemselves,
  allowHunterToShootAfterWitchDeathCause,
}

/// Décrit une option pour l'affichage dans l'écran de réglages.
class GameSettingDefinition {
  final SettingId id;
  final String label;
  final String description;
  final bool defaultValue;

  const GameSettingDefinition({
    required this.id,
    required this.label,
    required this.description,
    this.defaultValue = false,
  });
}

/// Catalogue de toutes les options disponibles. L'ordre ici est l'ordre
/// d'affichage dans l'écran de réglages.
const List<GameSettingDefinition> kGameSettingDefinitions = [
  GameSettingDefinition(
    id: SettingId.allowWerewolfToKillThemselves,
    label: 'Les Loups peuvent se dévorer entre eux',
    description:
    'Si activé, un Loup-Garou peut être désigné comme victime par ses '
        'coéquipiers pendant la phase des Loups.',
    defaultValue: false,
  ),
  GameSettingDefinition(
    id: SettingId.allowHunterToShootAfterWitchDeathCause,
    label: 'Le Chasseur peut tirer si il est tué par la sorcière',
    description:
        'Si activé, le Chasseur peut utiliser son pouvoir de tir après que la Sorcière l\'ait tué.',
    defaultValue: false,
  )
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

  // Raccourcis typés pratiques, un par option — optionnel mais confortable
  // à l'usage dans le reste du code.
  bool get allowWerewolfToKillThemselves =>
      get(SettingId.allowWerewolfToKillThemselves);

  bool get allowHunterToShootAfterWitchDeathCause => get(SettingId.allowHunterToShootAfterWitchDeathCause);

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