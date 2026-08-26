import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/game_settings.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';

class LoupsScreen extends StatelessWidget {
  const LoupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'les Loups-Garous',
      pluralToName: true,
      subtitle:
      'Réveillez-vous et mettez-vous d\'accord en silence sur votre victime.',
      accent: AppColors.blood,
      contentBuilder: (_) => const _LoupsContent(),
    );
  }
}

class _LoupsContent extends StatelessWidget {
  const _LoupsContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);

    // Par défaut les Loups ne peuvent pas se dévorer entre eux ; l'option
    // allowWerewolfToKillThemselves permet de les inclure dans les cibles.
    final wolfIds = state.aliveWolves.map((w) => w.id).toSet();
    final targets = settings.get(SettingId.allowWerewolfToKillThemselves)
        ? state.alivePlayers
        : state.alivePlayers.where((p) => !wolfIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Les Loups-Garous')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Désignez votre victime.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: targets,
                    onSelect: (id) => gp.setLoupsVictim(id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}