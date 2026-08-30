import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';

class EnfantSauvageCheckScreen extends StatelessWidget {
  const EnfantSauvageCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: "l'Enfant Sauvage",
      subtitle: 'C\'est le tour de l\'Enfant Sauvage. Réveille-toi.',
      accent: RoleId.enfantSauvage.info.accent,
      contentBuilder: (_) => const _EnfantSauvageCheckContent(),
    );
  }
}

class _EnfantSauvageCheckContent extends StatelessWidget {
  const _EnfantSauvageCheckContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);
    final info = RoleId.enfantSauvage.info;

    return Scaffold(
      appBar: AppBar(title: const Text('Enfant Sauvage')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(info.fallbackIcon, size: 64, color: info.accent),
              const SizedBox(height: 24),
              Text(
                'Ton modèle est toujours vivant : tu es toujours un simple '
                    'villageois, sans pouvoir particulier.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmEnfantSauvageCheck,
                  child: const Text('Se rendormir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}