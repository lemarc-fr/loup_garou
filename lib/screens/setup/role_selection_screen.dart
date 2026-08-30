import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_image.dart';
import '../settings/game_settings_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _recomputeVillagers(GameProvider gp) {
    final config = gp.draftConfig!;
    final othersSum = config.roleCounts.entries
        .where((e) => e.key != RoleId.simpleVillageois)
        .fold(0, (sum, e) => sum + e.value);
    final remaining = config.expectedTotalCards - othersSum;
    gp.setRoleCount(RoleId.simpleVillageois, remaining.clamp(0, 999));
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final config = gp.draftConfig!;

    final adjustableOrder = [
      // Camp des Loups
      RoleId.loupGarou,
      RoleId.loupBlanc,
      RoleId.infectPereDesLoups,
      RoleId.grandMechantLoup,
      // Camp du Village
      RoleId.voyante,
      RoleId.sorciere,
      RoleId.chasseur,
      RoleId.salvateur,
      RoleId.corbeau,
      RoleId.renard,
      RoleId.jugeBegue,
      RoleId.servanteDevouee,
      RoleId.boucEmissaire,
      RoleId.ancien,
      RoleId.idiotDuVillage,
      RoleId.montreurDours,
      RoleId.cupidon,
      RoleId.petiteFille,
      RoleId.enfantSauvage,
      RoleId.voleur,
    ];

    final othersSum = config.roleCounts.entries
        .where((e) => e.key != RoleId.simpleVillageois)
        .fold(0, (sum, e) => sum + e.value);
    final remaining = config.expectedTotalCards - othersSum;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Répartition des rôles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Options de jeu',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GameSettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                children: [
                  Text(
                    '${config.playerCount} joueurs'
                        '${config.hasVoleur ? ' · +2 cartes pour le Voleur' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.moonlight.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remaining < 0
                        ? '${remaining.abs()} rôle(s) en trop'
                        : '$remaining Simple(s) Villageois automatique(s)',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: remaining < 0 ? AppColors.blood : AppColors.forest,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: adjustableOrder.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final role = adjustableOrder[index];
                  final count = config.roleCounts[role] ?? 0;
                  final info = role.info;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          RoleImage(role: role, size: 52),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(info.name,
                                    style: theme.textTheme.titleLarge),
                                const SizedBox(height: 2),
                                Text(
                                  info.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.moonlight
                                          .withValues(alpha: 0.65)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: count > 0
                                ? () {
                              gp.incrementRole(role, by: -1);
                              _recomputeVillagers(gp);
                            }
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('$count',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge),
                          ),
                          IconButton.filledTonal(
                            onPressed: (info.unique && count >= 1)
                                ? null
                                : () {
                              gp.incrementRole(role, by: 1);
                              _recomputeVillagers(gp);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.draftConfigValid ? () => gp.goToNames() : null,
                  child: const Text('Continuer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}