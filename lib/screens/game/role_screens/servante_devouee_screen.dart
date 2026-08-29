import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/role_image.dart';

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
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => gp.setServanteDevoueeChoice(false),
            child: const Text('Continuer'),
          ),
        ),
      );
    }

    final info = offered.role.info;

    return Scaffold(
      appBar: AppBar(title: const Text('La Servante Dévouée')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${offered.name} vient d\'être éliminé(e) par le village.',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              RoleImage(role: offered.role, size: 100),
              const SizedBox(height: 16),
              Text(
                info.name,
                style: theme.textTheme.displayMedium
                    ?.copyWith(color: info.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Veux-tu révéler que tu es la Servante Dévouée et prendre '
                    'ce rôle à sa place ?',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
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
        ),
      ),
    );
  }
}