import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../../../widgets/player_grid_selector.dart';

class BoucEmissaireScreen extends StatelessWidget {
  const BoucEmissaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return Scaffold(
      body: Column(
        children: [
          const Text(
              'Ecran Mort Bouc Emissaire : choisir celui qui ne va pas jouer la prochaine fois'),
          Expanded(
            child: SingleChildScrollView(
              child: PlayerGridSelector(
                players: gp.state!.alivePlayers,
                onSelect: (id) => gp.setBoucEmissaireTarget(id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}