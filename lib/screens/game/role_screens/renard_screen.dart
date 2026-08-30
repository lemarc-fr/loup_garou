import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';

class RenardScreen extends StatelessWidget {
  const RenardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Le Renard',
      subtitle: 'C\'est le tour du Renard. Réveille-toi.',
      accent: RoleId.renard.info.accent,
      contentBuilder: (_) => const _RenardContent(),
    );
  }
}

class _RenardContent extends StatelessWidget {
  const _RenardContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final selection = gp.renardDraftSelection;

    return Scaffold(
      appBar: AppBar(title: const Text('Le Renard')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choisis trois joueurs voisins (${selection.length}/3).',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: gp.state!.alivePlayers,
                    highlightedIds: selection.toSet(),
                    onSelect: (id) => gp.setRenardTarget(id),
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