import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';

class ServanteDevoueeScreen extends StatelessWidget {
  const ServanteDevoueeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return Scaffold(
        body: Column(
          children: [
            Text('Ecrant Servante Devou veux tu le role de ${gp.state!.deathbyvillagevote.name} qui etait ${gp.state!.deathbyvillagevote.role} ?'),
            Expanded(
              child: SingleChildScrollView(
                child:
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        gp.setServanteDevoueeChoice(true);
                      },
                      child: const Text('Oui'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        gp.setServanteDevoueeChoice(false);
                      },
                      child: const Text('Non'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}