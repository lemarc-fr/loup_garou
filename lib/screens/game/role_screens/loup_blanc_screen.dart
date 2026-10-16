import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class LoupBlancScreen extends StatelessWidget {
  const LoupBlancScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: loc.roleName(RoleId.loupBlanc),
      pluralToName: false,
      subtitle: loc.loupBlancSubtitle,
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
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.loupBlancTitle,
      accent: AppColors.blood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: loc.loupBlancInstruction,
            accent: AppColors.blood,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                // Il ne peut éliminer qu'un autre Loup-Garou (lui-même est
                // du camp « seul », donc absent de aliveWolves).
                child: PlayerGridSelector(
                  players: gp.state!.aliveWolves,
                  onSelect: (id) => gp.setLoupBlancVictim(id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => gp.setLoupBlancVictim(null),
              child: Text(loc.skipPowerThisNightButton),
            ),
          ),
        ],
      ),
    );
  }
}