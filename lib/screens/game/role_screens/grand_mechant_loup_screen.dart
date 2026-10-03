import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class GrandMechantLoupScreen extends StatelessWidget {
  const GrandMechantLoupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.grandMechantLoup.info.name,
      subtitle: loc.grandMechantLoupSubtitle,
      accent: AppColors.blood,
      contentBuilder: (_) => const _GrandMechantLoupContent(),
    );
  }
}

class _GrandMechantLoupContent extends StatelessWidget {
  const _GrandMechantLoupContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final firstVictim = state.tryById(state.loupsVictimId);
    final loc = AppLocalizations.of(context)!;

    final targets = state.alivePlayers
        .where((p) => p.id != state.loupsVictimId)
        .where((p) =>
    state.settings.allowWerewolfToKillThemselves ||
        p.camp != Camp.loups)
        .toList();

    return RoleScreenFrame(
      title: loc.grandMechantLoupTitle,
      accent: AppColors.blood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: firstVictim != null
                ? loc.grandMechantLoupInstructionWithVictim(firstVictim.name)
                : loc.grandMechantLoupInstructionNoVictim,
            accent: AppColors.blood,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: targets,
                  onSelect: (id) => gp.resolveGrandMechantLoup(id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => gp.resolveGrandMechantLoup(null),
              child: Text(loc.skipPowerThisNightButton),
            ),
          ),
        ],
      ),
    );
  }
}