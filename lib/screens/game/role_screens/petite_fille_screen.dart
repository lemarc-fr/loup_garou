import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';

class PetiteFilleScreen extends StatelessWidget {
  const PetiteFilleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final pf = gp.state!.alivePlayersWithRole(RoleId.petiteFille).first;

    return PassDeviceGate(
      toName: pf.name,
      subtitle: 'C\'est le rôle de la Petite Fille. Réveille-toi.',
      accent: RoleId.petiteFille.info.accent,
      contentBuilder: (_) => const _PetiteFilleContent(),
    );
  }
}

class _PetiteFilleContent extends StatelessWidget {
  const _PetiteFilleContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('La Petite Fille')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                RoleId.petiteFille.info.nightInstruction,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Attention : si les Loups-Garous te surprennent, tu prendras la place de leur victime.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.blood),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => gp.resolvePetiteFille(tried: true),
                  child: const Text('Entrouvrir les yeux et espionner'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => gp.resolvePetiteFille(tried: false),
                  child: const Text('Rester sagement endormie'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}