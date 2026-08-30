import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class CorbeauScreen extends StatelessWidget {
  const CorbeauScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Corbeau',
      pluralToName: true,
      subtitle:
      'Choisis ta victime',
      accent: AppColors.blood,
      contentBuilder: (_) => const _CorbeauContent(),
    );
  }
}

class _CorbeauContent extends StatelessWidget {
  const _CorbeauContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return RoleScreenFrame(
      title: 'Le Corbeau',
      accent: AppColors.blood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RoleInstructionCard(
            text: 'Désigne un joueur qui recevra deux voix contre lui au vote.',
            accent: AppColors.blood,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setCorbeauVictim(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}