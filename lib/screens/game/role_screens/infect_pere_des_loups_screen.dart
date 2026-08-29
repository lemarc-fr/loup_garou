import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';

class InfectPereDesLoupsScreen extends StatelessWidget {
  const InfectPereDesLoupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return Scaffold(
        body: Column(
          children: [
            Text('Ecran Infect Pére des Loups : choisir si la victime des loup (${gp.state!.loupsVictimId}) va etre infectée'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => gp.setInfectPereDesLoups(true),
                      child: const Text('Infecter'),
                    ),
                    ElevatedButton(
                      onPressed: () => gp.setInfectPereDesLoups(false),
                      child: const Text('Ne pas infecter'),
                    ),
                  ],
                )
              ),
            ),
          ],
        )
    );
  }
}