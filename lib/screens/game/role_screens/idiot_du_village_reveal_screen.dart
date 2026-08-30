import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/role_image.dart';

class IdiotDuVillageRevealScreen extends StatelessWidget {
  const IdiotDuVillageRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final idiot = state.byId(state.idiotDuVillageRevealId!);
    final info = idiot.role.info;

    return Scaffold(
      appBar: AppBar(title: const Text("L'Idiot du Village")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Le village a voté contre ${idiot.name}...',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              RoleImage(role: idiot.role, size: 120),
              const SizedBox(height: 16),
              Text(
                info.name,
                style: theme.textTheme.displayMedium
                    ?.copyWith(color: info.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${idiot.name} révèle son rôle et survit, mais perd '
                    'définitivement son droit de vote.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmIdiotDuVillageReveal,
                  child: const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}