import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../../../widgets/player_grid_selector.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return Scaffold(
      body: Column(
        children: [
          const Text('Ecran Chasseur'),
          Expanded(
            child: SingleChildScrollView(
              child: PlayerGridSelector(
                players: gp.state!.alivePlayers,
                onSelect: (id) => gp.setHunterTarget(id),
              ),
            ),
          ),
        ],
      )
    );
  }
}