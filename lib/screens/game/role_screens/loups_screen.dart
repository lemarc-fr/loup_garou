import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class LoupsScreen extends StatelessWidget {
  const LoupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassDeviceGate(
      toName: 'Loups-Garous',
      pluralToName: true,
      subtitle:
      'Réveillez-vous et mettez-vous d\'accord en silence sur votre victime.',
      accent: AppColors.blood,
      contentBuilder: (_) => const _LoupsContent(),
    );
  }
}

class _LoupsContent extends StatelessWidget {
  const _LoupsContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;

    final wolfIds = state.aliveWolves.map((w) => w.id).toSet();
    final targets = state.settings.allowWerewolfToKillThemselves
        ? state.alivePlayers
        : state.alivePlayers.where((p) => !wolfIds.contains(p.id)).toList();

    return RoleScreenFrame(
      title: 'Les Loups-Garous',
      accent: AppColors.blood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RoleInstructionCard(
            text: 'Mettez-vous d’accord en silence, puis désignez votre victime.',
            accent: AppColors.blood,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: targets,
                  onSelect: (id) => gp.setLoupsVictim(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}