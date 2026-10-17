import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

/// Le joueur infecté la nuit précédente par l'Infect Père des Loups
/// l'apprend en secret, juste avant de se réveiller pour la première fois
/// avec la meute. Même principe que la mutation secrète de l'Enfant Sauvage
/// (voir EnfantSauvageMutationScreen).
class InfectedRevealScreen extends StatelessWidget {
  const InfectedRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<GameProvider>().state!;
    final player = state.byId(state.infectedRevealPendingId!);

    return PassDeviceGate(
      toName: player.name,
      accent: AppColors.blood,
      contentBuilder: (_) => const _InfectedRevealContent(),
    );
  }
}

class _InfectedRevealContent extends StatelessWidget {
  const _InfectedRevealContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final player = state.byId(state.infectedRevealPendingId!);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    // Avec le réglage « l'infecté garde son pouvoir », son rôle reste le
    // même ; sinon il est devenu Loup-Garou.
    final keepsPower = player.infected;

    return RoleScreenFrame(
      title: loc.infectedRevealTitle,
      accent: AppColors.blood,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: loc.infectedRevealInstruction,
            accent: AppColors.blood,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                const RoleImage(role: RoleId.loupGarou, size: 120),
                const SizedBox(height: 16),
                Text(
                  loc.roleName(RoleId.loupGarou),
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: context.readable(AppColors.blood)),
                  textAlign: TextAlign.center,
                ),
                if (keepsPower) ...[
                  const SizedBox(height: 12),
                  Text(
                    loc.infectedRevealKeepsPower(loc.roleName(player.role)),
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gp.confirmInfectedReveal,
              child: Text(loc.goBackToSleepButton),
            ),
          ),
        ],
      ),
    );
  }
}
