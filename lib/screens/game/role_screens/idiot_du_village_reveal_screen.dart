import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

class IdiotDuVillageRevealScreen extends StatelessWidget {
  const IdiotDuVillageRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final idiot = state.byId(state.idiotDuVillageRevealId!);
    final info = idiot.role.info;

    return RoleScreenFrame(
      title: "L'Idiot du Village",
      accent: info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text:
                'Le village a voté contre ${idiot.name}, mais il révèle son rôle et survit.',
            accent: info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                RoleImage(role: idiot.role, size: 120),
                const SizedBox(height: 16),
                Text(
                  info.name,
                  style:
                      theme.textTheme.displayMedium?.copyWith(color: info.accent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${idiot.name} perd définitivement son droit de vote.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gp.confirmIdiotDuVillageReveal,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}