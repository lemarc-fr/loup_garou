import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../../../widgets/player_grid_selector.dart';

class RenardScreen extends StatelessWidget {
  const RenardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return Scaffold(
        body: Column(
          children: [
            const Text('Ecran Renard : Choisir celui que tu veux espionner '),
            Expanded(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setRenardTarget(id),
                ),
              ),
            ),
            Text('Il y a ${gp.getwolfbeside(gp.state!.renardTarget)} loups vivant dans ces trois joueurs'),
          ],
        )
    );
  }
}