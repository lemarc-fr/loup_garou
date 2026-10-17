import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: loc.roleLoupGarouPlural,
      pluralToName: true,
      subtitle: loc.loupsSubtitle,
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
    final loc = AppLocalizations.of(context)!;

    // Le Loup Blanc fait partie de la meute : il est protégé comme les
    // autres quand les loups ne peuvent pas se dévorer entre eux.
    final targets = state.settings.allowWerewolfToKillThemselves
        ? state.alivePlayers
        : state.alivePlayers
            .where((p) => !state.isWolfPackMember(p))
            .toList();

    return RoleScreenFrame(
      title: loc.loupsTitle,
      accent: AppColors.blood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: loc.loupsInstruction,
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
          // Il ne reste que des loups (le Loup Blanc empêche leur victoire)
          // et ils ne peuvent pas s'entre-dévorer : pas de victime.
          if (targets.isEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => gp.setLoupsVictim(null),
              child: Text(loc.loupsNoPossibleVictimButton),
            ),
          ],
        ],
      ),
    );
  }
}