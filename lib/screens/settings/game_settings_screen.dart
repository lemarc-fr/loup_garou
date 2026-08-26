import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_settings.dart' show kGameSettingDefinitions;
import '../../providers/settings_provider.dart' show SettingsProvider;

/// Écran des options de jeu. C'est un écran poussé normalement
/// (Navigator.push) : le bouton retour système et la flèche de l'AppBar
/// le ferment tous les deux sans rien à coder de spécifique.
class GameSettingsScreen extends StatelessWidget {
  const GameSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Options de jeu')),
      body: SafeArea(
        child: !sp.loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: kGameSettingDefinitions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final def = kGameSettingDefinitions[index];
            return Card(
              child: SwitchListTile(
                value: sp.get(def.id),
                onChanged: (v) => sp.setValue(def.id, v),
                title: Text(def.label,
                    style: theme.textTheme.titleMedium),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(def.description,
                      style: theme.textTheme.bodyMedium),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}