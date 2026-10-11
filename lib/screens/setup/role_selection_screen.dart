import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_image.dart';
import '../settings/game_settings_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final config = gp.draftConfig!;
    final loc = AppLocalizations.of(context)!;
    // Mode "Amoureux tirés au sort" : Cupidon n'est pas proposé, une case
    // à cocher le remplace en tête de liste.
    final randomLoversMode =
        context.watch<SettingsProvider>().randomLoversInsteadOfCupidon;

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
      if (!randomLoversMode) RoleId.cupidon,
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
        title: Text(loc.roleSelectionTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: loc.gameSettingsTooltip,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GameSettingsScreen()),
              );
              // Le mode de formation des Amoureux a pu changer.
              if (context.mounted) {
                gp.applyLoversMode(
                    randomLoversInsteadOfCupidon: context
                        .read<SettingsProvider>()
                        .randomLoversInsteadOfCupidon);
              }
            },
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
                    '${loc.roleSelectionPlayerCount(config.playerCount)}'
                        '${config.hasVoleur ? loc.roleSelectionVoleurExtraCards : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.moonlight.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remaining < 0
                        ? loc.roleSelectionTooManyRoles(remaining.abs())
                        : loc.roleSelectionAutoVillagers(remaining),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: context.readable(
                          remaining < 0 ? AppColors.blood : AppColors.forest),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: adjustableOrder.length + (randomLoversMode ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (randomLoversMode) {
                    if (index == 0) {
                      return Card(
                        child: CheckboxListTile(
                          value: config.randomLovers,
                          onChanged: (v) => gp.setRandomLovers(v ?? false),
                          secondary: Icon(Icons.favorite,
                              color: context.readableIcon(AppColors.amethyst)),
                          title: Text(loc.roleSelectionRandomLovers,
                              style: theme.textTheme.titleMedium),
                          subtitle: Text(loc.roleSelectionRandomLoversHint),
                        ),
                      );
                    }
                    index -= 1;
                  }
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
                                Text(loc.roleName(role),
                                    style: theme.textTheme.titleLarge),
                                const SizedBox(height: 2),
                                Text(
                                  loc.roleDescription(role),
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
                              gp.recomputeVillagers();
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
                              gp.recomputeVillagers();
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
                  child: Text(loc.continueButtonLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}