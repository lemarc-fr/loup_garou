import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_image.dart';

class VoteResultScreen extends StatelessWidget {
  const VoteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final deaths = state.deathsThisWave.map(state.byId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat du vote')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.gavel, size: 64, color: AppColors.blood),
              const SizedBox(height: 16),
              Text(
                deaths.isEmpty
                    ? 'Le village n\'a éliminé personne.'
                    : 'Le village a voté...',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final p in deaths)
                      Card(
                        child: ListTile(
                          leading: RoleImage(role: p.role, size: 48),
                          title: Text(p.name),
                          subtitle: Text(p.role.info.name),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmVoteResult,
                  child: const Text('La nuit tombe à nouveau'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
