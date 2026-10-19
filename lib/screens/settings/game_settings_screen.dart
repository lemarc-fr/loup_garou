import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/setting_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/game_settings.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart' show SettingsProvider;
import '../../theme/app_theme.dart';
import '../../widgets/confirm.dart';

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
///
/// Les règles sont rangées par rubrique (voir [SettingCategory]), repliées
/// sauf la première, pour que l'écran tienne en un coup d'œil.
///
/// Ouvert depuis une partie ([inGame]) : seules les options
/// [GameSettingDefinition.liveInGame] s'appliquent tout de suite à la
/// partie en cours ; les autres sont enregistrées pour la suivante, avec un
/// avertissement. Un compteur rappelle combien de fois on a changé un
/// réglage pendant la partie.
class GameSettingsScreen extends StatelessWidget {
  final bool inGame;

  const GameSettingsScreen({super.key, this.inGame = false});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.gameSettingsTitle)),
      body: SafeArea(
        child: !sp.loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (inGame) ...[
                    const _ChangeCounter(),
                    const SizedBox(height: 10),
                    const _InGameNotice(),
                    const SizedBox(height: 16),
                  ],
                  _SectionTitle(loc.settingsAppSectionTitle),
                  const _LanguageCard(),
                  const SizedBox(height: 10),
                  const _SoundCard(),
                  const SizedBox(height: 24),
                  _SectionTitle(loc.settingsGameRulesSectionTitle),
                  for (final category in SettingCategory.values)
                    if (_definitions(category).isNotEmpty) ...[
                      _RuleCategoryCard(
                        category: category,
                        definitions: _definitions(category),
                        inGame: inGame,
                      ),
                      const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final ok = await confirmAction(
                          context,
                          title: loc.settingsResetRulesDialogTitle,
                          message: loc.settingsResetRulesDialogMessage,
                          confirmLabel: loc.settingsResetRulesConfirmLabel,
                        );
                        if (!ok) return;
                        final before = {
                          for (final d in kGameSettingDefinitions)
                            d.id: sp.get(d.id),
                        };
                        await sp.resetRules();
                        if (!inGame || !context.mounted) return;
                        final gp = context.read<GameProvider>();
                        for (final d in kGameSettingDefinitions) {
                          if (sp.get(d.id) != before[d.id]) {
                            gp.applySettingChange(d.id, sp.get(d.id));
                          }
                        }
                      },
                      icon: const Icon(Icons.restart_alt, size: 20),
                      label: Text(loc.settingsResetRulesButton),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<GameSettingDefinition> _definitions(SettingCategory category) => [
        for (final def in kGameSettingDefinitions)
          if (def.category == category) def,
      ];
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

/// Nombre de changements de réglages faits pendant la partie en cours.
class _ChangeCounter extends StatelessWidget {
  const _ChangeCounter();

  @override
  Widget build(BuildContext context) {
    final count = context.select<GameProvider, int>(
        (gp) => gp.state?.settingsChangeCount ?? 0);
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history,
            size: 18, color: count > 0 ? AppColors.lantern : AppColors.moonlight),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.settingsChangeCount(count),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: count > 0 ? AppColors.lantern : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _InGameNotice extends StatelessWidget {
  const _InGameNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lantern.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lantern.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.lantern),
          const SizedBox(width: 10),
          Expanded(
            child: Text(AppLocalizations.of(context)!.settingsInGameNotice,
                style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Une rubrique de règles, repliable.
class _RuleCategoryCard extends StatelessWidget {
  final SettingCategory category;
  final List<GameSettingDefinition> definitions;
  final bool inGame;

  const _RuleCategoryCard({
    required this.category,
    required this.definitions,
    required this.inGame,
  });

  static IconData _icon(SettingCategory category) => switch (category) {
        SettingCategory.night => Icons.nights_stay,
        SettingCategory.wolves => Icons.pets,
        SettingCategory.witch => Icons.science,
        SettingCategory.hunter => Icons.gps_fixed,
        SettingCategory.vote => Icons.how_to_vote,
        SettingCategory.otherRoles => Icons.groups,
      };

  Future<void> _onChanged(
      BuildContext context, GameSettingDefinition def, bool value) async {
    final sp = context.read<SettingsProvider>();
    if (inGame) {
      context.read<GameProvider>().applySettingChange(def.id, value);
      if (!def.liveInGame) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(loc.settingsNextGameWarning(loc.settingLabel(def.id))),
          ));
      }
    }
    await sp.setValue(def.id, value);
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        // La première rubrique (nuit et annonces) est ouverte d'emblée.
        initiallyExpanded: category == SettingCategory.values.first,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(_icon(category), color: AppColors.lantern),
        title: Text(loc.settingCategoryLabel(category),
            style: theme.textTheme.titleMedium),
        childrenPadding: const EdgeInsets.only(bottom: 6),
        children: [
          for (final def in definitions)
            SwitchListTile(
              value: sp.get(def.id),
              onChanged: (v) => _onChanged(context, def, v),
              title: Text.rich(
                TextSpan(children: [
                  TextSpan(text: loc.settingLabel(def.id)),
                  if (inGame && def.liveInGame)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Tooltip(
                        message: loc.settingsLiveInGameTooltip,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.bolt,
                              size: 18, color: AppColors.lantern),
                        ),
                      ),
                    ),
                ]),
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(loc.settingDescription(def.id),
                    style: theme.textTheme.bodyMedium),
              ),
            ),
        ],
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
                  // Libellé court, sans icône : il tient sur une ligne.
                  ButtonSegment(
                    value: _system,
                    label: Text(loc.settingsLanguageSystemShort,
                        maxLines: 1, softWrap: false),
                  ),
                  for (final entry in _languageNames.entries)
                    if (supported.contains(entry.key))
                      ButtonSegment(
                        value: entry.key,
                        label: Text(entry.value, maxLines: 1, softWrap: false),
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

/// Son de la nuit : voix du narrateur, musique d'ambiance et bruitages
/// (voir NarrationHost). Les volumes s'entendent changer pendant la partie.
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
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
            _VolumeSlider(
              label: loc.settingsSoundMusicVolumeLabel,
              icon: Icons.volume_up,
              value: sp.musicVolume,
              enabled: sp.musicEnabled,
              onChanged: sp.setMusicVolume,
              onChangeEnd: (_) => sp.saveSound(),
            ),
            const Divider(indent: 16, endIndent: 16, height: 24),
            _VolumeSlider(
              label: loc.settingsSoundSfxVolumeLabel,
              description: loc.settingsSoundSfxDescription,
              icon: Icons.campaign,
              value: sp.sfxVolume,
              onChanged: sp.setSfxVolume,
              onChangeEnd: (_) => sp.saveSound(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  final String label;
  final String? description;
  final IconData icon;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _VolumeSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
    this.description,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = '${(value * 100).round()} %';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.lantern),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label, style: theme.textTheme.titleMedium),
              ),
              Text(percent, style: theme.textTheme.bodyMedium),
            ],
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Text(description!, style: theme.textTheme.bodyMedium),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Slider(
              value: value,
              divisions: 20,
              label: percent,
              semanticFormatterCallback: (_) => percent,
              onChanged: enabled ? onChanged : null,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }
}
