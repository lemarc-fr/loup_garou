import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/setting_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/game_settings.dart' show kGameSettingDefinitions;
import '../../providers/settings_provider.dart' show SettingsProvider;
import '../../theme/app_theme.dart';

/// Nom de chaque langue disponible, écrit dans cette langue (on doit
/// pouvoir retrouver la sienne même si l'app est dans une langue qu'on ne
/// lit pas).
const Map<String, String> _languageNames = {
  'fr': 'Français',
  'en': 'English',
};

/// Écran des options de jeu. C'est un écran poussé normalement
/// (Navigator.push) : le bouton retour système et la flèche de l'AppBar
/// le ferment tous les deux sans rien à coder de spécifique.
class GameSettingsScreen extends StatelessWidget {
  const GameSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.gameSettingsTitle)),
      body: SafeArea(
        child: !sp.loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionTitle(loc.settingsAppSectionTitle),
                  const _LanguageCard(),
                  const SizedBox(height: 10),
                  const _SoundCard(),
                  const SizedBox(height: 24),
                  _SectionTitle(loc.settingsGameRulesSectionTitle),
                  for (final def in kGameSettingDefinitions) ...[
                    Card(
                      child: SwitchListTile(
                        value: sp.get(def.id),
                        onChanged: (v) => sp.setValue(def.id, v),
                        title: Text(loc.settingLabel(def.id),
                            style: theme.textTheme.titleMedium),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(loc.settingDescription(def.id),
                              style: theme.textTheme.bodyMedium),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.lantern,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

/// Choix de la langue de l'application : celle du téléphone, ou une
/// langue forcée parmi celles disponibles.
class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  static const _system = '';

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final supported =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate, size: 20, color: AppColors.lantern),
                const SizedBox(width: 10),
                Text(loc.settingsLanguageLabel,
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 4),
            Text(loc.settingsLanguageDescription,
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: _system,
                    icon: const Icon(Icons.phone_android, size: 18),
                    label: Text(loc.settingsLanguageSystem),
                  ),
                  for (final entry in _languageNames.entries)
                    if (supported.contains(entry.key))
                      ButtonSegment(
                        value: entry.key,
                        label: Text(entry.value),
                      ),
                ],
                selected: {sp.locale?.languageCode ?? _system},
                onSelectionChanged: (selection) {
                  final code = selection.first;
                  sp.setLocale(code == _system ? null : Locale(code));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Son de la nuit : voix du narrateur et musique d'ambiance (voir
/// NarrationHost).
class _SoundCard extends StatelessWidget {
  const _SoundCard();

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    Widget toggle({
      required IconData icon,
      required bool value,
      required ValueChanged<bool> onChanged,
      required String label,
      required String description,
    }) =>
        SwitchListTile(
          value: value,
          onChanged: onChanged,
          secondary: Icon(icon, color: AppColors.lantern),
          title: Text(label, style: theme.textTheme.titleMedium),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(description, style: theme.textTheme.bodyMedium),
          ),
        );

    return Card(
      child: Column(
        children: [
          toggle(
            icon: Icons.record_voice_over,
            value: sp.narrationEnabled,
            onChanged: sp.setNarrationEnabled,
            label: loc.settingsSoundNarrationLabel,
            description: loc.settingsSoundNarrationDescription,
          ),
          toggle(
            icon: Icons.music_note,
            value: sp.musicEnabled,
            onChanged: sp.setMusicEnabled,
            label: loc.settingsSoundMusicLabel,
            description: loc.settingsSoundMusicDescription,
          ),
        ],
      ),
    );
  }
}
