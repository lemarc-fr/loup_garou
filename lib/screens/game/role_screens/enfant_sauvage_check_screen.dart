import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

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
    final info = RoleId.enfantSauvage.info;

    return RoleScreenFrame(
      title: 'L’Enfant Sauvage',
      accent: info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text:
                'Ton modèle est toujours vivant : tu restes un simple villageois sans pouvoir particulier.',
            accent: info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Icon(info.fallbackIcon, size: 64, color: info.accent),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gp.confirmEnfantSauvageCheck,
              child: const Text('Se rendormir'),
            ),
          ),
        ],
      ),
    );
  }
}