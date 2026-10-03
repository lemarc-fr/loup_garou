import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

class EnfantSauvageCheckScreen extends StatelessWidget {
  const EnfantSauvageCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: loc.enfantSauvagePassTo,
      subtitle: loc.enfantSauvageCheckSubtitle,
      accent: RoleId.enfantSauvage.info.accent,
      contentBuilder: (_) => const _EnfantSauvageCheckContent(),
    );
  }
}

class _EnfantSauvageCheckContent extends StatelessWidget {
  const _EnfantSauvageCheckContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final info = RoleId.enfantSauvage.info;
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.enfantSauvageTitle,
      accent: info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: loc.enfantSauvageModelAliveInstruction,
            accent: info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Icon(info.fallbackIcon, size: 64, color: info.accent),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gp.confirmEnfantSauvageCheck,
              child: Text(loc.goBackToSleepButton),
            ),
          ),
        ],
      ),
    );
  }
}