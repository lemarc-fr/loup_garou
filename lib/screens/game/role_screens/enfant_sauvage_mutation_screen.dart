import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

class EnfantSauvageMutationScreen extends StatelessWidget {
  const EnfantSauvageMutationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final player = state.tryById(state.enfantSauvageNightMutationId);
    final loc = AppLocalizations.of(context)!;

    return PassDeviceGate(
      toName: player?.name ?? loc.enfantSauvagePassTo,
      accent: AppColors.blood,
      contentBuilder: (_) => const _EnfantSauvageMutationContent(),
    );
  }
}

class _EnfantSauvageMutationContent extends StatelessWidget {
  const _EnfantSauvageMutationContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.enfantSauvageMutationTitle,
      accent: AppColors.blood,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: loc.enfantSauvageMutationInstruction,
            accent: AppColors.blood,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                const RoleImage(role: RoleId.loupGarou, size: 120),
                const SizedBox(height: 16),
                Text(
                  RoleId.loupGarou.info.name,
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: AppColors.blood),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gp.confirmEnfantSauvageNightMutation,
              child: Text(loc.goBackToSleepButton),
            ),
          ),
        ],
      ),
    );
  }
}