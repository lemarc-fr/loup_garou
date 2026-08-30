import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

class ServanteDevoueeScreen extends StatelessWidget {
  const ServanteDevoueeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'La Servante Dévouée',
      subtitle: 'C\'est le rôle de la Servante Dévouée. Réveille-toi.',
      accent: RoleId.servanteDevouee.info.accent,
      contentBuilder: (_) => const _ServanteDevoueeContent(),
    );
  }
}

class _ServanteDevoueeContent extends StatelessWidget {
  const _ServanteDevoueeContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);
    final offered = gp.servanteDevoueeOfferedPlayer;

    // Filet de sécurité : ne devrait pas arriver si la phase n'est
    // déclenchée que lorsque GameState.servanteDevoueeOfferId est posé.
    if (offered == null) {
      return RoleScreenFrame(
        title: 'La Servante Dévouée',
        accent: RoleId.servanteDevouee.info.accent,
        child: Center(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => gp.setServanteDevoueeChoice(false),
              child: const Text('Continuer'),
            ),
          ),
        ),
      );
    }

    final info = offered.role.info;

    return RoleScreenFrame(
      title: 'La Servante Dévouée',
      accent: RoleId.servanteDevouee.info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text:
                '${offered.name} vient d\'être éliminé(e). Veux-tu prendre son rôle ?',
            accent: RoleId.servanteDevouee.info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                RoleImage(role: offered.role, size: 100),
                const SizedBox(height: 16),
                Text(
                  info.name,
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: info.accent),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => gp.setServanteDevoueeChoice(true),
              child: const Text('Oui, prendre ce rôle'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => gp.setServanteDevoueeChoice(false),
              child: const Text('Non, rester Servante Dévouée'),
            ),
          ),
        ],
      ),
    );
  }
}