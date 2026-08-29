import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';

class LoupBlancScreen extends StatelessWidget {
  const LoupBlancScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Loup Blanc',
      pluralToName: true,
      subtitle:
      'Choisis ta victime',
      accent: AppColors.blood,
      contentBuilder: (_) => const _LoupBlancContent(),
    );
  }
}

class _LoupBlancContent extends StatelessWidget {
  const _LoupBlancContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Les Loup Blanc')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Désigne ta victime.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: gp.state!.alivePlayers,
                    onSelect: (id) => gp.setLoupBlancVictim(id),
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