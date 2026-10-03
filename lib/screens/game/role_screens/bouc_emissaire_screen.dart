import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class BoucEmissaireScreen extends StatelessWidget {
  const BoucEmissaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.boucEmissaireTitle,
      accent: RoleId.boucEmissaire.info.accent,
      child: Column(
        children: [
          RoleInstructionCard(
            text: loc.boucEmissaireInstruction,
            accent: RoleId.boucEmissaire.info.accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setBoucEmissaireTarget(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}