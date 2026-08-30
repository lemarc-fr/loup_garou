import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

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
    final selection = gp.renardDraftSelection;

    return RoleScreenFrame(
      title: 'Le Renard',
      accent: RoleId.renard.info.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: 'Choisis trois joueurs voisins (${selection.length}/3).',
            accent: RoleId.renard.info.accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  highlightedIds: selection.toSet(),
                  onSelect: (id) => gp.setRenardTarget(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}