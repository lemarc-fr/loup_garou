import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;
    final deaths = state.deathsThisWave.map(state.byId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.dayRevealDayRises(state.day))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.wb_sunny, size: 64, color: AppColors.lantern),
              const SizedBox(height: 16),
              Text(
                deaths.isEmpty
                    ? loc.dayRevealNoDeaths
                    : deaths.length > 1
                        ? loc.dayRevealMultipleDeaths
                        : loc.dayRevealSingleDeath,
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
                              '${p.role.info.name} — ${_causeLabel(loc, p.deathCause)}'),
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
                        ? loc.montreurDoursGrowlsText
                        : loc.montreurDoursCalmText,
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
                  child: Text(loc.villageWakesUpButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _causeLabel(AppLocalizations loc, DeathCause? c) {
    switch (c) {
      case DeathCause.devoreParLesLoups:
        return loc.deathCauseDevoreParLesLoups;
      case DeathCause.potionDeMort:
        return loc.deathCausePotionDeMort;
      case DeathCause.chagrinDAmourCupidon:
        return loc.deathCauseChagrinDAmourCupidon;
      case DeathCause.vengeanceDuChasseur:
        return loc.deathCauseVengeanceDuChasseur;
      case DeathCause.vote:
        return loc.deathCauseVote;
      case DeathCause.tueParLoupBlanc:
        return loc.deathCauseTueParLoupBlanc;
      default :
        return '';
    }
  }
}
