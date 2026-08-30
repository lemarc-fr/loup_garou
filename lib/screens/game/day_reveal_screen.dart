import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_image.dart';

class DayRevealScreen extends StatelessWidget {
  const DayRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final deaths = state.deathsThisWave.map(state.byId).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Le jour ${state.day} se lève')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.wb_sunny, size: 64, color: AppColors.lantern),
              const SizedBox(height: 16),
              Text(
                deaths.isEmpty
                    ? 'Miracle ! Personne n\'est mort cette nuit.'
                    : deaths.length > 1
                        ? 'Le village pleure ses morts...'
                        : 'Le village pleure son mort...',
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
                          subtitle: Text(
                              '${p.role.info.name} — ${_causeLabel(p.deathCause)}'),
                        ),
                      ),
                  ],
                ),
              ),
              if (state.hasAliveRole(RoleId.montreurDours)) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gp.montreurDoursGrowls
                        ? "L'ours du Montreur d'Ours grogne : un Loup-Garou "
                        "se cache parmi ses voisins."
                        : "L'ours du Montreur d'Ours reste calme cette nuit.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmDayReveal,
                  child: const Text('Le village se réveille'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _causeLabel(DeathCause? c) {
    switch (c) {
      case DeathCause.devoreParLesLoups:
        return 'dévoré(e) par les Loups-Garous';
      case DeathCause.potionDeMort:
        return 'empoisonné(e) par la Sorcière';
      case DeathCause.chagrinDAmourCupidon:
        return 'mort(e) de chagrin d\'amour';
      case DeathCause.vengeanceDuChasseur:
        return 'abattu(e) par le Chasseur';
      case DeathCause.vote:
        return 'pendu(e) par le village';
      default :
        return '';
    }
  }
}
