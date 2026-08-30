import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';

class GrandMechantLoupScreen extends StatelessWidget {
  const GrandMechantLoupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Grand Méchant Loup',
      subtitle: 'Réveille-toi seul, les autres Loups peuvent se rendormir.',
      accent: AppColors.blood,
      contentBuilder: (_) => const _GrandMechantLoupContent(),
    );
  }
}

class _GrandMechantLoupContent extends StatelessWidget {
  const _GrandMechantLoupContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final firstVictim = state.tryById(state.loupsVictimId);

    final targets = state.alivePlayers
        .where((p) => p.id != state.loupsVictimId)
        .where((p) =>
    state.settings.allowWerewolfToKillThemselves ||
        p.camp != Camp.loups)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Le Grand Méchant Loup')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                firstVictim != null
                    ? 'Les Loups ont désigné ${firstVictim.name}. Tant '
                    'qu\'aucun Loup n\'est mort, tu peux dévorer une '
                    'seconde victime.'
                    : 'Tant qu\'aucun Loup n\'est mort, tu peux dévorer une '
                    'seconde victime.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: targets,
                    onSelect: (id) => gp.resolveGrandMechantLoup(id),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => gp.resolveGrandMechantLoup(null),
                  child: const Text('Ne pas utiliser mon pouvoir cette nuit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}