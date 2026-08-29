import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';

class SalvateurScreen extends StatelessWidget {
  const SalvateurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Salvateur-Garous',
      pluralToName: true,
      subtitle:'Reveille-toi et designe ton protégé',
      accent: AppColors.blood,
      contentBuilder: (_) => const _SalvateurContent(),
    );
  }
}

class _SalvateurContent extends StatelessWidget {
  const _SalvateurContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Le Salvateur')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Désignez votre protégé.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: gp.state!.alivePlayers,
                    onSelect: (id) => gp.setSalvateurTarget(id),
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