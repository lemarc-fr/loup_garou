import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';

class InfectPereDesLoupsScreen extends StatelessWidget {
  const InfectPereDesLoupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Infect Père des Loups',
      subtitle: 'C\'est ton tour. Réveille-toi seul.',
      accent: RoleId.infectPereDesLoups.info.accent,
      contentBuilder: (_) => const _InfectPereDesLoupsContent(),
    );
  }
}

class _InfectPereDesLoupsContent extends StatelessWidget {
  const _InfectPereDesLoupsContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final victim = state.tryById(state.loupsVictimId);

    return Scaffold(
      appBar: AppBar(title: const Text('Infect Père des Loups')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                victim != null
                    ? 'Les Loups ont désigné ${victim.name}. Veux-tu '
                    'l\'infecter au lieu de le laisser mourir ?'
                    : 'Les Loups n\'ont désigné personne cette nuit.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  victim == null ? null : () => gp.setInfectPereDesLoups(true),
                  child: const Text('Infecter'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => gp.setInfectPereDesLoups(false),
                  child: const Text('Ne pas infecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}