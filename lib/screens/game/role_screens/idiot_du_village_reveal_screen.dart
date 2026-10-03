import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

class IdiotDuVillageRevealScreen extends StatelessWidget {
  const IdiotDuVillageRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final idiot = state.byId(state.idiotDuVillageRevealId!);
    final info = idiot.role.info;
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.idiotDuVillageRevealTitle,
      accent: info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: loc.idiotDuVillageRevealInstruction(idiot.name),
            accent: info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                RoleImage(role: idiot.role, size: 120),
                const SizedBox(height: 16),
                Text(
                  info.name,
                  style:
                      theme.textTheme.displayMedium?.copyWith(color: info.accent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  loc.idiotDuVillageVoteLossMessage(idiot.name),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gp.confirmIdiotDuVillageReveal,
              child: Text(loc.continueButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}