import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/models/role.dart';

import '../../../providers/game_provider.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class EnfantSauvageScreen extends StatelessWidget {
  const EnfantSauvageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final loc = AppLocalizations.of(context)!;
    final enfantSauvageId =
        gp.state!.alivePlayersWithRole(RoleId.enfantSauvage).first.id;
    return RoleScreenFrame(
      title: loc.enfantSauvageTitle,
      accent: RoleId.enfantSauvage.info.accent,
      child: Column(
        children: [
          RoleInstructionCard(
            text: loc.enfantSauvageInstruction,
            accent: RoleId.enfantSauvage.info.accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers
                      .where((player) => player.id != enfantSauvageId)
                      .toList(),
                  onSelect: (id) => gp.setEnfantSauvageMentor(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}