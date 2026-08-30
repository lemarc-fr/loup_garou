import 'package:flutter/material.dart';
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

    return RoleScreenFrame(
      title: 'Le Bouc Émissaire',
      accent: RoleId.boucEmissaire.info.accent,
      child: Column(
        children: [
          RoleInstructionCard(
            text:
                'Tu dois désigner le joueur qui ne participera pas au prochain vote du village.',
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