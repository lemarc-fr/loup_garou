import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class SalvateurScreen extends StatelessWidget {
  const SalvateurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Salvateur',
      subtitle: 'Réveille-toi et désigne ton protégé.',
      accent: RoleId.salvateur.info.accent,
      contentBuilder: (_) => const _SalvateurContent(),
    );
  }
}

class _SalvateurContent extends StatelessWidget {
  const _SalvateurContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return RoleScreenFrame(
      title: 'Le Salvateur',
      accent: RoleId.salvateur.info.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: 'Choisis le joueur protégé contre les attaques de cette nuit.',
            accent: RoleId.salvateur.info.accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setSalvateurTarget(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}