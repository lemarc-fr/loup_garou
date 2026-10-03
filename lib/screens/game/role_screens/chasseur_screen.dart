import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class ChasseurScreen extends StatelessWidget {
  const ChasseurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.chasseurTitle,
      accent: RoleId.chasseur.info.accent,
      child: Column(
        children: [
          RoleInstructionCard(
            text: loc.chasseurInstruction,
            accent: RoleId.chasseur.info.accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setHunterTarget(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}