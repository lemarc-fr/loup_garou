import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class LoupBlancScreen extends StatelessWidget {
  const LoupBlancScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Loup Blanc',
      pluralToName: true,
      subtitle:
      'Choisis ta victime',
      accent: AppColors.blood,
      contentBuilder: (_) => const _LoupBlancContent(),
    );
  }
}

class _LoupBlancContent extends StatelessWidget {
  const _LoupBlancContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return RoleScreenFrame(
      title: 'Le Loup Blanc',
      accent: AppColors.blood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RoleInstructionCard(
            text:
                'Choisis un joueur à éliminer secrètement pendant ton tour.',
            accent: AppColors.blood,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setLoupBlancVictim(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}