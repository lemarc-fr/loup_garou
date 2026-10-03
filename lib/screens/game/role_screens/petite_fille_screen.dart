import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

class PetiteFilleScreen extends StatelessWidget {
  const PetiteFilleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.petiteFille.info.name,
      subtitle: loc.petiteFilleSubtitle,
      accent: RoleId.petiteFille.info.accent,
      contentBuilder: (_) => const _PetiteFilleContent(),
    );
  }
}

class _PetiteFilleContent extends StatelessWidget {
  const _PetiteFilleContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.petiteFilleTitle,
      accent: RoleId.petiteFille.info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: RoleId.petiteFille.info.nightInstruction,
            accent: RoleId.petiteFille.info.accent,
          ),
          const SizedBox(height: 14),
          RoleSectionCard(
            child: Text(
              loc.petiteFilleWarning,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.blood),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => gp.resolvePetiteFille(tried: true),
              child: Text(loc.petiteFilleSpyButton),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => gp.resolvePetiteFille(tried: false),
              child: Text(loc.petiteFilleSleepButton),
            ),
          ),
        ],
      ),
    );
  }
}