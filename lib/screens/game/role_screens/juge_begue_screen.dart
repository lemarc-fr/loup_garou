import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

/// Le Juge Bègue ne désigne jamais un joueur : une fois par partie, il
/// décide en secret que le vote du village qui va suivre sera rejoué
/// immédiatement une fois terminé (voir GameEngine.resolveJugeBegueDecision
/// et le flag GameState.voteReplayPending).
class JugeBegueScreen extends StatelessWidget {
  const JugeBegueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Le Juge Bègue',
      subtitle:
      'C\'est le tour du Juge Bègue. Personne d\'autre ne doit savoir qui il est.',
      accent: RoleId.jugeBegue.info.accent,
      contentBuilder: (_) => const _JugeBegueContent(),
    );
  }
}

class _JugeBegueContent extends StatelessWidget {
  const _JugeBegueContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final info = RoleId.jugeBegue.info;

    return RoleScreenFrame(
      title: 'Le Juge Bègue',
      accent: info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text:
                'Une fois par partie, tu peux décider en secret que le vote du village sera rejoué immédiatement.',
            accent: info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                Icon(info.fallbackIcon, size: 64, color: info.accent),
                const SizedBox(height: 12),
                Text(
                  'Veux-tu utiliser ce pouvoir maintenant ?',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => gp.resolveJugeBegueDecision(true),
              child: const Text('Utiliser mon pouvoir'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => gp.resolveJugeBegueDecision(false),
              child: const Text('Ne pas utiliser mon pouvoir'),
            ),
          ),
        ],
      ),
    );
  }
}